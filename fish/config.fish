function fish_greeting
    echo "
Wake up, $USER..."
end

# SSH agent setup - reuse existing or start new
if test -z "$SSH_AUTH_SOCK"
    # Check for existing agent
    set -l SSH_AGENT_FILE ~/.ssh/ssh-agent-info
    if test -f $SSH_AGENT_FILE
        source $SSH_AGENT_FILE >/dev/null
        # Test if agent is still running
        ssh-add -l &>/dev/null
        if test $status -ne 0
            # Agent not running, start new one
            eval (ssh-agent -c | tee $SSH_AGENT_FILE)
        end
    else
        # No agent file, start new one
        eval (ssh-agent -c | tee $SSH_AGENT_FILE)
    end
end

alias ll "eza -l --icons --git"
alias clip "xclip -selection clipboard"
alias dock lazydocker
# alias kevin "ollama run kevin"  # Disabled for Kevin CLI

set -gx BROWSER google-chrome-stable

starship init fish | source

# set -gx GOPATH $HOME/go; set -gx GOROOT $HOME/.go; set -gx PATH $GOPATH/bin $PATH; # g-install: do NOT edit, see https://github.com/stefanmaric/g
