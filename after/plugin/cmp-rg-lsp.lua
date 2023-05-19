local ok, cmp = pcall(require, "cmp")

if ok then
  cmp.register_source("rg_lsp", require("cmp-rg-lsp"))
end
