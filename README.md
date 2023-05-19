# Neovim completion using ripgrep 

If you're using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) but lsp support isn't all you'd hoped - a few tailored ripgrep searches may well do the trick.  The plugin allows you to setup regex searches via ripgrep to flow into the [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion engine.

![Alacritty](https://github.com/kizza/cmp-rg-lsp/assets/1088717/a3439cdd-31bc-47d7-865d-0c0225f092c5)

## Installation

There are many ways to do this. Here's an exmaple using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "kizza/cmp-rg-lsp",
    },
    ...
  }
},
```

## Usage

Include "rg-lsp" amongst your completion `sources`...

```lua
local cmp = require'cmp'

cmp.setup({
  ...
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    {
      name = "rg_lsp",
      patterns = {
        require("cmp-rg-lsp.builtins").ruby, -- Include inbuilt pattern collections
        {
          filetype = { "ruby" }, -- Only run this for given filetypes
          kind = cmp.lsp.CompletionItemKind.Property,  -- How result is displayed
          pattern = '^#\\s*(\\w*%s\\w+)+\\s+:', -- The regex to run over your codebase
          match = 1, -- The match index (given multiple regex groups)
        }
      }
    },
  })
  ...
}
```

## Example regex

The compeltion word being typed is substituted into the pattern via the `%s` character.
So to match method declarations within a ruby codebase (for example)

```ruby
def available_times
  ...
end
```
we can use...
```lur
  pattern = '^\\s*def\\s+(\\w*%s\\w+(\\?|!)?)',
```
with the following breif explanation
- `^` start of line
- `\\s*` possible prefixed white space
- `def\\s+` "def" with space after it
- `(` open the matching group
- `\\w*` perhapa a prefix of other text (ie. look for a partial match)
- `%s` the completion text
- `(\\?|!)?` possibly ending with a `!` or a `?`
- `)` close the matching group

All wrapped up to be
```lua
{
  filetype = { "ruby" }, -- Only run this for given filetypes
  kind = cmp.lsp.CompletionItemKind.Method,  -- We're matching methods
  pattern = '^\\s*def\\s+(\\w*%s\\w+(\\?|!)?)', -- The pattern above
  match = 1, -- We're matching the first group
}
```
