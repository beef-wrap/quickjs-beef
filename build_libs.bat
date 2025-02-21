clang -c -g -gcodeview -o quickjs-windows.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall quickjs\quickjs.c

mkdir libs
move quickjs-windows.lib libs
