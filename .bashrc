# https://github.com/rupa/z
. ~/z.sh
# Shell prompt
function _update_ps1() {
    if [ -f ~/prompt.sh ]
    then
        # Add prompt information on the right side, keep left side prompt simple.
        # prompt.sh should export the string for the right side prompt as $RIGHTPROMPT
        source ~/prompt.sh
        BASHCOLUMNS=${#RIGHTPROMPT}    # get string length of RIGHTPROMPT so we can align
        PS1="🐚  \[\033[s\033[$((${COLUMNS}-${BASHCOLUMNS}-4))C${RIGHTPROMPT}\033[u\]"
    else
        PS1="\W$ "
    fi
}
export PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"

export NVM_DIR="/Users/brodeb/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Tern for vim
export no_proxy=localhost

CCL_DEFAULT_DIRECTORY=/Users/benbp/open_source_repos/clozure/ccl

# Fixes "RE error: illegal byte sequence" for sed search/replace on osx
# http://stackoverflow.com/questions/19242275/re-error-illegal-byte-sequence-on-mac-os-x
export LC_CTYPE=C 
export LANG=C

set -o vi

alias c="clear"
alias e="echo"
alias cb="cd -"
alias la="ls -alh"

alias ic="ifconfig"
alias sic="sudo ifconfig"

alias gs="git status"
alias ga="git add"
alias gap="git add -p"
alias gau="git add -u"
alias gm="git commit -m "
alias gam="git add -u; git commit -m"
alias grr="git add -u; git commit --amend"
alias gd="git diff --color"
alias gdc="git diff --color -U0"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit -n10"
alias glg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
alias gpo="git push origin"
alias gpl="git fetch --all --prune; git pull --rebase"
alias gf="git fetch --all --prune"
alias gre="git remote"
alias grei="git rebase -i"
alias grb2="git rebase -i HEAD~2"
alias grb3="git rebase -i HEAD~3"
alias grb5="git rebase -i HEAD~5"
alias gba="git branch -a"
alias gcp="git cherry-pick"
alias gst="git stash"
alias gstp="git stash pop"
alias ggrep="git grep -i --color --break --heading --line-number"

alias fgrep="find . | grep"
alias sfgrep="sudo find . | grep"

alias vbm="VBoxManage"

alias dl="diskutil list"
alias tmp="mkdir /tmp/test;cd /tmp/test"

alias sni="sudo node index.js"
alias snid="sudo node debug index.js"
alias ni="node index.js"
alias nid="node debug index.js"
alias nr="cd ~/.noderepl;node ~/.noderepl/repl.js;cd -"

alias nd="node debug"
alias n="node"
alias m="mocha"
alias viewcover="./node_modules/.bin/istanbul report html; open coverage/index.html"

alias d="docker"

# quick aliasing for repetitive, but throwaway, tasks
function a() {
    alias $1="${*:2}"
    echo "Set up alias $1=\"${*:2}\""
}

function mt() {
    mocha $(find spec -name '*-spec.js')
}

function smt() {
    sudo mocha $(find spec -name '*-spec.js')
}

function mtd() {
    mocha debug $(find spec -name '*-spec.js')
}

function smtd() {
    sudo mocha debug $(find spec -name '*-spec.js')
}

alias rh="runhaskell"

# Remove vim swap files
alias rmswap="find . -name '*sw[m-p]'|xargs rm"

alias goog="ping 8.8.8.8"

function mkcd() {
    mkdir $1
    cd $1
}

function vmode() {
    if [[ "$1" == "on" ]];
    then
        set -o vi
    else
        set +o vi
    fi
}

function cu() {
    if [[ -z "$1" ]];
    then
        cd ..
    else
        for ((i=1; i<=$1;i++))
        do
            cd ..
        done
    fi
}

function md() {
    if [[ -z "$2" ]];
    then
        mdfind "$1"
    else
        mdfind "$1" -onlyin "$2"
    fi
}

function gld() {
    branch=`git branch | awk '/\*/ {print $2;}'`
    # glg is an alias defined above
    glg master..$branch
}

function gp() {
    branch=`git branch | awk '/\*/ {print $2;}'`
    if [[ -z "$1" ]];
    then
        if [[ "$branch" = "master" ]];
        then
            echo "You almost pushed to master!"
            echo "ABORTED: tried to push to master!"
            return
        fi
        git push origin $branch 2>&1 | captureStashPullRequestUrl
    else
        if [[ "$1" = "-f" ]];
        then
            if [[ "$branch" = "master" ]];
            then
                echo "You almost force pushed to master!"
                echo "ABORTED: tried to force push to master!"
            else
                echo "Are you sure you want to force push to $branch?"
                read -p "(yes/no): " confirm
                if [[ "$confirm" = "yes" ]];
                then
                    git push origin $branch --force 2>&1 | captureStashPullRequestUrl
                else
                    echo "Canceled"
                fi
            fi
        else
            git push origin $branch $1 2>&1 | captureStashPullRequestUrl
        fi
    fi
}

function gamp() {
    branch=`git branch | awk '/\*/ {print $2;}'`
    if [[ "$branch" = "master" ]];
    then
        echo "ABORTED: tried push to master"
    else
        git add -u; git commit -m "$1"; git push origin $branch 2>&1 | captureStashPullRequestUrl
    fi
}

function gsh() {
    if [[ -z "$1" ]];
    then
        sha=`git rev-parse HEAD`
    else
        sha=`git rev-parse HEAD~$1`
    fi
    git show $sha
}

function gitcl() {
    git clone git@github.com:$1
}

# Atlassian stash prints out a pull request URL when you git push, capture
# that to a temp file so we can open that URL with a shortcut
function captureStashPullRequestUrl() {
    pwd=`pwd`
    tee /tmp/`basename $pwd`
}

# Open the most recent atlassian stash pr associated with the current directory
function openpr() {
    pwd=`pwd`
    base=`basename $pwd`
    loc=/tmp/$base
    if [ -e $loc ] && [ -s $loc ];
    then
        url=`cat $loc | grep http | awk '{print $2}'`
        if [ -z "$url" ];
        then
            echo "Could not find a pull request URL for $base"
        else
            open $url
        fi
    else
        echo "Could not find a pull request URL for $base"
    fi
}

alias brc="vi ~/dotfiles/.bashrc; cp ~/dotfiles/.bashrc ~;source ~/.bashrc"
alias bri="vi ~/dotfiles/.inputrc; cp ~/dotfiles/.inputrc ~; bind -f ~/.inputrc"
alias brcp="vi ~/.bashrc.private; source ~/.bashrc"

alias ple="pylint -E"
function plw { pylint "$1" | grep W: ; }
function plc { pylint "$1" | grep C: ; }
export -f plw
export -f plc


verbose_commands=0

function cd_and_ls() {
    cd $1
    ls
}

function vv() {
    let verbose_commands=($verbose_commands+1)%2
    if [ $verbose_commands -eq 1 ]; then
        echo "verbose commands on"
        alias cd="cd_and_ls"
        alias ls="ls -lah"
    else
        echo "verbose commands off"
        unalias cd
        unalias ls
    fi
}

alias scf="vi ~/.ssh/config"
alias skr="ssh-keygen -R"
alias edithosts="sudo vi /etc/hosts"

# borrowed from
# http://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

 if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
    start_agent;
fi
###

if [ -e ~/.bashrc.private ]
then
    source ~/.bashrc.private
fi
