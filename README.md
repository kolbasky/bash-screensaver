# bash-screensaver
This script displays flying logos, text, or current datetime.<br>
Text may be multiline (using \n), just test that it is displayed correctly with printf command. Ususally it takes to change `\n` -> `\\n`, `` ` ``  -> `` \` ``, `"` -> `\"`. <br>
For `%` in text use `%%`<br>
Direction can be changed via WASD/arrows, speed - via -/+ :-)<br>
![asd](https://user-images.githubusercontent.com/42576088/198890281-7c91152d-fea1-48ee-82a3-77121acb151d.gif)<br>

## Usage
Download and make executable<br>
```
curl https://raw.githubusercontent.com/kolbasky/bash-screensaver/main/screensaver.sh > screensaver.sh
chmod +x screensaver.sh
```
Default is DVD logo<br>
`./screensaver.sh`<br>
Display batman logo<br>
`./screensaver.sh -l batman`<br>
Display custom text<br>
`./screensaver.sh -t Sample_text!`<br>
Display current datetime<br>
`./screensaver.sh date`<br>
Display contents of file (i.e. with ASCII art)<br>
`./screensaver.sh -f somefile`<br>
Get help<br>
`./screensaver.sh help`<br>
Exit<br>
`Ctrl+C`

### Parameters
- `--logo(-l)` name of a premade logo: dvd, batman, ghost, metallica, tux, bigtux, demon, medusa<br>
- `--file(-f)` read file with text or ASCII art<br>
- `--date(-d)` disaply current datetime. conflicts with -t<br>
- `--text(-t)` text to display. conflicts with -d<br>
- `--clear-mode(-c)` how screen clears: 1 - line-by-line over old position, 2 - clear around object, 3 - clear command. Feel free to experiment, which looks better.<br>
- `--speed(-s)` speed of movement. FPS<br>
- `--fps-counter(-F)` show FPS counter<br>

### Controls
- `WASD` to change direction<br>
- `-/+` to change speed (fps)<br>
