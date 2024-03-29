{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    globals.mapleader = " "; # Sets the leader key to space

    options = {
      clipboard = {
        providers.wl-copy.enable = true;
        register = "unnamedplus";
      };
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

    plugins = {
      barbecue.enable = true;
      copilot-vim.enable = true;
      gitsigns.enable = true;
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>lg" = "live_grep";
        };
      };
      indent-blankline.enable = true;
      nvim-colorizer.enable = true;
      nvim-autopairs.enable = true;
      nix.enable = true;
      comment.enable = true;
      lualine = {
        enable = true;
      };
      startup = {
        enable = true;
        theme = "dashboard";
      };
      lsp = {
        enable = true;
        servers = {
          lua-ls.enable = true;
          bashls.enable = true;
          dockerls.enable = true;
          java-language-server.enable = true;
          lemminx.enable = true;
          taplo.enable = true;
          yamlls.enable = true;
          nixd.enable = true;
          html.enable = true;
          ccls.enable = true;
          cmake.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          pyright.enable = true;
          tailwindcss.enable = true;
        };
      };

      lsp-lines.enable = true;
      treesitter = {
        enable = true;
        nixGrammars = true;
      };
      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
          };
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-toml
      vim-markdown
    ];

    # FOR NEOVIDE
    extraConfigLua = '' 
      vim.opt.guifont = "JetBrainsMono\\ NFM,Noto_Color_Emoji:h14"
      vim.g.neovide_cursor_animation_length = 0.05
      vim.g.neovide_cursor_vfx_mode = "railgun"
      vim.g.neovide_cursor_vfx_particle_lifetime = 0.15
      vim.g.neovide_cursor_vfx_particle_density = 15
      vim.g.neovide_cursor_vfx_particle_speed = 10
      vim.g.neovide_cursor_vfx_particle_phase = 0.04
      vim.g.neovide_cursor_vfx_line_enable = 1
    '';

    extraConfigVim = ''
      set noshowmode
      inoremap jj <ESC>
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>fb";
        action = ":Telescope file_browser<CR>";
        options.noremap = true;
      }
      {
        key = "<Tab>";
        action = ":bnext<CR>";
        options.silent = false;
      }
      {
        key = "<S-Tab>";
        action = ":bprev<CR>";
        options.silent = false;
      }
    ];
  };
} 
