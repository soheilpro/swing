rm -rf out
mkdir out

echo "Building module core"

xcrun swift \
  -module-name core \
  -emit-library \
  -emit-object \
  -sdk $(xcrun --show-sdk-path --sdk macosx) \
  -I include \
  -import-objc-header bridge.h \
  Error.swift \
  Loop.swift \
  Stream.swift \
  TCPServer.swift

xcrun clang \
  -cc1 \
  -emit-obj \
  -isysroot $(xcrun --show-sdk-path --sdk macosx) \
  -I include \
  -fblocks \
  bridge.c

ar rcs \
  out/libcore.a \
  Error.o \
  Loop.o \
  Stream.o \
  TCPServer.o \
  bridge.o

rm *.o

xcrun swift \
  -module-name core \
  -emit-module Error.swift Loop.swift Stream.swift TCPServer.swift \
  -sdk $(xcrun --show-sdk-path --sdk macosx) \
  -import-objc-header bridge.h \
  -I include \
  -o out/core.swiftmodule
