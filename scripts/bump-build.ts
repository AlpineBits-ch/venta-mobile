#!/usr/bin/env bun
// Bumps the build number (the `+N` suffix) in pubspec.yaml, which is what
// Flutter feeds into both Android's versionCode and iOS's CFBundleVersion.
// Apple rejects re-uploading a build with the same version+build number, so
// this needs to go up on every TestFlight upload.
//
// Usage:
//   bun scripts/bump-build.ts                  # bump build number by 1
//   bun scripts/bump-build.ts --set-version=1.1.0   # set marketing version, reset build to 1

import { readFileSync, writeFileSync } from "fs";
import { join } from "path";

const pubspecPath = join(import.meta.dir, "..", "pubspec.yaml");
const content = readFileSync(pubspecPath, "utf8");

const versionLineRegex = /^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m;
const match = content.match(versionLineRegex);
if (!match) {
  console.error("Could not find a `version: X.Y.Z+B` line in pubspec.yaml");
  process.exit(1);
}

const [, currentMarketingVersion, currentBuildStr] = match;
const currentBuild = parseInt(currentBuildStr, 10);

const setVersionArg = process.argv
  .find((a) => a.startsWith("--set-version="))
  ?.split("=")[1];

const newMarketingVersion = setVersionArg ?? currentMarketingVersion;
const newBuild = setVersionArg ? 1 : currentBuild + 1;

const newContent = content.replace(
  versionLineRegex,
  `version: ${newMarketingVersion}+${newBuild}`,
);
writeFileSync(pubspecPath, newContent);

console.log(
  `pubspec.yaml version: ${currentMarketingVersion}+${currentBuild} -> ${newMarketingVersion}+${newBuild}`,
);
