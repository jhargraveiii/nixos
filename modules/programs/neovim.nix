{ config, inputs, theme, pkgs, ... }:

let
  plugins = pkgs.unstable.vimPlugins;
in
{
  programs.nixvim = {
    enable = true;
    plugins = {
      telescope.enable = true;
      neo-tree.enable = true;
      indent-blankline.enable = true;
      lualine = {
        enable = true;
        theme = "auto";
      };

      comment-nvim.enable = true;
      lsp = {
        enable = true;
        servers = {
          tsserver.enable = true;
          lua-ls.enable = true;
          nixd.enable = true;
          html.enable = true;
          ccls.enable = true;
          cmake.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          pyright.enable = true;
          tailwindcss.enable = true;
          #dockerls.enable = true;
          java-language-server.enable = true;
          #lemminx.enable = true;
          taplo.enable = true;
          yamlls.enable = true;
        };
      };
      treesitter.enable = true;
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''cmp.mapping.select_next_item()'';
            modes = [ "i" "s" ];
          };
        };
      };
    };

    extraPlugins = [
      plugins.vim-airline-themes
      plugins.base16-nvim
    ];

    globals.mapleader = " "; # Sets the leader key to space

    extraConfigLua = ''
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>s', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end)
    '';

    extraConfigVim = ''
      set noshowmode
      colorscheme base16-${theme}
      inoremap jj <ESC>
      let s:guifontsize = 16
      let s:guifont = "JetBrainsMono\\ Nerd\\ Font"
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>tf";
        options.silent = false;
        action = "<cmd>Ex<CR>";
      }
      {
        mode = "n";
        key = "<leader>fb";
        options.silent = false;
        action = "<cmd>Neotree reveal right<CR>";
      }
    ];

    options = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
      softtabstop = 2;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      updatetime = 50;
    };

  };
} 