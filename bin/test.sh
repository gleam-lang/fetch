#/bin/bash
set -eu

library_dir() {
  echo "target/deps/$1"
}

project_dir() {
  echo "target/lib/$1"
}

clone_dep() {
  local dir=$(library_dir "$1")
  local tag="$2"
  local url="$3"

  if [ ! -d "$dir" ] ; then
    mkdir -p "$dir"
    git clone --depth=1 --branch="$tag" "$url" "$dir"
  fi
}

compile_library() {
  local name="$1"
  echo "Compiling $name"

  shift
  local lib_flags=()
  for dep in "$@"; do
    lib_flags+=("--lib=$(project_dir $dep)")
  done

  local dir=$(library_dir "$name")
  local src="$dir/src"
  local out=$(project_dir "$name")


  if [ ! -d "$out" ] ; then
    gleam compile-package \
      --name "$name" \
      --target javascript \
      --src "$src" \
      --out $(project_dir "$name") \
      "${lib_flags[@]: }"
    if compgen -G "$src/"*.js > /dev/null; then
      cp "$src/"*.js "$out/"
    fi
  fi
}

clone_dep gleam_stdlib main https://github.com/gleam-lang/stdlib.git
clone_dep gleam_http main https://github.com/gleam-lang/http.git
clone_dep gleam_javascript main https://github.com/gleam-lang/javascript.git

compile_library gleam_stdlib
compile_library gleam_http gleam_stdlib
compile_library gleam_javascript gleam_stdlib

rm -rf $(project_dir gleam_fetch)
gleam compile-package \
  --name gleam_fetch \
  --target javascript \
  --src src \
  --test test \
  --out $(project_dir gleam_fetch) \
  --lib $(project_dir gleam_stdlib) \
  --lib $(project_dir gleam_javascript) \
  --lib $(project_dir gleam_http)
cp "src/"*.js $(project_dir gleam_fetch)/

node bin/run-tests.js
