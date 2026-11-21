export const assetPrefix = 'tmp/brandish-icons/assets/';

/** Resource paths shared by cache validation and deployment staging. */
export function resourcePaths(entries) {
	const paths = new Set();
	function collect(value) {
		if (typeof value === 'string' && value.startsWith(assetPrefix)) {
			paths.add(value);
		} else if (value && typeof value === 'object') {
			Object.values(value).forEach(collect);
		}
	}
	entries.forEach((entry) => Object.values(entry).forEach(collect));
	return paths;
}
