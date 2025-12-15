-- LSP server configuration (using vim.lsp.config for Neovim 0.11+)
local lsp_servers = {
  'pyright',
  'nil_ls',
  'marksman',
  'rust_analyzer',
  'yamlls',
  'bashls',
  'java_language_server',
  'lemminx',
  'taplo',
  'html',
  'ccls',
  'jsonls',
}

-- Enable all configured LSP servers
vim.lsp.enable(lsp_servers)
