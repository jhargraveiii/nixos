{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    colorschemes.kanagawa.enable = true;
    globals.mapleader = " "; # Sets the leader key to space

    opts = {
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
      copilot-vim.enable = true;
      gitsigns.enable = true;
      toggleterm.enable = true;
      neo-tree.enable = true;
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
      lualine = { enable = true; };
      startup = {
        enable = true;
        theme = "auto";
      };
      lint = {
        enable = true;
        lintersByFt = {
          nix = [ "statix" ];
          bash = [ "shellcheck" ];
          text = [ "vale" ];
          json = [ "jsonfmt" ];
          toml = [ "taplo lint" ];
          markdown = [ "vale" ];
          lua = [ "luacheck" ];
          dockerfile = [ "hadolint" ];
          yaml = [ "yamllint" ];
          cpp = [ "cppcheck" ];
          proto = [ "protolint" ];
          python = [ "pylint" ];
          java = [ "checkstyle" ];
          git = [ "gitlint" ];
          make = [ "checkmake" ];
          c = [ "cppcheck" ];
          css = [ "stylelint" ];
          env = [ "dotenv-linter" ];
        };
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          julials.enable = true;
          lua-ls.enable = true;
          bashls.enable = true;
          java-language-server.enable = true;
          lemminx.enable = true;
          taplo.enable = true;
          yamlls.enable = true;
          html.enable = true;
          ccls.enable = true;
          jsonls.enable = true;
          pyright.enable = true;
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
          sources =
            [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];
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
      julia-vim
      denops-vim
      vim-pluto
      vim-dotenv
    ];

    extraConfigLua = ''
      vim.opt.guifont = "JetBrainsMono\\ NFM,Noto_Color_Emoji:h14"
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
