clear
list=($(git log --reverse | grep -e '^commit' | awk '{print $2}'))

idx=0
git checkout ${list[idx]} > /dev/null 2>&1 && tree -d
while :
do
  read -p "h or l : " action
  if [ "$action" = "h" ]; then
    idx=$(( idx - 1 ))
  elif [ "$action" = "l" ]; then
    idx=$(( idx + 1 ))
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
  git checkout ${list[idx]} > /dev/null 2>&1 && tree -d
done
