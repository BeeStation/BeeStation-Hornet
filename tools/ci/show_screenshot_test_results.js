import fetch, { FormData, fileFrom } from "node-fetch";
import fs from "fs";
import path from "path";
import process from "process";

const createComment = (screenshotFailures, zipFileUrl) => {
	const formatScreenshotFailure = ({
		directory,
		diffUrl,
		newUrl,
		oldUrl,
	}) => {
		const img = (url) => {
			if (url) {
				return `![](${url})`;
			} else {
				return "None produced.";
			}
		};

		return `| ${directory} | ${img(oldUrl)} | ${img(newUrl)} | ${img(
			diffUrl
		)} |`;
	};

	return `
		Screenshot tests failed!

		${
			zipFileUrl
				? `[Download zip file of new screenshots.](${zipFileUrl})`
				: "No zip file could be produced, this is a bug!"
		}

		## Diffs
		<details>
			<summary>See snapshot diffs</summary>

			| Name | Expected image | Produced image | Diff |
			| :--: | :------------: | :------------: | :--: |
			${screenshotFailures.map(formatScreenshotFailure).join("\n")}
		</details>

		## Help
		<details>
			<summary>What is this?</summary>

			Screenshot tests make sure that specific icons look the same as they did before.
			This is important for elements that often mistakenly change, such as alien species.

			If the produced image looks broken, then it is possible your code caused a bug.
			Make sure to test in game to see if you can fix it.
		</details>

		<details>
			<summary>I am changing sprites, it's supposed to look different.</summary>

			If the newly produced sprites are correct, then the tests should be updated.

			You can either:

			1. Right-click the "produced image", and save it in \`code/modules/unit_tests/screenshots/NAME.png\`.
			2. Download and extract [this zip file](${zipFileUrl}) in the root of your repository, and commit.

			If you need help, you can ask maintainers either on Discord or on this pull request.
		</details>

		<details>
			<summary>This is a false positive.</summary>

			If you are sure your code did not cause this failure, especially if it's inconsistent,
			then you may have found a false positive.

			Ask maintainers to rerun the test.

			If you need help, you can ask maintainers either on Discord or on this pull request.
		</details>
	`.replace(/\t/g, ""); // If we keep tabs, it'll become a code block.
};

export async function showScreenshotTestResults({ github, context, exec }) {
	// Check if bad-screenshots is in the artifacts
	const {
		data: { artifacts },
	} = await github.rest.actions.listWorkflowRunArtifacts({
		owner: context.repo.owner,
		repo: context.repo.repo,
		run_id: context.payload.workflow_run.id,
	});

	const badScreenshots = artifacts.find(
		({ name }) => name === "bad-screenshots"
	);
	if (!badScreenshots) {
		console.log("No bad screenshots found");
		return;
	}

	// Download the screenshots from the artifacts
	const download = await github.rest.actions.downloadArtifact({
		owner: context.repo.owner,
		repo: context.repo.repo,
		artifact_id: badScreenshots.id,
		archive_format: "zip",
	});

	fs.writeFileSync("bad-screenshots.zip", Buffer.from(download.data));

	await exec.exec("unzip bad-screenshots.zip -d bad-screenshots");

	const prNumberFile = path.join(
		"bad-screenshots",
		"pull_request_number.txt"
	);

	if (!fs.existsSync(prNumberFile)) {
		console.log("No PR number found");
		return;
	}

	const prNumber = parseInt(fs.readFileSync(prNumberFile, "utf8"), 10);
	if (!prNumber) {
		console.log("No PR number found");
		return;
	}

	fs.rmSync(prNumberFile);

	// Collect screenshots and re-upload as individual artifacts
	const screenshotFailures = [];
	for (const directory of fs.readdirSync("bad-screenshots")) {
		const newPath = path.join("bad-screenshots", directory, "new.png");
		const oldPath = path.join("bad-screenshots", directory, "old.png");
		const diffPath = path.join("bad-screenshots", directory, "diff.png");

		if (![newPath, oldPath, diffPath].some((p) => fs.existsSync(p)))
			continue;

		// Upload screenshots as new artifacts
		const uploadAndGetUrl = async (file, label) => {
			if (!fs.existsSync(file)) return null;

			await github.rest.actions.uploadArtifact({
				owner: context.repo.owner,
				repo: context.repo.repo,
				run_id: context.runId,
				name: `${directory}-${label}`,
				files: [file],
			});

			// Note: GitHub doesn’t provide direct image links; instead, artifact download URL:
			const { data } = await github.rest.actions.listWorkflowRunArtifacts(
				{
					owner: context.repo.owner,
					repo: context.repo.repo,
					run_id: context.runId,
				}
			);
			const artifact = data.artifacts.find(
				(a) => a.name === `${directory}-${label}`
			);
			return artifact ? artifact.archive_download_url : null;
		};

		let newUrl, oldUrl, diffUrl;
		await Promise.all([
			uploadAndGetUrl(newPath, "new").then((u) => (newUrl = u)),
			uploadAndGetUrl(oldPath, "old").then((u) => (oldUrl = u)),
			uploadAndGetUrl(diffPath, "diff").then((u) => (diffUrl = u)),
		]);

		screenshotFailures.push({ directory, newUrl, oldUrl, diffUrl });
	}

	if (screenshotFailures.length === 0) {
		console.log("No screenshot failures found");
		return;
	}

	// Build PR comment (clickable download links)
	const comment = screenshotFailures
		.map(({ directory, newUrl, oldUrl, diffUrl }) => {
			return `### Screenshot mismatch: \`${directory}\`

**Old** [Download](${oldUrl})
**New** [Download](${newUrl})
**Diff** [Download](${diffUrl})`;
		})
		.join("\n\n");

	await github.rest.issues.createComment({
		owner: context.repo.owner,
		repo: context.repo.repo,
		issue_number: prNumber,
		body: comment,
	});
}
