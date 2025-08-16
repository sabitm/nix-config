status is-interactive || exit

# source all user-defined configs
set -l userconfd "$HOME/.config/fish/userconf.d"
if test -d $userconfd
    for file in $userconfd/*
        source $file
    end
end
