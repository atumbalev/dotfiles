return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    keys = {
      { "<leader>cP", "<cmd>RenderMarkdown preview<cr>", desc = "Markdown Preview (split)", ft = "markdown" },
    },
  },
  -- Don't run markdownlint on markdown files (too noisy for reading)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
  -- Hide remaining diagnostics (e.g. marksman) in markdown buffers
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          vim.diagnostic.enable(false, { bufnr = ev.buf })
        end,
      })
    end,
  },
  -- gx on a local PDF link like [p. 42](<book.pdf#page=42>) opens it in Skim at that page
  -- (the default gx passes the <> and #page to `open` literally; other links fall back to it)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    init = function()
      local skim_open = [[
on run argv
  tell application "Skim"
    activate
    set d to open POSIX file (item 1 of argv)
    go d to page ((item 2 of argv) as integer) of d
  end tell
end run]]

      local function open_pdf_link()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2] + 1
        for s, dest, e in line:gmatch("()%[[^%]]*%]%((.-)%)()") do
          if col >= s and col < e then
            dest = dest:gsub("^<(.*)>$", "%1")
            local file, page = dest:match("^(.-%.pdf)#page=(%d+)$")
            file = file or dest:match("^(.-%.pdf)$")
            if not file or file:match("^%a+://") then
              return false
            end
            file = file:gsub("%%20", " ")
            local path = file:sub(1, 1) == "/" and file or vim.fs.joinpath(vim.fn.expand("%:p:h"), file)
            path = vim.fs.normalize(path)
            if not vim.uv.fs_stat(path) then
              vim.notify("PDF not found: " .. path, vim.log.levels.WARN)
              return true
            end
            vim.system({ "osascript", "-e", skim_open, path, page or "1" }, {}, function(res)
              if res.code ~= 0 then
                vim.schedule(function()
                  vim.notify("Skim: " .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
                end)
              end
            end)
            return true
          end
        end
        return false
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          local default_gx = vim.fn.maparg("gx", "n", false, true)
          vim.keymap.set("n", "gx", function()
            if not open_pdf_link() and default_gx.callback then
              default_gx.callback()
            end
          end, { buffer = ev.buf, desc = "Open link (PDFs at page)" })
        end,
      })
    end,
  },
}
