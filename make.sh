rm -rf out
mkdir out

pushd modules/core > /dev/null
./make.sh
popd > /dev/null

echo "Building main"

xcrun swiftc main.swift \
  -module-name main \
  -sdk $(xcrun --show-sdk-path --sdk macosx) \
  -I modules/core \
  -I modules/core/include \
  -I modules/core/out \
  -L modules/core/lib \
  -L modules/core/out \
  -lcore \
  -luv \
  -o out/main
