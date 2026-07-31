#!/usr/bin/env bun
// One-shot release: verify, bump the build number, commit everything, tag and
// push. The tag *is* the build number - `v<major>.<minor>.<build>` - so there
// is a single counter to reason about instead of two that drift apart (they
// had: tags were at v1.0.39 while pubspec was on +35).
//
// The next number is `max(current build, highest existing tag) + 1`, which is
// what closes that gap on the first run and keeps both monotonic afterwards.
// Build numbers may only ever go up - Apple rejects a re-used one - so jumping
// forward is safe and going backwards is never attempted.
//
// Usage:
//   bun scripts/release.ts -m "feat: what changed"
//   bun scripts/release.ts -m "fix: ..." --dry-run      # print the plan, touch nothing
//   bun scripts/release.ts -m "fix: ..." --skip-checks  # skip analyze + test
//   bun scripts/release.ts -m "..." --allow-branch      # release off a non-main branch

import { readFileSync, writeFileSync } from "fs";
import { join } from "path";

const repoRoot = join(import.meta.dir, "..");
const pubspecPath = join(repoRoot, "pubspec.yaml");
const isWindows = process.platform === "win32";

function fail(message: string): never {
  console.error(`\n  release: ${message}\n`);
  process.exit(1);
}

/** Runs a command, streaming its output. Aborts the release if it fails. */
function run(cmd: string[]) {
  const proc = Bun.spawnSync({ cmd, cwd: repoRoot, stdout: "inherit", stderr: "inherit" });
  if (proc.exitCode !== 0) {
    fail(`\`${cmd.join(" ")}\` exited with ${proc.exitCode}`);
  }
}

/** Runs a command and returns its stdout. [tolerant] swallows a non-zero exit. */
function capture(cmd: string[], { tolerant = false } = {}): string {
  const proc = Bun.spawnSync({ cmd, cwd: repoRoot, stdout: "pipe", stderr: "pipe" });
  if (proc.exitCode !== 0 && !tolerant) {
    process.stderr.write(proc.stderr.toString());
    fail(`\`${cmd.join(" ")}\` exited with ${proc.exitCode}`);
  }
  return proc.stdout.toString().trim();
}

// `flutter` is a .bat on Windows, which only resolves through the shell. git is
// a real .exe, so it stays a direct spawn - that keeps the commit message out
// of any shell quoting.
const flutter = (...args: string[]) =>
  isWindows ? ["cmd", "/c", "flutter", ...args] : ["flutter", ...args];

// ----------------------------------------------------------------- arguments

const argv = process.argv.slice(2);
const dryRun = argv.includes("--dry-run");
const skipChecks = argv.includes("--skip-checks");
const allowBranch = argv.includes("--allow-branch");

const messageIndex = argv.findIndex((a) => a === "-m" || a === "--message");
const message =
  argv.find((a) => a.startsWith("--message="))?.slice("--message=".length) ??
  (messageIndex >= 0 ? argv[messageIndex + 1] : undefined);

if (!message?.trim()) {
  fail(
    "a commit message is required\n" +
      '  usage: bun scripts/release.ts -m "feat: what changed" [--dry-run] [--skip-checks]',
  );
}

// ------------------------------------------------------------------ preflight

const branch = capture(["git", "rev-parse", "--abbrev-ref", "HEAD"]);
if (branch !== "main" && !allowBranch) {
  fail(`on branch '${branch}', not main. Pass --allow-branch to release anyway.`);
}

if (!capture(["git", "status", "--porcelain"])) {
  fail("nothing to release - the working tree is clean.");
}

// Remote tags decide the next number, so a stale local tag list would hand out
// one that already exists on the remote and the push would be rejected.
console.log("• fetching tags");
run(["git", "fetch", "--tags", "--quiet"]);

// -------------------------------------------------------------- next version

const pubspec = readFileSync(pubspecPath, "utf8");
const versionLine = /^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$/m;
const match = pubspec.match(versionLine);
if (!match) fail("could not find a `version: X.Y.Z+B` line in pubspec.yaml");

const [, major, minor, patch, buildStr] = match;
const currentBuild = Number(buildStr);

// Only tags on this major.minor line count: `--set-version=1.1.0` resets the
// build to 1, and v1.1.1 must not be blocked by the v1.0.x series above it.
const tagPrefix = `v${major}.${minor}.`;
const highestTag = capture(["git", "tag", "--list", `${tagPrefix}*`])
  .split("\n")
  .map((t) => Number(t.trim().slice(tagPrefix.length)))
  .filter((n) => Number.isInteger(n))
  .reduce((a, b) => Math.max(a, b), 0);

const build = Math.max(currentBuild, highestTag) + 1;
const version = `${major}.${minor}.${patch}+${build}`;
const tag = `${tagPrefix}${build}`;

if (capture(["git", "tag", "--list", tag])) {
  fail(`tag ${tag} already exists, refusing to move it.`);
}

console.log(`\n  branch   ${branch}`);
console.log(`  version  ${major}.${minor}.${patch}+${currentBuild} -> ${version}`);
console.log(`  tag      ${tag}`);
console.log(`  message  ${message.split("\n")[0]}\n`);

if (dryRun) {
  console.log("  --dry-run: nothing written, committed, tagged or pushed.\n");
  console.log(capture(["git", "status", "--short"]));
  process.exit(0);
}

// ---------------------------------------------------------------- verify

// Before the bump, so a failing check leaves pubspec.yaml untouched.
if (skipChecks) {
  console.log("• skipping analyze + test (--skip-checks)");
} else {
  // `flutter analyze` treats *every* diagnostic as fatal by default, infos
  // included, so this exited 1 on the ~90 style lints this repo has always
  // carried and no release could ever run. Infos are still printed - they just
  // don't block. Warnings and errors remain fatal, which is the line that
  // actually matters.
  console.log("• flutter analyze (infos reported, not fatal)");
  run(flutter("analyze", "--no-fatal-infos", "lib"));
  console.log("• flutter test");
  run(flutter("test"));
}

// ---------------------------------------------------------------- release

console.log(`• pubspec.yaml -> ${version}`);
writeFileSync(pubspecPath, pubspec.replace(versionLine, `version: ${version}`));

console.log("• commit");
run(["git", "add", "-A"]);
run(["git", "commit", "-m", message]);

console.log(`• tag ${tag}`);
run(["git", "tag", tag]);

// Commit and tag exist locally from here on, so a failed push is recoverable
// rather than lost - say how, instead of leaving it looking like nothing ran.
console.log("• push");
const push = Bun.spawnSync({
  cmd: ["git", "push", "origin", branch],
  cwd: repoRoot,
  stdout: "inherit",
  stderr: "inherit",
});
if (push.exitCode !== 0) {
  fail(
    `push failed, but the commit and tag ${tag} exist locally.\n` +
      `  retry:  git push origin ${branch} && git push origin ${tag}\n` +
      `  undo:   git tag -d ${tag} && git reset --hard HEAD~1`,
  );
}
run(["git", "push", "origin", tag]);

console.log(`\n  released ${version} as ${tag} on ${branch}\n`);
