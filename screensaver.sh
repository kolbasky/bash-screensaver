#!/usr/bin/env bash
shopt -s extglob 2> /dev/null 
setopt extended_glob 2> /dev/null 
setopt KSH_ARRAYS 2> /dev/null
programname=$0

usage() {
  printf -- "Usage:\n"
  printf -- " ${programname} [-d] [-t \"sample text\"] [-l batman] [-f filename] [-c] [-s 24]\n"
  printf -- "Parameters:\n"
  printf -- " --logo(-l)\t\tname of a premade logo: dvd, batman, ghost, metallica, tux, bigtux\n"
  printf -- " --file(-f)\t\tread file with text (ascii art)\n"
  printf -- " --date(-d)\t\tdisaply current datetime. conflicts with -t\n"
  printf -- " --text(-t)\t\ttext to display. conflicts with -d\n"
  printf -- " --clear-mode(-c)\thow screen clears: 1 - line-by-line over old position, 2 - clear around object, 3 - tput clear. Feel free to experiment, which looks better.\n"
  printf -- " --speed(-s)\t\thow often frames change\n"
  printf -- " --fps-counter(-F)\tshow FPS counter\n"
  printf -- "Controls:\n"
  printf -- "  WASD or arrows for directions, -/+ for speed\n"
}

# to support --parameter=value and --parameter value syntax.
set -- ${@//=/ }
# parse input arguments
while [ $# -gt 0 ]; do
    case "${1}" in
        *(-)-help|*(-)-h)
            usage
            exit 0
	    ;;
        *(-)-text|*(-)-t)
            text="${2:-empty}"
            shift || true
	    ;;
        *(-)-date|*(-)-d)
            date=1
	    ;;
        *(-)-speed|*(-)-s)
            fps="${2}"
            shift
      ;;
        *(-)-fps-counter|*(-)-F)
            fps_counter=1
      ;;
        *(-)-logo|*(-)-l)
            logo="${2}"
            shift
      ;;
        *(-)-file|*(-)-f)
            file="${2}"
            shift
      ;;
        *(-)-clear-mode|*(-)-c)
            clear_mode=${2}
            shift
      ;;   
        *)
            text="${text} ${1}"
	    ;;
    esac
    shift || true
done
# fail on conflicting arguments
if [[ $date == "1" ]] && [[ ! -z "$text" ]]; then
  printf -- "Error: conflicting parameters --text and --date. Specify one of them!\n"
  usage
  tput cnorm
  exit 1
fi
text=${text//%/%%}
# start vars
xspeed=1
yspeed=1
pos=(0 0)
prevpos=("${pos[@]}")
logo=${logo:-dvd}
date=${date:-0}
fps=${fps:-15}
clear_mode=${clear_mode:-1}
sleep=`printf "scale = 3; 1 / $fps\n" | bc`
fps_counter=${fps_counter:-0}
colornum=1
IFS='
'
# premade logos
if [[ $logo == "tux" ]];then
    # small tux penguin logo
    text=${text:-"              a8888b.\n             d888888b.\n             8P\"YP\"Y88\n             8|o||o|88\n             8'    .88\n             8\`._.' Y8.\n            d/      \`8b.\n          .dP   .     Y8b.\n         d8:'   \"   \`::88b.\n        d8\"           \`Y88b\n       :8P     '       :888\n        8a.    :      _a88P\n      ._/\"Yaa_ :    .| 88P|\n      \    YP\"      \`| 8P  \`.\n      /     \._____.d|    .'\n      \`--..__)888888P\`._.'"}
elif [[ $logo == "bigtux" ]];then
    # big tux penguin
    text=${text:-"                 .88888888:.\n                88888888.88888.\n              .8888888888888888.\n              888888888888888888\n              88' _\`88'_  \`88888\n              88 88 88 88  88888\n              88_88_::_88_:88888\n              88:::,::,:::::8888\n              88\`:::::::::'\`8888\n             .88  \`::::'    8:88.\n            8888            \`8:888.\n          .8888'             \`888888.\n         .8888:..  .::.  ...:'8888888:.\n        .8888.'     :'     \`'::\`88:88888\n       .8888        '         \`.888:8888.\n      888:8         .           888:88888\n    .888:88        .:           888:88888:\n    8888888.       ::           88:888888\n    \`.::.888.      ::          .88888888\n   .::::::.888.    ::         :::\`8888'.:.\n  ::::::::::.888   '         .::::::::::::\n  ::::::::::::.8    '      .:8::::::::::::.\n .::::::::::::::.        .:888:::::::::::::\n :::::::::::::::88:.__..:88888:::::::::::'\n  \`'.:::::::::::88888888888.88:::::::::'\n        \`':::_:' -- '' -'-' \`':_::::'\`\n "}
elif [[ $logo == "batman" ]];then
    text=${text:-"                   ,.ood888888888888boo.,\n              .od888P^\"\"            \"\"^Y888bo.\n          .od8P''   ..oood88888888booo.    \`\`Y8bo.\n       .odP'\"  .ood8888888888888888888888boo.  \"\`Ybo.\n     .d8'   od8'd888888888f\`8888't888888888b\`8bo   \`Yb.\n    d8'  od8^   8888888888[  \`'  ]8888888888   ^8bo  \`8b\n  .8P  d88'     8888888888P      Y8888888888     \`88b  Y8.\n d8' .d8'       \`Y88888888'      \`88888888P'       \`8b. \`8b\n.8P .88P            \"\"\"\"            \"\"\"\"            Y88. Y8.\n88  888                                              888  88\n88  888                                              888  88\n88  888.        ..                        ..        .888  88\n\`8b \`88b,     d8888b.od8bo.      .od8bo.d8888b     ,d88' d8'\n Y8. \`Y88.    8888888888888b    d8888888888888    .88P' .8P\n  \`8b  Y88b.  \`88888888888888  88888888888888'  .d88P  d8'\n    Y8.  ^Y88bod8888888888888..8888888888888bod88P^  .8P\n     \`Y8.   ^Y888888888888888LS888888888888888P^   .8P'\n       \`^Yb.,  \`^^Y8888888888888888888888P^^'  ,.dP^'\n          \`^Y8b..   \`\`^^^Y88888888P^^^'    ..d8P^'\n              \`^Y888bo.,            ,.od888P^'\n                   \"\`^^Y888888888888P^^'\""}
elif [[ $logo == "metallica" ]];then
    # metallica logo
    text=${text:="           _                                   _ \n         .-/:\                                 /::-. \n     _.-~ /:::\___  ______ __  _    _     _   /:::| ~-._ \n     \:/  -~||  __||_  __//  || |  | |  /| | / __/| .\:/ \n      / . . ||  __|:| |\:/ ' || |__| |_/:| || (:/:|   \ \n     / /::| ||____|:|_|:/_/|_||____|____||_|:\___\| |\ \ \n    / /:::|.:\::::\:\:\:|:||:||::::|:::://:/:/:::/:.|:\ \ \n   / /:::/ \::\::::\|\:\|:/|:||::::|::://:/\/:::/::/:::\ \ \n  /  ..:\   \-~~~~~~~ ~~~~  ~~ ~~~~~~~~ ~~  ~~~~~-/\/:..  \ \n /..:::::\                                         /:::::..\ \n/::::::::-                                         -::::::::\ \n\:::::-~                                             ~-:::::/ \n \:-~                                                   ~-:/"}
elif [[ $logo == "ghost" ]];then
    # ghostbusters logo
    text=${text:="                       ---                                     \n                    -        --                             \n                --( /     \ )XXXXXXXXXXXXX                   \n            --XXX(   O   O  )XXXXXXXXXXXXXXX-              \n           /XXX(       U     )        XXXXXXX\               \n         /XXXXX(              )--   XXXXXXXXXXX\             \n        /XXXXX/ (      O     )   XXXXXX   \XXXXX\\n        XXXXX/   /            XXXXXX   \   \XXXXX----        \n        XXXXXX  /          XXXXXX         \  ----  -         \n---     XXX  /          XXXXXX      \           ---        \n  --  --  /      /\  XXXXXX            /     ---=         \n    -        /    XXXXXX              '--- XXXXXX         \n      --\/XXX\ XXXXXX                      /XXXXX         \n        \XXXXXXXXX                        /XXXXX/\n         \XXXXXX                         /XXXXX/         \n           \XXXXX--  /                -- XXXX/       \n            --XXXXXXX---------------  XXXXX--         \n               \XXXXXXXXXXXXXXXXXXXXXXXX-            \n                 --XXXXXXXXXXXXXXXXXX-"}
elif [[ $logo == "medusa" ]];then
    # medusa logo
    text=${text:="⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠾⠏⠉⠀⠀⠀⠀⠀⠀⠈⠉⠳⢶⣄⡀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠁⠀⠀⠀⠸⠷⠀⠀⠀⠀⠀⠘⠛⠃⠙⢿⣄⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⢠⡿⢱⡟⠓⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣶⡄⢻⡆⠀\n⠀⠀⠀⠀⠀⠀⠀⢸⣧⡈⠙⠛⠁⠀⢀⣀⡀⠀⠀⠀⣀⣀⠀⠀⠁⠀⠈⣿⡀\n⠀⠀⠀⠀⠀⠀⠀⠸⢍⣻⣦⣄⡀⠀⠹⠭⠟⠀⠀⠸⣿⣿⠇⠀⣠⠶⣦⣿⠃\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣧⣈⣻⡷⢶⣦⣀⣀⠀⠀⠀⠀⠀⠀⠈⢛⢡⡟⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣳⠃⡹⠳⡤⡴⡏⠙⠛⣻⠶⠶⢤⡤⠤⠶⣿⠁⠀\n⠀⠀⠀⢀⣠⣤⣶⠶⠋⣵⠋⢰⠇⣼⣱⠁⢹⠗⢲⡟⠦⣤⠼⠛⠦⠞⠃⠀⠀\n⠀⢀⣴⡿⠋⠁⢠⣰⠞⠁⣰⣯⣼⠁⡏⠀⢸⠀⠸⡇⠀⢸⠀⠀⠀⠀⠀⠀⠀\n⠀⣼⠋⢀⣠⡴⣟⢁⣠⡞⢻⡿⠁⢰⡇⠀⢸⣄⠀⢷⠀⠸⣆⠀⠀⠀⠀⠀⠀\n⢸⢇⣴⡿⠋⠄⣼⡿⠁⠀⣾⠁⠀⠸⡇⠀⠀⢿⡄⠘⣆⠀⠹⣦⠀⠀⠀⠀⠀\n⢠⣾⠏⠀⠀⢠⣿⠀⠀⠀⣿⡄⠀⠀⢿⠀⠀⠈⣷⡄⠹⣧⠀⠙⢷⣄⠀⠀⠀\n⢸⡟⠀⠀⠀⢸⣿⠀⠀⠀⢹⣧⠀⠀⠸⣷⠀⠀⠸⣷⡀⠹⣦⠀⠀⠻⣧⠀⠀\n⢸⡇⠀⠀⠀⠀⣿⡆⠀⠀⠀⢻⣧⠀⠀⢻⡆⠀⠀⠹⣧⠀⠹⣇⠀⠀⢻⣧⠀\n⢸⣇⠀⠀⠀⠀⠘⣿⣄⠀⠀⠀⠹⣧⠀⠘⣿⠀⠀⠀⣿⡇⠀⢿⣄⠀⠀⣿⡇\n⢈⣿⡄⠀⠀⠀⠀⠘⣿⣄⠀⠀⠀⠈⠣⡀⢿⡆⠀⠀⣿⠃⠀⠘⣿⡀⠀⢸⡇\n⠀⠘⠃⠀⠀⠀⠀⠀⠈⢿⣧⠀⠀⠀⠀⠀⢸⣷⢀⡼⠃⠀⠀⠀⣿⡇⠀⢸⡇\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣧⡀⠀⠀⠀⢸⣿⠈⠀⠀⠀⠀⠀⣿⡇⠀⡾⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⡄⠀⠀⣸⡏⠀⠀⠀⠀⠀⣸⡟⠀⠀⠁⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡿⠀⠀⠀⠀⢀⣴⠟⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠃⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"}
elif [[ $logo == "demon" ]];then
    # demon logo
    text=${text:="                            ,-.\n       ___,---.__          /'|\`\          __,---,___\n    ,-'    \\\`    \`-.____,-'  |  \`-.____,-'    //    \`-.\n  ,'        |           ~'\     /\`~           |        \`.\n /      ___//              \`. ,'          ,  , \___      \ \n|    ,-'   \`-.__   _         |        ,    __,-'   \`-.    |\n|   /          /\_  \`   .    |    ,      _/\          \   |\n\  |           \ \`-.___ \    |   / ___,-'/ /           |  /\n \  \           | \`._   \`\\   |  //'   _,' |           /  /\n  \`-.\         /'  _ \`---'' , . \`\`---' _  \`\         /,-'\n     \`\`       /     \    ,='/ \\\`=.    /      \      ''\n             |__   /|\_,--.,-.--,--._/|\   __|\n             /  \`./  \\\\\\\\\\\\\`\\ |  |  | /,//' \,'  \ \n            /   /     ||--+--|--+-/-|     \   \ \n           |   |     /'\_\_\ | /_/_/\`\     |   |\n            \   \__, \_     \`~'     _/ .__/   /\n             \`-._,-'   \`-._______,-'   \`-._,-'"}
else
    # nice DVD logo
    text=${text:-"⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⡀\\n⠀⢠⣿⣿⡿⠀⠀⠈⢹⣿⣿⡿⣿⣿⣇⠀⣠⣿⣿⠟⣽⣿⣿⠇⠀⠀⢹⣿⣿⣿\\n⠀⢸⣿⣿⡇⠀⢀⣠⣾⣿⡿⠃⢹⣿⣿⣶⣿⡿⠋⢰⣿⣿⡿⠀⠀⣠⣼⣿⣿⠏\\n⠀⣿⣿⣿⣿⣿⣿⠿⠟⠋⠁⠀⠀⢿⣿⣿⠏⠀⠀⢸⣿⣿⣿⣿⣿⡿⠟⠋⠁⠀\\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   ⢹⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\\n⣠⣴⣶⣾⣿⣿⣻⡟⣻⣿⢻⣿⡟⣛⢻⣿⡟⣛⣿⡿⣛⣛⢻⣿⣿⣶⣦⣄⡀⠀\\n⠉⠛⠻⠿⠿⠿⠷⣼⣿⣿⣼⣿⣧⣭⣼⣿⣧⣭⣿⣿⣬⡭⠾⠿⠿⠿⠛⠉⠀"}
fi

tput smcup
# return cursor on exit
trap "tput cnorm; tput sgr0; stty echo; unset IFS; tput rmcup; exit 1" SIGINT SIGTERM EXIT 2>/dev/null

if [[ ! -z $file ]];then
  text=""
  for l in `cat file | sed "s/'/\'/g" | sed "s/%/%%%%/g" | sed "s/\\\\\/\\\\\\\\\\\\\/g"`;do text="$text\\n$l"; done
fi

if [[ $date == "1" ]]; then
  text=`date +"%A, %Y-%m-%d %H:%M:%S"`
  text_height=1
else
  text_height=`printf -- "$text" | grep -c "^.*$"`
fi

for line in `printf -- "$text"`; do
  if [ ${#line} -gt ${text_len:-0} ]; then text_len=${#line};fi
done

body() {
  while true; do
    if [[ $date == "1" ]]; then
      text=`date +"%A, %Y-%m-%d %H:%M:%S"`
    fi
    # check terminal size every loop to detect resize
    width=`tput cols`
    heigth=`tput lines`
    #stty -echo
    tput civis
    # we can control flying text with WASD :-)  and speed with -/+
    escape_char=$(printf "\u1b")
    read -t 0.001 -r -s -n 1 key 2> /dev/null || read -t 0.001 -r -s -k 1 key 2> /dev/null
    if [[ $key == $escape_char ]]; then
        read -t 0.001 -r -s -n 2 key_arrow 2> /dev/null || read -r -t 0.001 -s -k 2 key_arrow 2> /dev/null
        key=""
    fi
    # get rid of extra user input
    read -t 0.001 -r -s
    if [[ ${key,,} == "w" ]] || [[ ${key,,} == "ц" ]] || [[ ${key_arrow} == '[A' ]];then yspeed=-1; 
    elif [[ ${key,,} == "a" ]] || [[ ${key,,} == "ф" ]] || [[ ${key_arrow} == '[D' ]];then xspeed=-1; 
    elif [[ ${key,,} == "s" ]] || [[ ${key,,} == "ы" ]] || [[ ${key_arrow} == '[B' ]];then yspeed=1; 
    elif [[ ${key,,} == "d" ]] || [[ ${key,,} == "в" ]] || [[ ${key_arrow} == '[C' ]];then xspeed=1;
    elif [[ ${key,,} == "-" ]];then fps=$((fps - 5));
    elif [[ ${key,,} == "=" ]];then fps=$((fps + 5));
    elif [[ ${key,,} == "+" ]];then fps=$((fps + 5));
    fi
    if [[ $fps -le 0 ]]; then fps=1; fi
    if [[ $fps -gt 125 ]]; then fps=125; fi
    sleep=`printf "scale = 3; 1 / $fps\n" | bc`
    key=""
    # loop through colors on collisions
    if [ $colornum -gt 7 ]; then colornum=1; fi
    # clear screen
    # this way we have a little bit of flickering, but less blur
    if [[ $clear_mode == "1" ]];then
      tput cup ${prevpos[1]} 0
      for line in `printf -- "$text"`;do
        printf -- "\033[0K\n"
        #tput el && tput cud1
        k=$((k+1))
      done
    elif [[ $clear_mode == "2" ]];then
    # this way we have less flickering, but more clear_mode
      if [[ ${pos[1]} -eq 0 ]];then
          tput cup $((${pos[1]} + $text_height)) ${pos[0]}
          tput el && tput el1
      elif [[ $((${pos[1]} + $text_height)) -eq $heigth ]];then
          tput cup $((${pos[1]} - 1)) ${pos[0]}
          tput el && tput el1
      elif [[ $yspeed -eq 1 ]]; then
          tput cup $((${pos[1]} - $yspeed)) ${pos[0]}
          tput el && tput el1
      elif [[ $yspeed -eq -1 ]]; then
            tput cup $((${pos[1]} + $text_height - $yspeed - 1)) ${pos[0]}
            tput el && tput el1
      fi
      i=0
      for line in `printf -- "$text"`; do
        tput cup $((${pos[1]} + $i)) $((${pos[0]})) 2> /dev/null
        tput el1
        tput cup $((${pos[1]} + $i)) $((${pos[0]} + ${#line} - 1))
        tput el
        i=$((i+1))
      done
    else
      tput clear
    fi
    # position the cursor and print colred text
    i=0
    for line in `printf -- "$text"`; do
        tput cup $((${pos[1]} + $i)) ${pos[0]}
        printf -- "$(tput setaf $colornum)$line"  
        i=$((i+1))
        # fps counter
        if [ $fps_counter -eq 1 ]; then
          tput cup 0 $((width - 3))
          printf $fps
        fi
    done
    # move text and remember previous pos for cleaner
    prevpos=("${pos[@]}")
    pos[0]=$((${pos[0]} + $xspeed))
    pos[1]=$((${pos[1]} + $yspeed))
    # collsion detection
    if [ $((${pos[0]} + $text_len)) -ge $width ]; then 
      xspeed=$((xspeed * -1))
      pos[0]=$((width - $text_len))
      colornum=$((colornum + 1))
    fi
    if [ ${pos[0]} -le 0 ]; then 
      xspeed=$((xspeed * -1)); 
      pos[0]=0; 
      colornum=$((colornum + 1))
    fi
    if [ $((${pos[1]} + $text_height)) -ge $heigth ]; then 
      yspeed=$((yspeed * -1)); 
      pos[1]=$((heigth - $text_height)); 
      colornum=$((colornum + 1));
    fi
    if [ ${pos[1]} -le 0 ]; then 
      yspeed=$((yspeed * -1)); 
      pos[1]=0; 
      colornum=$((colornum + 1));
    fi
    sleep $sleep
  done
}
# hide cursor, clear screen and run
stty -echo
tput civis
body
