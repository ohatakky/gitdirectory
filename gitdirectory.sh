clear
list=($(git log --reverse | grep -e '^commit' | awk '{print $2}'))
prURL=https://github.com/$(git config --get remote.origin.url | sed -e 's/git@github.com://g' | sed -e 's/.git//g')/pulls?q=is%3Apr+hash%3A

idx=0
git checkout ${list[idx]} > /dev/null 2>&1 && tree -d
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
        continue
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
    git checkout ${list[idx]} > /dev/null 2>&1 && tree -d
done
