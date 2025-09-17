doc:
    vimcats  \
    lua/base16-pro-max/init.lua \
    lua/base16-pro-max/types.lua \
    lua/base16-pro-max/parser.lua \
    > doc/base16-pro-max.nvim.txt

set shell := ["bash", "-cu"]

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
