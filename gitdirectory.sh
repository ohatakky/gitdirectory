
BAR="#"
MIN=1
MAX=100
progress_bar() {
    TIMES=$1
    COUNT=$2
    PROGRESS=$(echo | awk -v t=$TIMES -v c=$COUNT -v max=$MAX '{ print int(c / t * max) }')
    
    PROGRESS_BAR=""
    for _i in $(seq $MIN $PROGRESS); do PROGRESS_BAR="${PROGRESS_BAR}${BAR}"; done
    
    printf "\r[%-100s] %3d%%" $PROGRESS_BAR $PROGRESS
}
loading() {
    for i in $(seq 1 10); do
        progress_bar 10 $i
        sleep 0.5
    done
}

loading &
LOADING_PID=$!
trap "kill -9 $LOADING_PID" `seq 0 15`  > /dev/null 2>&1

repo=git@github.com:$1.git
git clone --filter=blob:none --no-checkout $repo > /dev/null 2>&1 && cd "$(echo $1 | sed -e 's/.*\///g')"

kill -9 $LOADING_PID > /dev/null 2>&1
clear

list=($(git log --reverse | grep -e '^commit' | awk '{print $2}'))
prURL=https://github.com/$(git config --get remote.origin.url | sed -e 's/git@github.com://g' | sed -e 's/.git//g')/pulls?q=is%3Apr+hash%3A

idx=0
git ls-tree -d -r ${list[idx]} | awk '{print $4}' | sed -e 's;[^/]*/; |__;g;s;__|; |;g'
while :
do
    read -p "h or l or [0-9]+ or -[0-9]+: " action
    if [ "$action" = "h" ]; then
        idx=$(( idx - 1 ))
        elif [ "$action" = "l" ]; then
        idx=$(( idx + 1 ))
        elif [[ "$action" =~ ^([0-9]+)$ ]]; then
        idx=$(( idx + action ))
        elif [[ "$action" =~ ^-([0-9]+)$ ]]; then
        idx=$(( idx - ${action:1} ))
    else
        break
    fi
    
    if [ $(($idx)) -lt 0 ]; then
        idx=0
        clear
        continue
        elif [ $(($idx)) -ge ${#list[@]} ]; then
        idx=$((${#list[@]}-1))
        clear
        continue
    fi
    
    clear
    echo commitID: ${list[idx]}
    echo PR: $prURL${list[idx]}
    git ls-tree -d -r ${list[idx]} | awk '{print $4}' | sed -e 's;[^/]*/; |__;g;s;__|; |;g'
done
