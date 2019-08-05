# Minimal zsh theme

# Options
num_dirs=2  # Use 0 for full path

# failure colours
local return_status="%(?:%F{black}:%F{red})%f"
background_jobs="%(?:%F{black}:%F{green})%f"
truncated_path="%F{white}%$num_dirs~%f"
decoration="%F{blue}${return_status}${background_jobs}"


# git things
ZSH_THEME_GIT_PROMPT_PREFIX="%F{grey} ["
ZSH_THEME_GIT_PROMPT_SUFFIX="] %f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}%f"


# Left part of prompt
PROMPT='$truncated_path $decoration$(git_prompt_info) '
# Right part of prompt
RPROMPT=''
# Input in bold
# zle_highlight=(default:bold)
