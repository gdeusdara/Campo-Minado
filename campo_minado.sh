
#!/bin/bash

# variables
score=0
total=100

corners=(-1 1 -9 -10 -11 9 10 11)

RED="\033[0;31m"
GREEN="\033[0;32m"
NOCOLOR="\033[0m"

# declarations
declare -a room
declare -a mines

# functions
time_to_quit()
{
  printf '\n\n%s\n\n' "info: Que triste! Você optou por sair!!"
  exit 1
}

show_field()
{
  r=0
  clear
  printf '%s' "     a   b   c   d   e   f   g   h   i   j"
  printf '\n   %s\n' "-----------------------------------------"
  for row in $(seq 0 9); do
    printf '%d  ' "$row" 
    for col in $(seq 0 9); do
       ((r+=1))
       is_null_field $r
       printf '%s \e[33m%s\e[0m ' "|" "${room[$r]}"
    done
    printf '%s\n' "|" 
    printf '   %s\n' "-----------------------------------------"
  done
  printf '\n\n'
}

init_mines()
{
  local qtd=$1
  mines=("${room[@]}")
  for i in $(seq 1 $qtd); do
    x=$(shuf -i 0-9 -n 1)
    y=$(shuf -i 0-9 -n 1)
    place=$(($x * 10 + $y))
    
    while [ "${mines[$place]}" = "X" ]; do
      x=$(shuf -i 0-9 -n 1)
      y=$(shuf -i 0-9 -n 1)
      place=$((($x * 10) + $y))
    done
    mines[$place]="X"
  done
}


get_free_fields()
{
  free_fields=0
  for n in $(seq 1 ${#room[@]}); do
    if [ "${room[$n]}" = "." ]; then
      ((free_fields+=1))
    fi
  done
}

is_free_field()
{
  local f=$1
  not_allowed=0
  if [ "${room[$f]}" != "." ]; then
    not_allowed=1
  fi
}


is_null_field()
{
  local e=$1  
    if [ -z "${room[$e]}" ];then
      room[$r]="."
    fi
}


get_mines()
{
  m="${mines[$i]}"
  if [ "$m" == "X" ]; then
    g=0
    room[$i]=X
    room=("${mines[@]}")
  else
    get_mines_around
  fi
}


get_mines_around()
{
  count=0
  for corner in "${corners[@]}"; do
    place=$(($i + $corner))
    if [ "${mines[$place]}" = "X" ]; then
      ((count+=1))
    fi
  done
  room[$i]=$count
  mines[$i]=$count
}


get_coordinates()
{
  colm=${opt:0:1}
  ro=${opt:1:1}
  case $colm in
    a ) o=1;;
    b ) o=2;;
    c ) o=3;;
    d ) o=4;;
    e ) o=5;;
    f ) o=6;;
    g ) o=7;;
    h ) o=8;;
    i ) o=9;;
    j ) o=10;;
  esac
  i=$(((ro*10)+o))
  is_free_field $i
  if [[ $not_allowed = 1 ]] || [[ ! "$colm" =~ [a-j] ]]; then
    printf "$RED \n%s: %s\n$NOCOLOR" "Atenção!!!" "campo inválido ou já escolhido!!!!"
  else
    get_mines
    show_field
    if [ "$m" = "X" ]; then
      printf "\n\n\t $RED%s" "GAME OVER"
      printf '\n\n\t%s\n\n' "Você acertou uma mina"
      exit 0
    elif [ $score = $end ]; then
      printf "\n\n\t $GREEN%s: %s $NOCOLOR %d\n\n Você conseguiu!"
      exit 0
    fi
  fi
}


# main
trap time_to_quit INT
clear
read -p "informe a quantidade de minas: " qtd

end=$((total - qtd))

show_field
init_mines $qtd
while true; do
  printf "Regras: para escolher coluna - g, linha- 5, com o input - g5 \n\n"
  read -p "digite as coordenadas: " opt
  get_coordinates
  ((score+=1))
done