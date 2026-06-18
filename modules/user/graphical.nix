{ inputs, pkgs, ...}:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    zed-editor
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;

    ## Core settings
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.termguicolors = true
      
      -- Apply colorscheme after plugins load
      vim.cmd("colorscheme catppuccin-mocha")
    '';

    ## Declarative Plugin Management
    plugins = with pkgs.vimPlugins; [
      # Color scheme
      catppuccin-nvim 

      # Advanced Syntax Highlighting for Python, Rust and Nix
      {
	plugin = nvim-treesitter.withPlugins (p: with p; [
	  python
	  rust
	  nix
	  lua
	  java
	  javascript
	  markdown
	]);
	type = "lua";
	config = ''
	  require('nvim-treesitter.configs').setup({
	    highlight = {enable = true },
	  })
	'';
      }
    ];
  };
}

