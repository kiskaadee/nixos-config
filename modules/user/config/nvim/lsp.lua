local lspconfig = require('lspconfig')

-- Python LSP: Pyright (Type checking and navigation)
lspconfig.pyright.setup{}

-- Python LSP: Ruff (Ultra-fast Linting and Auto-formatting)
lspconfig.ruff.setup{
  on_attach = function(client, bufnr)
    -- Disable hover provider in Ruff so it doesn't conflict with Pyright
    client.server_capabilities.hoverProvider = false
  end,
}

-- Configure LSP Keybindings on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    
    -- Standard navigation & actions
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

    -- Auto-format on save using Ruff / LSP
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = ev.buf,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})
