#{{ ansible_managed }}
# Pour les gros doigts
alias cD='cd'
alias cd..='cd ..'
alias -- -="cd .."
alias cd-='cd -'
alias grpe='grep'
alias gerp='grep'
alias mroe='more'
alias iv='vi'
alias tial='tail'
alias xs='cd'
alias vf='cd'
alias ..=' cd ..'
alias gti='git'
alias alais='alias'
alias gitrepos_update_all='~/bin/git-repos-update-all.sh'
alias gitrepos_update_all_fast="echo -e '\e[1m\e[31mUse gitrepos_update_all instead !\e[0m\n' && gitrepos_update_all"

alias ack='ack-grep'
alias tkillw='tmux kill-window -t $1'

alias gitbranchpurge='git fetch -p && git branch --merged | grep -v "\*" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d'

function clone_group { 
    TOKEN=${1};
    GROUP=${2};
    GROUP_ID=`http git.livingobjects.com/api/v3/groups?private_token=${TOKEN} | jq '.[] | select(.path=="'${GROUP}'") | .id'`;
    mkdir -p ${GROUP};
    cd ${GROUP};
    for PROJECT in `http --pretty format git.livingobjects.com/api/v3/groups/${GROUP_ID}?private_token=${TOKEN} | jq .projects | jq -r .[].ssh_url_to_repo`;
    do
        echo Cloning ${PROJECT};
        git clone ${PROJECT};
    done;
    cd -
}


function gitrepos_update_path {
    if [ -n "$(git --git-dir=${1} --work-tree=$(dirname ${1}) status --porcelain)" ]; then
       echo "* $(dirname ${1})" >> /tmp/gitrepos_update_report
    else
       echo "Updating repository $(dirname ${1})"
       git --git-dir=${1} --work-tree=$(dirname ${1}) pull
    fi
}
export -f gitrepos_update_path  &>/dev/null

function gitrepos_status_path {
   red="\033[0;31m"
   NC="\033[0m"
   dir="$(dirname $1)"
   changes=$(git --git-dir="$1" --work-tree=$dir status -s)

   if [ -n "$changes" ]
   then
     change_msg="[`echo $changes | wc -l` uncommitted file(s)]"
     dirty=1
   fi

   repo_gap=$(git --git-dir="$1" --work-tree=$dir rev-list --left-right @{u}...)

   if [ -n "$repo_gap" ]
   then
     ahead=`echo -e "$repo_gap" | grep '<' | wc -l`
     behind=`echo -e "$repo_gap" | grep '>' | wc -l`
     gap_msg="[need for synchronization ($ahead ahead - $behind behind)]"
     dirty=1
   fi

   if [ -n "$dirty" ]
   then
     echo -e "${red}(*)${NC} $dir $change_msg $gap_msg"
   else
     echo "$dir"
   fi
}

export -f gitrepos_status_path  &>/dev/null

function gitrepos_status_all {
   find -L ~/ -maxdepth 5 -path "*.git"  -type d  -exec bash -c 'gitrepos_status_path "{}"' \;
}

function tkillws {
    for i in $(eval echo {$1..$2});
    do
        echo "kill $i";
        tmux kill-window -t ${i};
    done
}

alias tkillserver='tmux kill-server'
function trespawnw {
    # the 2 Ctrl-C are there in case you are in edition mode, the first exit the edition mode and the second kill the running process
    tmux send-keys -t ${1} "C-c"
    tmux send-keys -t ${1} "C-c"
    retries=1
    until `tmux respawn-window -t ${1}`
    do
        echo "retrying"
        sleep 0.5
        retries=$(($retries + 1))
        if [ ${retries} -gt 5 ]
        then
            echo "we tried 5 times without apparent success"
            break
        fi
    done
    echo "done"
}

function trespawnws {
    for i in $(eval echo {$1..$2});
    do
        echo "respawn $i";
        trespawnw $i
    done
}
#{{ ansible_managed }}
