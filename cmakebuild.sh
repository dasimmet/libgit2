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
    -DREGEX_BACKEND=builtin
    -DDEPRECATE_HARD=ON
    -DCMAKE_BUILD_TYPE=Debug
    -DUSE_HTTPS=OpenSSL
    -DUSE_GSSAPI=ON
    -DDEBUG_STRICT_ALLOC=ON
    -DDEBUG_STRICT_OPEN=ON
    -DUSE_SSH=exec"

# -DUSE_THREADS=OFF
# -DUSE_LEAK_CHECKER=valgrind

export CMAKE_GENERATOR=Ninja
export PKGCONFIG="false"
cmake .. $CMAKE_OPTIONS 2>&1 | tee cmake.log
cmake --build . 2>&1 | tee -a cmake.log
