-- Python LSP: Pyright (Type checking and navigation)
vim.lsp.config('pyright', {})
vim.lsp.enable('pyright')

-- Python LSP: Ruff (Ultra-fast Linting and Auto-formatting)
vim.lsp.config('ruff', {
  on_attach = function(client, bufnr)
    -- Disable hover provider in Ruff so it doesn't conflict with Pyright
    client.server_capabilities.hoverProvider = false
  end,
})
vim.lsp.enable('ruff')

-- Rust LSP: Rust Analyzer
vim.lsp.config('rust_analyzer', {})
vim.lsp.enable('rust_analyzer')

-- Nix LSP: nixd (Nix Language Server)
vim.lsp.config('nixd', {})
vim.lsp.enable('nixd')

-- TypeScript LSP: ts_ls
vim.lsp.config('ts_ls', {})
vim.lsp.enable('ts_ls')

-- Lua LSP: lua_ls
vim.lsp.config('lua_ls', {})
vim.lsp.enable('lua_ls')

-- TOML LSP: taplo
vim.lsp.config('taplo', {})
vim.lsp.enable('taplo')

-- Markdown LSP: marksman
vim.lsp.config('marksman', {})
vim.lsp.enable('marksman')

-- Configure LSP Keybindings and features on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    
    -- Standard navigation & actions
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

    -- Enable built-in LSP completion (Neovim 0.11+)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- Auto-format on save using Ruff / LSP
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = ev.buf,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})
