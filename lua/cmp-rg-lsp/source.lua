local cmp = require("cmp")
local util = require("cmp-rg-lsp.util")

local source = {}

source.new = function()
  local timer = vim.loop.new_timer()
  util.stop_timer_on_quit(timer)

  return setmetatable({
    running_jobs = {},
    timer = timer,
  }, { __index = source })
end

source.get_debug_name = function(self)
  return "cmp-rp-lsp"
end

source.is_available = function(self)
  return vim.fn.executable('rg') == 1
end

source.complete = function(self, request, callback)
  local seen = {}
  local items = {}
  local throttle = 5

  local function on_event(job_id, data, event)
    if event == "stdout" then
      local completed_job = self:get_running_job(job_id)

      if request.option.debug then
        util.log("Chunk returned...\n"..vim.inspect({
          job_id = completed_job.job_id, cmd = completed_job.cmd, data = data,
        }))
      end

      for _, match in ipairs(data) do
        if match ~= "" and not seen[match] then
          table.insert(items, {
            label = match,
            kind = completed_job.kind,
          })

          seen[match] = true
        end
      end

      if request.option.debug then
        util.log("Search\n".. completed_job.cmd .. " now we have\n"..vim.inspect(items))
      end

      if #items - throttle >= throttle then
        throttle = throttle * 2
        callback { items = items, isIncomplete = true }
      end
    end

    if event == "stderr" and request.option.debug then
      vim.cmd('echomsg "Error handling '.. source.get_debug_name() .. ' response"')
      util.log(vim.inspect({
        cmd = completed_job.cmd,
        data = data,
      }))
    end

    if event == "exit" then
      callback { items = items, isIncomplete = false }
    end
  end

  self.timer:stop()
  self.timer:start(
    request.option.debounce or 100,
    0,
    vim.schedule_wrap(
      function()
        self:stop_running_jobs()

        local text = string.sub(request.context.cursor_before_line, request.offset)
        if string.len(text) < 3 then
          return callback { items = items, isIncomplete = true }
        end

        self:start_jobs(text, request, on_event)
      end
    )
  )
end

source.get_running_job = function(self, job_id)
  for _, job in ipairs(self.running_jobs) do
    if job.job_id == job_id then
      return job
    end
  end
end

source.stop_running_jobs = function(self)
  for _, running_job in ipairs(self.running_jobs) do
    vim.fn.jobstop(running_job.job_id)
    table.remove(self.running_jobs, 1)
  end
end

source.start_jobs = function(self, text, request, on_event)
  for _, pattern in ipairs(source.filtered_patterns(request)) do
    cmd = source.build_cmd(
      string.format(pattern.pattern, text),
      pattern.match or 1
    )

    table.insert(self.running_jobs, {
      cmd = cmd,
      kind = pattern.kind or cmp.lsp.CompletionItemKind.Text,
      job_id = vim.fn.jobstart(cmd, {
        on_stderr = on_event,
        on_stdout = on_event,
        on_exit = on_event,
        cwd = request.option.cwd or vim.fn.getcwd(),
      })
    })
  end
end

source.filtered_patterns = function(request)
  local patterns = {}
  for _, pattern in ipairs(util.flatten(request.patterns) or {}) do
    if util.contains(pattern.filetype or {}, request.context.filetype) then
      table.insert(patterns, pattern)
    end
  end
  return patterns
end

source.build_cmd = function(regexp, match_index)
  local cmd = {
    "rg",
    "--only-matching",
    "--no-line-number",
    "--no-filename",
    "--smart-case",
    "--color never",
    vim.fn.shellescape(regexp) .. " --replace '$" .. match_index .."'",
    ".",
  }
  return table.concat(cmd, " ")
end

return source
