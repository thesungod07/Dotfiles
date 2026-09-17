# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors - terminal palette is black/red (#120707) but keep sequences for background
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end
    # Override fish syntax to darker varied (truecolor) - only commands change colors, rest stays black/red
    set -g fish_color_command 4e9a06 --bold
    set -g fish_color_param 06989a
    set -g fish_color_quote c4a000
    set -g fish_color_error 7d0e0f --bold
    set -g fish_color_operator 06989a
    set -g fish_color_redirection 06989a --bold
    set -g fish_color_end 4e9a06
    set -g fish_color_cwd 4e9a06
    set -g fish_color_autosuggestion 6a5656

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end


# Added by Antigravity CLI installer
set -gx PATH "/home/apollo/.local/bin" $PATH
