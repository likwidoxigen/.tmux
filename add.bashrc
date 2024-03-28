alias tmexit='rm ~/.closebash && exit'
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [ -z "$TERM_PROGRAM" ]; then
            # exec tmux  #will always close terminal on a detach
            #tmux  #will exit to bash prompt
        tmux #alternate way to close base shell on exit
        #Just set a session variable rather than write a file ya dummy
        if [ ! -f ~/.closebash ]; then
            echo "Remaining In terminal"
            echo "close" > ~/.closebash 
        else
            exit
        fi
fi

GIT_BRANCH_SYMBOL='⌥'
# Taken from http://aaroncrane.co.uk/2009/03/git_branch_prompt/
READLINK='readlink -e'
find_git_repo() {
    local dir=.
    if [[ "$TERM" != screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        echo "WE ARE HERE"
        return
    fi
    GIT_REPO_OLD_PATH=$GIT_REPO_PATH
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            GIT_REPO_PATH=`$READLINK $dir`/
            if [ "$GIT_REPO_OLD_PATH" = "$GIT_REPO_PATH" ]; then
            	#echo "same path"
            	return;
            fi
            GIT_REPO_NAME=`basename -s "/" "$GIT_REPO_PATH"`
            find_git_branch "$GIT_REPO_PATH"
            export TMUX_GIT_INFO="$GIT_REPO_NAME$GIT_BRANCH_SYMBOL$GIT_BRANCH"
	    export TMUX_GIT_REPO_NAME="$GIT_REPO_NAME"
	    export TMUX_GIT_REPO_BRANCH="$GIT_BRANCH"
	    export TMUX_GIT_BRANCH_SYMBOL="$GIT_BRANCH_SYMBOL"
            #echo "$TMUX_GIT_INFO"
            tmux setenv TMUX_GIT_REPO "$TMUX_GIT_INFO"
	    tmux setenv TMUX_GIT_REPO_NAME "$TMUX_GIT_REPO_NAME"
	    tmux setenv TMUX_GIT_REPO_BRANCH "$TMUX_GIT_REPO_BRANCH"
	    tmux setenv TMUX_GIT_BRANCH_SYMBOL "$TMUX_GIT_BRANCH_SYMBOL"
            return
        fi
        dir="../$dir"
    done
    GIT_REPO_PATH=''
    GIT_REPO_NAME=''
    GIT_BRANCH=''
    tmux setenv TMUX_GIT_REPO ""
    tmux setenv TMUX_GIT_REPO_NAME ""
    tmux setenv TMUX_GIT_REPO_BRANCH ""
    tmux setenv TMUX_GIT_BRANCH_SYMBOL ""
    return
}

find_git_branch() {
    head=$(< "$1.git/HEAD")
    if [[ $head == ref:\ refs/heads/* ]]; then
        GIT_BRANCH=${head#*/*/}
    elif [[ $head != '' ]]; then
        GIT_BRANCH='(detached)'
    else
        GIT_BRANCH='(unknown)'
    fi
}

# Taken from https://github.com/jimeh/git-aware-prompt
find_git_dirty() {
  local status=$(git status --porcelain 2> /dev/null)
  if [[ "$status" != "" ]]; then
    GIT_DIRTY='*'
  else
    GIT_DIRTY=''
  fi
}

find_git_stash() {
    if [ -e "$1/.git/refs/stash" ]; then
        GIT_STASH='stash'
    else
        GIT_STASH=''
    fi
}

grey='\[\033[1;30m\]'
red='\[\033[0;31m\]'
RED='\[\033[1;31m\]'
green='\[\033[0;32m\]'
GREEN='\[\033[1;32m\]'
yellow='\[\033[0;33m\]'
YELLOW='\[\033[1;33m\]'
purple='\[\033[0;35m\]'
PURPLE='\[\033[1;35m\]'
white='\[\033[0;37m\]'
WHITE='\[\033[1;37m\]'
blue='\[\033[0;34m\]'
BLUE='\[\033[1;34m\]'
cyan='\[\033[0;36m\]'
CYAN='\[\033[1;36m\]'
NC='\[\033[0m\]'



PS1="$GREEN\u$WHITE:$BLUE\w$ $NC"
if [[ "$TERM" != screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    PROMPT_COMMAND="$PROMPT_COMMAND"
else
    PROMPT_COMMAND="find_git_repo; $PROMPT_COMMAND"
fi