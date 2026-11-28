import { createHash, randomUUID } from 'node:crypto';
import { mkdir, readFile, rename, rm, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const sha256 = (data) => createHash('sha256').update(data).digest('hex');

const download = async (url) => {
  const response = await fetch(url, { signal: AbortSignal.timeout(60_000) });
  if (!response.ok) {
    throw new Error(`Download failed with HTTP ${response.status}: ${url}`);
  }
  return Buffer.from(await response.arrayBuffer());
};

const checksum = (data) => {
  const digest = data.toString('ascii').trim().split(/\s+/)[0];
  if (!/^[a-f0-9]{64}$/i.test(digest)) {
    throw new Error('Invalid Spacelizard SHA256 file');
  }
  return digest.toLowerCase();
};

const publish = async (path, data, mode) => {
  const temp = `${path}.${randomUUID()}.tmp`;
  try {
    await writeFile(temp, data, { flag: 'wx', mode });
    await rename(temp, path);
  }
  finally {
    await rm(temp, { force: true });
  }
};

export const resolveSpacelizard = async () => {
  const dependencyFile = await readFile('dependencies.sh', 'utf8');
  const readPin = (name) => new RegExp(`^export ${name}=([^\\s]+)`, 'm').exec(dependencyFile)?.[1];
  const repo = readPin('SPACELIZARD_REPO');
  const version = readPin('SPACELIZARD_VERSION');
  if (!repo || !/^[\w.-]+\/[\w.-]+$/.test(repo)
    || !version || !/^v[\w.-]+$/.test(version)) {
    throw new Error('Invalid SPACELIZARD_REPO or SPACELIZARD_VERSION in dependencies.sh');
  }
  const assets = { win32: 'spacelizard-win-x64.exe', linux: 'spacelizard-linux-x64' };
  const asset = assets[process.platform];
  if (process.arch !== 'x64' || !asset) {
    throw new Error(`Spacelizard release unavailable for ${process.platform}/${process.arch}`);
  }
  const dir = resolve('tools/bootstrap/.cache', `spacelizard-${version}`);
  await mkdir(dir, { recursive: true });
  const binary = resolve(dir, asset);
  const digestFile = `${binary}.sha256`;
  try {
    const [data, digest] = await Promise.all([readFile(binary), readFile(digestFile)]);
    if (sha256(data) === checksum(digest)) {
      return binary;
    }
  }
  catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
  }

  const url = `https://github.com/${repo}/releases/download/${version}/${asset}`;
  const [data, digest] = await Promise.all([download(url), download(`${url}.sha256`)]);
  if (sha256(data) !== checksum(digest)) {
    throw new Error(`Spacelizard checksum verification failed for ${asset}`);
  }
  await publish(binary, data, 0o755);
  await publish(digestFile, digest, 0o644);
  return binary;
};
