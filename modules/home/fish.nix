{ config, pkgs, ... }:
let
  general = ''
    # remove fish welcome greeting
    set -g fish_greeting ""

    # set helix as editor and less as pager
    set -x EDITOR nvim
    set -x VISUAL nvim
    set -x PAGER less

    # set default less options
    set -x LESS '-g -i -M -R -S -w -z-4'
  '';

  hydro = ''
    # prompt color set
    set -g hydro_color_git yellow
    set -g hydro_color_prompt brblack
    set -g hydro_color_pwd cyan
  '';

  aliases = ''
    # misc
    alias ae='aerc'
    alias aider='aider --no-git'
    alias aidera='aider --no-git --architect'
    alias justd='just --working-directory . --justfile ~/Downloads/Justfile'
    alias rgx='rg -n -U --pcre2'
    alias tslen='gtranslate -s en -t id'
    alias tslid='gtranslate -s id -t en'
    alias yv='youtube-viewer'
    alias yva='youtube-viewer -a'

    # git related
    alias g.='lazygit'
    alias ga='git add'
    alias gb='git branch'
    alias gc='git commit'
    alias gcm='git commit -m'
    alias gco='git checkout'
    alias gd='git diff'
    alias gdf='git diff --no-index'
    alias gl='git log'
    alias gp='git pull'
    alias gps='git push'
    alias grb='git rebase'
    alias grbi='git rebase -i'
    alias gs='git status'

    # dir and files
    alias dua='dua -A'
    alias l='ls -lAtrh'
    alias la='ls -A'
    alias ll='ls -ltrh'
    alias lsp='find "$PWD" -maxdepth 1'
  '';

  functions = ''
    function take -d "create a directory and cd into it"
      mkdir $argv && cd $argv
    end

    function psc -d "ps sort by cpu"
      tput rmam
      ps -eo %cpu,pid,command | sort -k1 -n
      tput smam
    end

    function psm -d "ps sort by mem"
      tput rmam
      ps -eo rss,pid,command | sort -k1 -n
      tput smam
    end

    function y -d "yazi with change cwd on exit and set origin"
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      set -x ORIGIN "$PWD"
      yazi $argv --cwd-file="$tmp"
      if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
      end
      rm -f -- "$tmp"
    end
  '';
in 
{
  # Enable fish
  programs.fish = {
    enable = true;
    plugins = [
      { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
    ];
    binds = {
      "alt-space".command = "forward-char";
      "alt-comma".command = [ "backward-kill-bigword" "yank" "yank"];
      "alt-enter".command = [ "accept-autosuggestion" "execute" ];
    };
    interactiveShellInit = general + hydro + aliases + functions;
  };
}
