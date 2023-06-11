# Battleship.nvim

Play battleship against the computer directly in your favorite text editor! (add screenshots)

## Motivation

I wanted to learn more about the Lua programming language and neovim API in order to write more serious plugins to improve my workflow. Since battleship was a fun game from when I was a kid, with simple rules and would make me work with buffer writing, window management, highlighting and more, it seemed like a fair choice of first project.

## How to Play

First install the plugin using your package manager of choice. With [packer](https://github.com/wbthomason/packer.nvim), it is as simple as:

```lua
use "victoroliveirab/battleship.nvim"
```

In order to initialize the plugin, just call the setup function anywhere

```lua
require("battleship").setup()
```

This will setup things such as seeding the pseudo-random number generation, highlights and more.
Run the command `:Battleship` in order to start playing. A prompt will appear and the [rules](https://www.hasbro.com/common/instruct/battleship.pdf) are the same as usual.

## TODO

- Allow user to assemble her own defense board
- Simulate delay to improve experience
- Offer more setup parameters to the user
- Add ability to save and load a match
- Add lifetime and in-game stats
