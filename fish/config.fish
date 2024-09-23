function fish_greeting
    echo "
Wake up, $USER..."
end

begin
    eval (ssh-agent -c)
end &>/dev/null

alias ll "eza -l --icons --git"
alias clip "xclip -selection clipboard"
alias dock lazydocker

starship init fish | source
