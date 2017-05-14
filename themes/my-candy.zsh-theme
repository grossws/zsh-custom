if [ $EUID -eq 0 ] ; then
  PROMPT=$'%{$fg_bold[red]%}%n%{$fg_bold[yellow]%}@'
else
  PROMPT=$'%{$fg_bold[green]%}%n%{$fg_bold[yellow]%}@'
fi

if [ ! "x$SSH_CLIENT" = "x" ] ; then
  PROMPT=$'%{$fg_bold[magenta]%}[R]%{$reset_color%} '${PROMPT}$'%{$fg_bold[magenta]%}'
fi

PROMPT=${PROMPT}$'%m %{$fg[blue]%}%D{[%I:%M:%S]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info)\
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# vim: ft=zsh:sw=2:et:ts=2:
