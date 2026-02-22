# remove fish welcome greeting
set -g fish_greeting ""

# set vim as editor and less as pager
set -x EDITOR vim
set -x VISUAL vim
set -x PAGER less

# set default less options
set -x LESS '-g -i -M -R -S -w -z-4'
