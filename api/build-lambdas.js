// build-lambdas.js
const esbuild = require('esbuild');
const fs = require('fs');
const path = require('path');

const handlers = ['contacts', 'countries'];

for (const name of handlers) {
  const entryPoint = `src/handlers/${name}.ts`;
  const outdir = `dist/${name}`;
  const outfile = `${outdir}/index.js`;

  // Ensure dist/<name> exists
  fs.mkdirSync(outdir, { recursive: true });

  esbuild.buildSync({
    entryPoints: [entryPoint],
    bundle: true,
    platform: 'node',
    target: 'node18', // Match your Lambda runtime
    outfile,
    external: [], // Add node_modules you want to exclude from bundle
  });

  // Zip output
  const zipCmd = `cd dist/${name} && zip -r ../${name}.zip .`;
  require('child_process').execSync(zipCmd, { stdio: 'inherit' });
}
