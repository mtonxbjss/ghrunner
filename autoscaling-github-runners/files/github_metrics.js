/* eslint-disable import/no-extraneous-dependencies */
const AWS = require("aws-sdk");
const https = require("https");
const querystring = require("querystring");

function sendRequestToGithub(
  ownerId,
  repoId,
  authHeader,
  subPath = "",
  queryParams = {}
) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: "api.github.com",
      path: `/repos/${ownerId}/${repoId}/actions${subPath}?${querystring.stringify(
        queryParams
      )}`,
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: authHeader,
        "User-Agent": ownerId,
      },
    };
    https
      .get(options, (resp) => {
        let data = "";
        resp.on("data", (chunk) => {
          data += chunk;
        });
        resp.on("end", () => {
          resolve(JSON.parse(data));
        });
      })
      .on("error", (err) => {
        reject(new Error(err));
      });
  });
}

async function findJobsForTag(ownerId, projectId, tag, authHeader) {
  try {
    // get all jobs that are currently queued waiting for a runner with the required tag
    const workflowRuns = await sendRequestToGithub(
      ownerId,
      projectId,
      authHeader,
      "/runs",
      { status: "queued" }
    );
    const workflowJobIds = workflowRuns.workflow_runs.map((run) => run.id);
    const allJobsAllRuns = await Promise.all(
      workflowJobIds.map((runId) =>
        sendRequestToGithub(
          ownerId,
          projectId,
          authHeader,
          `/runs/${runId}/jobs`
        )
      )
    );
    const allQueuedJobs = allJobsAllRuns
      .map((run) => {
        return run.jobs.filter(
          (job) => job.status === "queued" && job.labels.includes(tag)
        );
      })
      .flat();
    console.log("All Queued Jobs...");
    console.log(allQueuedJobs.map((job) => job.html_url));

    // get all busy runners that have the required tag
    const allRunners = await sendRequestToGithub(
      ownerId,
      projectId,
      authHeader,
      "/runners",
      { per_page: "100" }
    );
    const filteredRunners = allRunners.runners.filter(
      (runner) =>
        runner.busy &&
        runner.labels.filter((runnerTag) => runnerTag.name === tag).length > 0
    );
    console.log("All Busy Runners...");
    console.log(filteredRunners.map((runner) => runner.name));

    return {
      queued: allQueuedJobs.length,
      running: filteredRunners.length,
    };
  } catch (gitErr) {
    throw new Error(
      `Error querying github jobs (project id ${projectId}, tag ${tag}) :: ${gitErr}`
    );
  }
}

async function putMetricData(metric, value, tag, namespace) {
  try {
    const CW = new AWS.CloudWatch({
      apiVersion: "2010-08-01",
      region: "eu-west-2",
    });
    const params = {
      MetricData: [
        {
          MetricName: metric,
          Unit: "Count",
          Value: value,
          Timestamp: new Date(),
          Dimensions: [
            {
              Name: "Tag",
              Value: tag,
            },
          ],
        },
      ],
      Namespace: namespace,
    };
    await CW.putMetricData(params).promise();
  } catch (metricErr) {
    throw new Error(`Failed to put metric data to CloudWatch :: ${metricErr}`);
  }
}

async function getSecret(name) {
  try {
    const SM = new AWS.SecretsManager({
      apiVersion: "2017-10-17",
      region: "eu-west-2",
    });
    const param = {
      SecretId: name,
    };
    console.log(`getting PAT token`);
    const smSecretResult = await SM.getSecretValue(param).promise();
    return `Bearer ${smSecretResult.SecretString}`;
  } catch (smErr) {
    throw new Error(`Failed to retrieve github pat token :: ${smErr}`);
  }
}

exports.handler = async () => {
  try {
    // get env vars
    const {
      GITHUB_PAT_SECRET_ARN: tokenPath,
      GITHUB_OWNER: ownerId,
      GITHUB_REPO_NAMES: repoId,
      TAG_LIST: tag,
      CLOUDWATCH_NAMESPACE: cloudwatchNamespace,
    } = process.env;

    // get github auth token from Secrets Manager
    console.log(tokenPath);
    const authHeader = await getSecret(tokenPath);

    // get count of pending jobs from github (monorepo + pipeline jobs)
    let queuedJobs = 0;
    let runningJobs = 0;
    try {
      await Promise.all(
        repoId.split(",").map(async (repo) => {
          const jobCount = await findJobsForTag(ownerId, repo, tag, authHeader);
          queuedJobs += jobCount.queued;
          runningJobs += jobCount.running;
        })
      );
    } catch (repoErr) {
      throw new Error(`Failed to count jobs in repos :: ${repoErr}`);
    }

    // write CloudWatch metrics
    // eslint-disable-next-line no-console
    console.log(`Total queued jobs on the runners: ${queuedJobs}`);
    console.log(`Total running jobs on the runners: ${runningJobs}`);

    putMetricData("githubQueued", queuedJobs, tag, cloudwatchNamespace);
    putMetricData("githubRunning", runningJobs, tag, cloudwatchNamespace);

    return true;
  } catch (err) {
    throw new Error(`Failed to record github runner metrics :: ${err}`);
  }
};
