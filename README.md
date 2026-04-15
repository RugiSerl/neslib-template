# neslib-template
Template NES project in C using neslib.

Should build OK on Linux. Has a dependency on libpng for the png2chr tool, so make sure you have a "dev" package for that installed or built.

1. You should first download and build the dependencies (like cc65) by executing task `make setup`.
2. Now you can build the NES ROM by running `make`

I personally recommend using clangd lsp for this project. (to get compile_commands.json with compile parameters just use bear with the command `bear -- make`)

Enjoy some NES coding?
