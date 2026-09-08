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

function __urlencode --argument-names str --description "Percent-encode a path (keeps / and unreserved chars)"
  set -l out ""
  for b in (printf '%s' $str | od -An -v -tx1 | string split -n ' ')
    # first hex digit 0-7 means an ASCII byte we can safely test as a char
    if string match -qr '^[0-7]' -- $b
      set -l ch (printf "\x$b")
      if string match -qr '^[A-Za-z0-9._~/-]$' -- $ch
        set out "$out$ch"
        continue
      end
    end
    set out "$out%"(string upper $b)
  end
  printf '%s' $out
end

function __urldecode --argument-names str --description "Percent-decode a URI path"
  # assumes well-formed input: every % is part of a %HH escape
  printf '%b' (string replace -a '%' '\x' -- $str)
end

function cpclip --description "Copy file objects to the clipboard for Wayland"
  if test (count $argv) -eq 0
    echo "Error: Please specify at least one file path."
    return 1
  end

  set -l uris

  for file in $argv
    if test -e $file
      # Percent-encode so other apps and pasteclip round-trip correctly
      set -a uris "file://"(__urlencode (realpath $file))
    else
      echo "Warning: File '$file' does not exist. Skipping."
    end
  end

  if test (count $uris) -eq 0
    echo "Error: No valid files were found to copy."
    return 1
  end

  string join \n $uris | wl-copy -t text/uri-list

  echo "Copied "(count $uris)" file(s) to clipboard as file objects."
end

function pasteclip --description "Paste file objects from the Wayland clipboard to the current directory"
  if not wl-paste --list-types | string match -q "text/uri-list"
    echo "Error: No file objects found in the clipboard."
    return 1
  end

  set -l uris (wl-paste -t text/uri-list | string replace -r '\r$' '' | string match -r '^file://.*')
  if test (count $uris) -eq 0
    echo "Error: Clipboard contains URIs, but no local file paths."
    return 1
  end

  set -l pasted_count 0

  for uri in $uris
    set -l source_path (__urldecode (string sub -s 8 $uri))

    if not test -e $source_path
      echo "Warning: Source file '$source_path' no longer exists."
      continue
    end

    # Resolve naming collisions
    set -l base (basename $source_path)
    set -l dest $base

    if test -d $source_path
      # For directories
      set -l counter 1
      while test -e $dest
        set dest "$base"_"$counter"
        set counter (math $counter + 1)
      end
    else
      # For files, preserve the extension (e.g., file.txt -> file_1.txt)
      set -l ext (string match -r '\.[^.]+$' $base)
      set -l name_without_ext (string replace -r '\.[^.]+$' '' $base)
      set -l counter 1
      while test -e $dest
        set dest "$name_without_ext"_"$counter""$ext"
        set counter (math $counter + 1)
      end
    end

    cp -r $source_path ./$dest
    echo "Pasted: $dest"
    set pasted_count (math $pasted_count + 1)
  end

  echo "Successfully pasted $pasted_count file(s)."
end

function mvclip --description "Move (Cut/Paste) file objects from the Wayland clipboard to the current directory"
  if not wl-paste --list-types | string match -q "text/uri-list"
    echo "Error: No file objects found in the clipboard."
    return 1
  end

  set -l uris (wl-paste -t text/uri-list | string replace -r '\r$' '' | string match -r '^file://.*')
  if test (count $uris) -eq 0
    echo "Error: Clipboard contains URIs, but no local file paths."
    return 1
  end

  set -l moved_count 0

  for uri in $uris
    set -l source_path (__urldecode (string sub -s 8 $uri))

    if not test -e $source_path
      echo "Warning: Source file '$source_path' no longer exists."
      continue
    end

    # Resolve naming collisions
    set -l base (basename $source_path)
    set -l dest $base

    if test -d $source_path
      set -l counter 1
      while test -e $dest
        set dest "$base"_"$counter"
        set counter (math $counter + 1)
      end
    else
      set -l ext (string match -r '\.[^.]+$' $base)
      set -l name_without_ext (string replace -r '\.[^.]+$' '' $base)
      set -l counter 1
      while test -e $dest
        set dest "$name_without_ext"_"$counter""$ext"
        set counter (math $counter + 1)
      end
    end

    mv $source_path ./$dest
    echo "Moved: $dest"
    set moved_count (math $moved_count + 1)
  end

  echo "Successfully moved $moved_count file(s)."
end
