local M = {}

function M.log(message)
  local log_file_path = vim.fn.stdpath("cache") .. "/cmp-rg-lsp.log"
  local log_file = io.open(log_file_path, "a")
  io.output(log_file)
  io.write(message.."\n")
  io.close(log_file)
end

function M.stop_timer_on_quit(timer)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
      end
    end,
  })
end

function M.flatten(input, flattened)
  local flattened = flattened or {}
  for _,value in pairs(input) do
    if #value == 0 then
      table.insert(flattened, value)
    else
      flattened = M.flatten(value, flattened)
    end
  end
  return flattened
end

function M.contains(table, match)
  for _, value in ipairs(table) do
    if value == match then
      return true
    end
  end
  return false
end

return M
