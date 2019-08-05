# Minimal zsh theme

# Options
num_dirs=2  # Use 0 for full path


# failure colours
local return_status="%(?:%F{black}:%F{red})"
local background_jobs="%(?:%F{black}:%F{green})"
local truncated_path="%F{white}%$num_dirs~%f"


# git things
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}"


decoration="%F{blue}${return_status}${background_jobs}$(git_prompt_info)"


# Left part of prompt
PROMPT='$truncated_path $decoration '
# Right part of prompt
RPROMPT=''
# Input in bold
# zle_highlight=(default:bold)
