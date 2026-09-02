alias l='ls -lh'
alias ll='ls -lah'
alias la='ls -a'
alias ld='ls -lhd'
alias p='pwd'

#alias rm='rm -rf'
alias u='cd /data/data/com.termux/files/usr'
alias h='cd /data/data/com.termux/files/home'
alias :q='exit'
alias grep='grep --color=auto'
alias open='termux-open'
alias lc='lolcat'
alias xx='chmod +x'
alias rel='termux-reload-settings'

#------------------------------------------

# SSH Server Connections

# linux (Arch)
#alias arch='ssh UNAME@IP -i ~/.ssh/id_rsa.DEVICE'

# linux sftp (Arch)
#alias archfs='sftp -i ~/.ssh/id_rsa.DEVICE UNAME@IP'

# ==============================================================================
# Enable Powerlevel10k instant prompt. Must stay near the top.
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# Oh My Zsh core (single source of truth — no second block later overwriting this)
# ------------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo colored-man-pages command-not-found extract z web-search copypath copyfile)

source "$ZSH/oh-my-zsh.sh"

export LC_ALL=C.UTF-8

# ------------------------------------------------------------------------------
# History
# ------------------------------------------------------------------------------
HISTSIZE=10000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Drop failed commands from history right after they run
autoload -Uz add-zsh-hook
_zsh_drop_failed_history() {
    local exit_status=$?
    if (( exit_status != 0 )); then
        sed -i '$ d' "$HISTFILE" 2>/dev/null
    fi
}
add-zsh-hook precmd _zsh_drop_failed_history

# ------------------------------------------------------------------------------
# Case-insensitive completion (fish-style)
# ------------------------------------------------------------------------------
autoload -Uz 		compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ------------------------------------------------------------------------------
# Core aliases
# ------------------------------------------------------------------------------
alias x='chmod +x'
alias ax='chmod -x'
alias cls='clear'
alias c='clear'

alias ls='ls --color=auto --group-directories-first'
alias ll='ls -la --color=auto --group-directories-first'
alias la='ls -A --color=auto'
# (removed: alias l='ls -CF' — it was silently overriding the `l()` package-list
#  function below every time you typed `l eu`, `l u`, etc. The function wins now.)

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

alias in='apt install'
alias unin='apt uninstall'
alias als='apt search'
alias upup='apt update && apt upgrade -y'

alias sd='cd /sdcard'
alias dl='cd /sdcard/Download'

alias p='nano ~/.zshrc'                # edit profile
alias r='source ~/.zshrc'              # reload profile
alias termux-reload='source ~/.zshrc'
alias profiletxt='cat ~/.zshrc'
alias ohmyzsh='cd "$ZSH"'              # (was `mate`, a macOS-only editor command — not on Termux)

alias setclip='termux-clipboard-set'
alias clip='termux-clipboard-get'
alias t2a="termux-clipboard-set"
alias a2t="termux-clipboard-get"
alias clipset="termux-clipboard-set"
alias batt='termux-battery-status'
alias b='bash'
alias ghc='gh repo clone'

alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

alias cata='for f in *; do [ -f "$f" ] && grep -qI . "$f" && cat "$f"; done'
alias notes='cat ~/notes.txt 2>/dev/null || echo "no notes yet"'
alias myip='curl -s ifconfig.me && echo'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias topcpu='ps aux --sort=-%cpu | head -6'
alias topmem='ps aux --sort=-%mem | head -6'
alias duh='du -h --max-depth=1 | sort -hr'

# ------------------------------------------------------------------------------
# New QOL / fun aliases
# ------------------------------------------------------------------------------
alias please='sudo $(fc -ln -1)'       # retype last command, prefix with sudo
alias path='echo -e ${PATH//:/\\n}'    # print $PATH one entry per line
alias big='du -ah . 2>/dev/null | sort -rh | head -20'   # 20 biggest files/dirs here
alias ports='netstat -tulanp 2>/dev/null || ss -tulanp'  # what's listening
alias serve='python3 -m http.server 8000'                # instant file server, cwd
alias jsonpp='python3 -m json.tool'                       # pretty-print JSON: cat x.json | jsonpp
alias please-clean='apt autoremove -y && apt clean'
alias whereami='termux-location 2>/dev/null || echo "termux-location not installed"'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias hi='echo "hey 👋 $(date "+%A %H:%M") — $(uptime -p 2>/dev/null)"'
alias please-reboot='termux-reboot 2>/dev/null || echo "not supported without root"'
alias untrack='git rm -r --cached . && git add .'   # re-sync .gitignore with tracked files
alias lastcmd='fc -ln -1'                            # print (not run) the last command
alias emptytrash='find . -name "*.bak.*" -mtime +7 -delete && echo "old .bak files cleared"'

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1"     ;;
      *.tar.gz)  tar xzf "$1"     ;;
      *.bz2)     bunzip2 "$1"     ;;
      *.rar)     unrar x "$1"     ;;
      *.gz)      gunzip "$1"      ;;
      *.tar)     tar xvf "$1"     ;;
      *.tbz2)    tar xjf "$1"     ;;
      *.tgz)     tar xzf "$1"     ;;
      *.zip)     unzip "$1"       ;;
      *.Z)       compress -d "$1" ;;
      *.7z)      7z x "$1"        ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

mkcd() { mkdir -p "$1" && cd "$1" || return; }

addprofile() {
  echo "$*" >> ~/.zshrc
  source ~/.zshrc
}

note() {
  echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> ~/notes.txt
  echo "📝 saved."
}

bak() { cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)" && echo "backed up -> $1.bak.$(date +%Y%m%d%H%M%S)"; }
ff() { find . -iname "*$1*" 2>/dev/null; }
weather() { curl -s "wttr.in/${1:-}"; }
cheat() { curl -s "cheat.sh/$1"; }

countdown() {
  local s="$1"
  while [ "$s" -gt 0 ]; do
    echo -ne "⏳ $s \r"
    sleep 1
    s=$((s - 1))
  done
  echo "⏰ time's up!"
}

# Pomodoro timer built on countdown(), with an optional Termux notification
pomodoro() {
  local mins="${1:-25}"
  echo "🍅 Pomodoro started: ${mins} min"
  countdown $((mins * 60))
  termux-notification -t "Pomodoro done" -c "Take a break!" 2>/dev/null
}

# Search your history for a keyword, with dates — handy for "what did I run yesterday"
whatdid() {
  fc -li 1 | grep -i "$1"
}

# Grep with color, case-insensitive
f() {
    grep -i --color=auto "$*"
}

# Print one specific line (with its line number) from a file
ptxt() {
    local file="$1"
    local line="$2"
    if [ -z "$file" ] || [ -z "$line" ]; then
        echo "Usage: ptxt <file> <line_number>"
        return 1
    fi
    sed -n "${line}p" "$file"
}

# ------------------------------------------------------------------------------
# Shizuku / rish package-list & enable/disable helpers
# ------------------------------------------------------------------------------

# Oh My Zsh's core lib defines `alias l='ls -lah'` by default — it loads
# earlier in this file via `source $ZSH/oh-my-zsh.sh` and silently shadows
# the function below unless we remove it first.
unalias l 2>/dev/null

l() {
    case "$1" in
        e|enabled)         rish -c "/system/bin/cmd package list packages -e" | sed 's/package://' ;;
        d|disabled)        rish -c "/system/bin/cmd package list packages -d" | sed 's/package://' ;;
        du|disabled-user)  rish -c "/system/bin/cmd package list packages -d -3" | sed 's/package://' ;;
        eu|enabled-user)   rish -c "/system/bin/cmd package list packages -e -3" | sed 's/package://' ;;
        u|user)            rish -c "/system/bin/cmd package list packages -3" | sed 's/package://' ;;
        s|system)          rish -c "/system/bin/cmd package list packages -s" | sed 's/package://' ;;
        *)
            echo "Usage: l [e|d|du|eu|u|s]"
            echo "  e  : all enabled apps"
            echo "  d  : all disabled apps"
            echo "  du : disabled 3rd-party user apps"
            echo "  eu : enabled 3rd-party user apps"
            echo "  u  : all 3rd-party user apps"
            echo "  s  : all system apps"
            ;;
    esac
}

_find_pkg() {
    local query="$1"
    local matched
    matched=$(rish -c "/system/bin/cmd package list packages" | sed 's/package://' | grep -i "$query" | head -n 1)
    if [ -z "$matched" ]; then
        matched=$(rish -c "dumpsys package" | grep -i -E "pkg=.*$query|label=.*$query" -B 2 -A 2 | grep -o 'pkg=[^ ]*' | cut -d= -f2 | head -n 1)
    fi
    echo "$matched"
}

enable() {
    if [ -z "$1" ]; then
        echo "Usage: enable <app_or_pkg1> [app_or_pkg2 ...]"
        return 1
    fi
    for item in "$@"; do
        local pkg=""
        if [[ "$item" == *.* ]]; then pkg="$item"; else pkg=$(_find_pkg "$item"); fi
        if [ -n "$pkg" ]; then
            echo -e "\e[1;32m[+] Enabling:\e[0m $pkg"
            rish -c "/system/bin/cmd package enable $pkg" > /dev/null 2>&1
            rish -c "/system/bin/cmd package unsuspend $pkg" > /dev/null 2>&1
        else
            echo -e "\e[1;31m[-] Could not find package matching:\e[0m $item"
        fi
    done
}

disable() {
    if [ -z "$1" ]; then
        echo "Usage: disable <app_or_pkg1> [app_or_pkg2 ...]"
        return 1
    fi
    for item in "$@"; do
        local pkg=""
        if [[ "$item" == *.* ]]; then pkg="$item"; else pkg=$(_find_pkg "$item"); fi
        if [ -n "$pkg" ]; then
            echo -e "\e[1;33m[-] Disabling:\e[0m $pkg"
            rish -c "/system/bin/cmd package disable-user $pkg" > /dev/null 2>&1
            rish -c "/system/bin/cmd package suspend $pkg" > /dev/null 2>&1
        else
            echo -e "\e[1;31m[-] Could not find package matching:\e[0m $item"
        fi
    done
}

# ------------------------------------------------------------------------------
# Startup banner
# ------------------------------------------------------------------------------
clear
echo -e "\e[1;35m  _  _  ____  _     _     ____  \e[0m"
echo -e "\e[1;35m / \\/ \\/  _ \\/ \\   / \\   /  _ \\ \e[0m"
echo -e "\e[1;35m | || ||  __/| |   | |   | / \\| \e[0m"
echo -e "\e[1;35m | \\_/|| |   | |_/\\| |_/\\| \\_/| \e[0m"
echo -e "\e[1;35m \\____/\\_/   \\____/\\____/\\____/ \e[0m"
echo -e "\e[1;33m Termux zsh Ready! Fish-style autosuggestions active.\e[0m\n"
