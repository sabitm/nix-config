# remove fish welcome greeting
set -g fish_greeting ""

# set nv as editor and less as pager
set -x EDITOR nv
set -x VISUAL nv
set -x PAGER less

# set default less options
set -x LESS '-g -i -M -R -S -w -z-4'
