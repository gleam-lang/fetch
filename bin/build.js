import { copyFile, readFile, mkdir, access, readdir } from "fs/promises";
import { join } from "path";
import { promisify } from "util";
import { exec as callbackExec } from "child_process";

let exec = promisify(callbackExec);

export async function build() {
  let { name, gleamDependencies } = JSON.parse(
    await readFile("./package.json")
  );

  await Promise.all(gleamDependencies.map(clone));
  for (let dep of gleamDependencies) await cachedBuildProject(dep);

  await buildProject({
    name,
    root: ".",
    includeTests: true,
    dependencies: gleamDependencies.map((d) => d.name),
  });

  return {
    name,
  };
}

async function copyJs(name, dir) {
  let inDir = join(dir, "src");
  let out = outDir(name);
  let files = await readdir(inDir);
  files.map(async (file) => {
    if (file.endsWith(".js")) {
      await copyFile(join(inDir, file), join(out, file));
    }
  });
}

async function cachedBuildProject(info) {
  if (await fileExists(outDir(info.name))) return;
  await buildProject(info);
}

async function buildProject({ name, root, dependencies, includeTests }) {
  console.log(`Building ${name}`);
  let dir = root || libraryDir(name);
  let src = join(dir, "src");
  let test = join(dir, "test");
  console.log("src", src, "test", test);
  let out = outDir(name);
  try {
    await exec(
      [
        "gleam compile-package",
        `--name ${name}`,
        "--target javascript",
        `--src ${src}`,
        includeTests ? `--test ${test}` : "",
        `--out ${out}`,
        (dependencies || []).map((dep) => `--lib=${outDir(dep)}`).join(" "),
      ].join(" ")
    );
  } catch (error) {
    console.error(error.stderr);
    process.exit(1);
  }
  await copyJs(name, dir);
}

async function clone({ name, ref, url }) {
  let dir = libraryDir(name);
  if (await fileExists(dir)) return;
  await mkdir(dir, { recursive: true });
  await exec(`git clone --depth=1 --branch="${ref}" "${url}" "${dir}"`);
}

function libraryDir(name) {
  return join("target", "deps", name);
}

function outDir(name) {
  return join("target", "lib", name);
}

async function fileExists(path) {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}
