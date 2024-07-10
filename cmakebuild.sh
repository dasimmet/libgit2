#!/usr/bin/env sh

set -ex

MY_CC="${CC:-cc}"
export CC="$(mktemp --suffix=.cc)"
chmod +x $CC
cat <<EOF > $CC
#!/usr/bin/env sh

set -ex
$MY_CC "\$@"
EOF
# export CFLAGS=""
cleanup(){
    rm "$CC"
}
trap cleanup EXIT

mkdir -p build
cd build
CMAKE_OPTIONS="
    -DREGEX_BACKEND=pcre2
    -DDEPRECATE_HARD=ON
    -DCMAKE_BUILD_TYPE=Debug
    -DUSE_SSH=exec"
export CMAKE_GENERATOR=Ninja

cmake .. $CMAKE_OPTIONS 2>&1 | tee cmake.log
cmake --build . 2>&1 | tee -a cmake.log
