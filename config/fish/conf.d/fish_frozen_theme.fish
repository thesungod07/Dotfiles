# This file was created by fish when upgrading to version 4.3, to migrate
# theme variables from universal to global scope.
# Don't edit this file, as it will be written by the web-config tool (`fish_config`).
# To customize your theme, delete this file and see
#     help interactive#syntax-highlighting
# or
#     man fish-interactive | less +/^SYNTAX.HIGHLIGHTING
# for appropriate commands to add to ~/.config/fish/config.fish instead.
# See also the release notes for fish 4.3.0 (run `help relnotes`).

# Patched for black/red terminal with darker command colors only (truecolor, not palette)
# Logo/everything stays black/red (kitty #120707), commands use darker varied hex
set --global fish_color_autosuggestion 6a5656 brblack
set --global fish_color_cancel -r
set --global fish_color_command 4e9a06 --bold
set --global fish_color_comment 6a5656
set --global fish_color_cwd 4e9a06
set --global fish_color_cwd_root 7d0e0f
set --global fish_color_end 4e9a06
set --global fish_color_error 7d0e0f --bold
set --global fish_color_escape 06989a
set --global fish_color_history_current --bold
set --global fish_color_host normal
set --global fish_color_host_remote 3465a4
set --global fish_color_normal c3c1c1
set --global fish_color_operator 06989a
set --global fish_color_param 06989a
set --global fish_color_quote c4a000
set --global fish_color_redirection 06989a --bold
set --global fish_color_search_match --background=6a5656
set --global fish_color_selection c3c1c1 --bold --background=6a5656
set --global fish_color_status 7d0e0f
set --global fish_color_user 4e9a06 --bold
set --global fish_color_valid_path --underline
set --global fish_pager_color_completion c3c1c1
set --global fish_pager_color_description 968c8c
set --global fish_pager_color_prefix 06989a --bold --underline
set --global fish_pager_color_progress c3c1c1 --background=6a5656
set --global fish_pager_color_selected_background --background=6a5656 --reverse
