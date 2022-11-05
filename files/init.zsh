# vi mode
bindkey -v

# Completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' insert-tab pending

# GPG
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Fix partial lines
setopt PROMPT_CR
setopt PROMPT_SP

# macOS
if [[ `uname` == "Darwin" ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
