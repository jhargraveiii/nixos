{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      lua-language-server
      gopls
      xclip
      wl-clipboard
      luajitPackages.lua-lsp
      nil
      # Broken:rust-analyzer
      nodePackages.bash-language-server
      yaml-language-server
      pyright
      marksman
      java-language-server
      lemminx
      taplo
      ccls
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
      nodePackages.vscode-json-languageserver
    ];
    plugins = with pkgs.vimPlugins; [
      copilot-vim
      alpha-nvim
      auto-session
      bufferline-nvim
      dressing-nvim
      indent-blankline-nvim
      nui-nvim
      nvim-treesitter.withAllGrammars
      # lualine-nvim
      nvim-autopairs
      nvim-web-devicons
      nvim-cmp
      nvim-surround
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      luasnip
      cmp_luasnip
      friendly-snippets
      lspkind-nvim
      comment-nvim
      nvim-ts-context-commentstring
      plenary-nvim
      neodev-nvim
      luasnip
      telescope-nvim
      todo-comments-nvim
      nvim-tree-lua
      telescope-fzf-native-nvim
      vim-tmux-navigator
      plenary-nvim
      neodev-nvim
      luasnip
      telescope-nvim
      todo-comments-nvim
      nvim-tree-lua
      telescope-fzf-native-nvim
      vim-tmux-navigator
    ];
    extraConfig = ''
      set noemoji
    '';
    extraLuaConfig = ''
      ${builtins.readFile ../../config/nvim/options.lua}
      ${builtins.readFile ../../config/nvim/keymaps.lua}
      ${builtins.readFile ../../config/nvim/plugins/alpha.lua}
      ${builtins.readFile ../../config/nvim/plugins/autopairs.lua}
      ${builtins.readFile ../../config/nvim/plugins/auto-session.lua}
      ${builtins.readFile ../../config/nvim/plugins/comment.lua}
      ${builtins.readFile ../../config/nvim/plugins/cmp.lua}
      ${builtins.readFile ../../config/nvim/plugins/lsp.lua}
      ${builtins.readFile ../../config/nvim/plugins/nvim-tree.lua}
      ${builtins.readFile ../../config/nvim/plugins/telescope.lua}
      ${builtins.readFile ../../config/nvim/plugins/todo-comments.lua}
      ${builtins.readFile ../../config/nvim/plugins/treesitter.lua}

      require("ibl").setup()
      require("bufferline").setup{}
      -- require("lualine").setup({
      --   icons_enabled = true,
      --   theme = 'dracula',
      -- })
    '';
  };
}
