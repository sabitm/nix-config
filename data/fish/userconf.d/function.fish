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
