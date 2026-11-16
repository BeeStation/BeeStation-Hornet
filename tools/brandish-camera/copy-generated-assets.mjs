import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { assetPrefix, resourcePaths } from './manifest-resources.mjs';

/** Copy the completed catalog's resources without pruning the shared cache. */
export function copyGeneratedAssets(root, destination) {
	const sourceAssets = path.resolve(root, assetPrefix);
	const destinationAssets = path.resolve(destination, assetPrefix);
	const samePath =
		process.platform === 'win32'
			? sourceAssets.toLowerCase() === destinationAssets.toLowerCase()
			: sourceAssets === destinationAssets;
	if (samePath) {
		throw new Error(
			'Generated-asset staging must be separate from the source cache.',
		);
	}
	const manifest = JSON.parse(
		fs.readFileSync(
			path.join(root, 'tmp/brandish-icons/manifest.json'),
			'utf8',
		),
	);
	if (!Array.isArray(manifest.entries))
		throw new Error('Invalid generated resource manifest.');
	const names = new Set();
	for (const resource of resourcePaths(manifest.entries)) {
		const name = resource.slice(assetPrefix.length);
		if (!/^[a-f0-9]{24}\.dmi$/.test(name)) {
			throw new Error(`Invalid generated resource path: ${resource}`);
		}
		names.add(name);
	}
	// Validate every source before changing an existing staging directory.
	for (const name of names) {
		if (!fs.statSync(path.join(sourceAssets, name)).isFile()) {
			throw new Error(`Missing generated resource: ${name}`);
		}
	}
	fs.mkdirSync(destinationAssets, { recursive: true });
	for (const name of names) {
		fs.copyFileSync(
			path.join(sourceAssets, name),
			path.join(destinationAssets, name),
		);
	}
	for (const entry of fs.readdirSync(destinationAssets, {
		withFileTypes: true,
	})) {
		if (
			entry.isFile() &&
			entry.name.endsWith('.dmi') &&
			!names.has(entry.name)
		) {
			fs.unlinkSync(path.join(destinationAssets, entry.name));
		}
	}
	return names.size;
}

if (
	process.argv[1] &&
	path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)
) {
	if (!process.argv[2])
		throw new Error('Usage: copy-generated-assets.mjs <staging-directory>');
	const count = copyGeneratedAssets(
		process.cwd(),
		path.resolve(process.argv[2]),
	);
	console.log(
		`Staged ${count} generated resources from the current manifest.`,
	);
}
