# remove fish welcome greeting
set -g fish_greeting ""

# set nvim as editor and less as pager
set -x EDITOR nvim
set -x VISUAL nvim
set -x PAGER less

# set default less options
set -x LESS '-g -i -M -R -S -w -z-4'
