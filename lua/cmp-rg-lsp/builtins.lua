local cmp = require("cmp")
local M = {}

M.ruby = {
  {
    kind = cmp.lsp.CompletionItemKind.Method,
    pattern = '^\\s*(def|scope)\\s+(self\\.|:)?(\\w*%s\\w+(\\?|!)?)',
    match = 3,
    filetype = { "ruby" },
  },
  {
    kind = cmp.lsp.CompletionItemKind.Property,
    pattern = '^\\s*(attribute|has_one|has_many|belongs_to|has_and_belongs_to_many)\\s+:?(\\w*%s\\w+)',
    match = 2,
    filetype = { "ruby" },
  },
  {
    kind = cmp.lsp.CompletionItemKind.Class,
    pattern = '^\\s*(class)\\s+(\\w*%s\\w+)',
    match = 2,
    filetype = { "ruby" },
  },
  {
    kind = cmp.lsp.CompletionItemKind.Module,
    pattern = '^\\s*(module)\\s+(\\w*%s\\w+)',
    match = 2,
    filetype = { "ruby" },
  }
}

return M
