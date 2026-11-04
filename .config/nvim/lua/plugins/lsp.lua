-- Smart `gd`: on a usage -> jump to the definition.
-- Already on the definition -> list all usages (references) instead.
local function goto_definition_or_references()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local client = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" })[1]
  if not client then
    return vim.notify("No LSP with definition support attached", vim.log.levels.WARN)
  end
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

  vim.lsp.buf_request_all(buf, "textDocument/definition", params, function(results)
    local uri = vim.uri_from_bufnr(buf)
    local on_definition = false
    for _, res in pairs(results or {}) do
      local locs = res.result or {}
      if locs.uri or locs.targetUri then
        locs = { locs }
      end
      for _, loc in ipairs(locs) do
        local luri = loc.uri or loc.targetUri
        local range = loc.targetSelectionRange or loc.range or loc.targetRange
        if luri == uri and range and range.start.line <= row and range["end"].line >= row then
          local s = range.start.line == row and range.start.character or 0
          local e = range["end"].line == row and range["end"].character or math.huge
          if col >= s and col <= e then
            on_definition = true
          end
        end
      end
    end
    vim.schedule(function()
      if on_definition then
        require("telescope.builtin").lsp_references({ include_declaration = false })
      else
        require("telescope.builtin").lsp_definitions({ reuse_win = true })
      end
    end)
  end)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gd", goto_definition_or_references, desc = "Goto Definition / Usages", has = "definition" },
          },
        },
      },
    },
  },
}
