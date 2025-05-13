# Lua scripts

I started porting some of the scripts to Lua, for better performance and
portability.

The main reason for this is that I already have Lua installed on my system
(since I use [Neovim][neovim] as my editor), so I can just use it to write the
scripts. I also wanted to have a better and more portable way of having my own
"library" that I could use across multiple scripts for common operations, like
parsing arguments, handling git repositories, colorful output, etc.

## The `launcher.lua` script

This is the main script that I use to run all the other scripts. It's a simple
Lua script that loads the other scripts and runs them based on the name of the
calling script.

The scripts themselves are located in the `./lua/scripts` folder. I also keep
the helpers in the `./lua/helpers` folder.

## Global variables

The main reason foe the `launcher.lua` script to exist is to have a context
that's available to all the scripts I want to run. It does this by setting up
a global environment that's available to all the scripts. You can check the
helpers in the `./lua/helpers` folder to see what's available.

Other than that, the `launcher.lua` script also parses the command line
arguments and sets them as global variables that can be accessed by the scripts.

```lua
_G.options = {
  -- Named options
  option1 = true,
  option2 = false,
  option3 = "value",
}

_G.args = { ... } -- Positional arguments (args[1], args[2], ...)
```

---

[ansicolors]: https://github.com/kikito/ansicolors.lua
[neovim]: https://neovim.io/
