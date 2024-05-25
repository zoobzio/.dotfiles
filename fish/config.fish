# list folder contents
if type -q eza
  alias ll "eza -l -g --icons"
end

# size of directory
alias sizeof "du -hs"

# pnpm
set -gx PNPM_HOME "/Users/alex.thorwaldson/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
