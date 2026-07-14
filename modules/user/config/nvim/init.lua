vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers for easier navigation jumps
vim.opt.shiftwidth = 2         -- 2-space indents
vim.opt.tabstop = 2            -- Tab spacing
vim.opt.expandtab = true       -- Convert tabs to spaces
vim.opt.smartindent = true     -- Intelligent auto-indenting based on file syntax
vim.opt.wrap = false           -- Disable automatic line wrapping
vim.opt.termguicolors = true   -- Enable 24-bit RGB terminal colors
vim.opt.completeopt = { "menu", "menuone", "noinsert" } -- Smooth auto-completion behavior

-- Accept completion with Tab when the completion menu is visible
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>'
  else
    return '<Tab>'
  end
end, { expr = true, silent = true })

