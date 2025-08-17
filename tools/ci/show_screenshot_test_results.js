import fetch, { FormData, fileFrom } from "node-fetch";
import fs from "fs";
import path from "path";
import process from "process";

const createComment = (zipFileUrl) => {
	return `
		Screenshot tests failed!

		${
			zipFileUrl
				? `[Download zip file of new screenshots.](${zipFileUrl})`
				: "No zip file could be produced, this is a bug!"
		}

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

	await github.rest.issues.createComment({
		owner: context.repo.owner,
		repo: context.repo.repo,
		issue_number: prNumber,
		body: createComment(badScreenshots.url),
	});
}
