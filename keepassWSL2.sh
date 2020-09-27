export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock

sshpid=$(ss -ap | grep "$SSH_AUTH_SOCK")
if [ "$1" = "-k" ] || [ "$1" = "-r" ]; then
    sshpid=${sshpid//*pid=/}
    sshpid=${sshpid%%,*}
    if [ -n "${sshpid}" ]; then
        kill "${sshpid}"
    else
        echo "'socat' not found"
    fi
    if [ "$1" = "-k" ]; then
        exit
    fi
    unset sshpid
fi

if [ -z "${sshpid}" ]; then
    rm -f $SSH_AUTH_SOCK
    ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"/mnt/c/Users/r2/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >/dev/null 2>&1
fi