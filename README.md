# KeepassWSL2

ReadMe Picked from https://gist.github.com/strarsis/e533f4bca5ae158481bbe53185848d49

 
# Installation/setup
1. Install the [KeeAgent plugin](https://github.com/dlech/KeeAgent) for [KeePass (_2.x_)](https://keepass.info/download.html).
2. The `OpenSSH Authentication Agent` Windows service must be stopped. For being sure that it stays stopped, even after rebooting, disable the service (when it is stopped).
3. Open the KeeAgent options via KeePass Menu -> Tools -> Options -> KeeAgent Tab. 
Enable the option `Enable agent for Windows OpenSSH (experimental)`
A possible error message `Windows OpenSSH agent is already running. KeeAgent cannot listen for Windows OpenSSH requests.` can be ignored, everything will still work fine.
No socket files need to be created, the options can be left disabled.
4. Place the `npiperelay.exe` under `/usr/local/bin/npiperelay.exe` inside your WSL 2 installation.
It must be on the devfs filesystem, see https://github.com/rupor-github/wsl-ssh-agent#wsl-2-compatibility.
5. Add the following shell code to your `.zshrc` (`~/.zshrc`):
```bash
# KeeAgent
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
    ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >/dev/null 2>&1
fi
````
Tip: Reload .zshrc config in current bash session:
````
$ source ~/.zshrc
````
6. Necessary step (thanks @jacobblock): `socat` must also be installed.
`sudo apt install socat`, 
source your zshrc again to start the pipe again npiperelay: 
`source ~/.zshrc`.
7. You can check the key agent functionality by either connecting via SSH or listing the keys with `ssh-add -l` (thanks @jacobblock).
KeePass should automatically show the authentication prompt and/or notify that SSH keys have been accessed.
Note: The KeePass program must be running when KeeAgent should be used. Turning on KeePass autostart could be a good idea.