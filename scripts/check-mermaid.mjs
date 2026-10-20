// Parse-check every Mermaid diagram under the given folders, without a browser.
// Checks fenced ```mermaid blocks in .md files and whole .mmd files.
// Usage: node "${CLAUDE_PLUGIN_ROOT}/scripts/check-mermaid.mjs" docs [more folders or files]
// Needs once, in the project: npm i -D mermaid jsdom
// It loads mermaid and jsdom from the project's node_modules (the current directory) first,
// so the script can live in the plugin while the packages live in the project.
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';

const fromProject = createRequire(path.join(process.cwd(), 'noop.js'));
async function load(name) {
  try {
    return await import(pathToFileURL(fromProject.resolve(name)).href);
  } catch {
    return import(name);
  }
}

const { JSDOM } = await load('jsdom');
const dom = new JSDOM('<!doctype html><body></body>');
globalThis.window = dom.window;
globalThis.document = dom.window.document;
const { default: mermaid } = await load('mermaid');

function* files(target) {
  const stat = fs.statSync(target);
  if (stat.isFile()) { yield target; return; }
  for (const entry of fs.readdirSync(target, { withFileTypes: true })) {
    if (entry.name === 'node_modules' || entry.name.startsWith('.')) continue;
    yield* files(path.join(target, entry.name));
  }
}

function diagrams(file) {
  const text = fs.readFileSync(file, 'utf8');
  if (file.endsWith('.mmd')) return [{ line: 1, code: text }];
  if (!file.endsWith('.md')) return [];
  const found = [];
  const lines = text.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim() !== '```mermaid') continue;
    const start = i + 1;
    let end = start;
    while (end < lines.length && lines[end].trim() !== '```') end++;
    found.push({ line: start + 1, code: lines.slice(start, end).join('\n') });
    i = end;
  }
  return found;
}

const targets = process.argv.slice(2);
if (targets.length === 0) {
  console.error('usage: node check-mermaid.mjs <folder or file> [...]');
  process.exit(2);
}

let checked = 0;
let failed = 0;
for (const target of targets) {
  for (const file of files(target)) {
    for (const { line, code } of diagrams(file)) {
      checked++;
      try {
        await mermaid.parse(code);
      } catch (error) {
        failed++;
        console.error(`${file}:${line}: ${String(error.message).split('\n')[0]}`);
      }
    }
  }
}
console.log(`mermaid: ${checked} diagrams checked, ${failed} failed`);
process.exit(failed ? 1 : 0);
