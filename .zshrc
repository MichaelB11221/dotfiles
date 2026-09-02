# ==============================================================================
# 1. Powerlevel10k instant prompt (must stay at the top)
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# 2. Oh My Zsh core config
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
CASE_SENSITIVE="false"
ENABLE_CORRECTION="true"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  colored-man-pages
  command-not-found
  extract
  z
  web-search
  copypath
  copyfile
)

source "$ZSH/oh-my-zsh.sh"

export LC_ALL=C.UTF-8

# ==============================================================================
# 3. History
# ==============================================================================
HISTSIZE=10000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Case-insensitive completion (fish-style)
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ==============================================================================
# 4. Core aliases
# ==============================================================================
alias x='chmod +x'
alias ax='chmod -x'
alias xx='chmod +x'
alias cls='clear'
alias c='clear'
alias :q='exit'

alias p='nano ~/.zshrc'                # edit profile
alias r='source ~/.zshrc'              # reload profile
alias termux-reload='source ~/.zshrc'
alias profiletxt='cat ~/.zshrc'
alias ohmyzsh='cd "$ZSH"'
alias grep='grep --color=auto'
alias open='termux-open'
alias lc='lolcat'
alias rel='termux-reload-settings'

alias ls='ls --color=auto --group-directories-first'
alias ll='ls -la --color=auto --group-directories-first'
alias la='ls -A --color=auto'
alias lh='ls -lh'                       # renamed from `l` — see note near the l() function below
alias ld='ls -lhd'

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
alias u='cd /data/data/com.termux/files/usr'
alias h='cd /data/data/com.termux/files/home'

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

alias please='sudo $(fc -ln -1)'       # retype last command, prefix with sudo
alias path='echo -e ${PATH//:/\\n}'    # print $PATH one entry per line
alias big='du -ah . 2>/dev/null | sort -rh | head -20'
alias ports='netstat -tulanp 2>/dev/null || ss -tulanp'
alias serve='python3 -m http.server 8000'
alias jsonpp='python3 -m json.tool'
alias please-clean='apt autoremove -y && apt clean'
alias whereami='termux-location 2>/dev/null || echo "termux-location not installed"'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias hi='echo "hey 👋 $(date "+%A %H:%M") — $(uptime -p 2>/dev/null)"'
alias please-reboot='termux-reboot 2>/dev/null || echo "not supported without root"'
alias untrack='git rm -r --cached . && git add .'
alias lastcmd='fc -ln -1'
alias emptytrash='find . -name "*.bak.*" -mtime +7 -delete && echo "old .bak files cleared"'

# ==============================================================================
# 5. Helper functions
# ==============================================================================
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

pomodoro() {
  local mins="${1:-25}"
  echo "🍅 Pomodoro started: ${mins} min"
  countdown $((mins * 60))
  termux-notification -t "Pomodoro done" -c "Take a break!" 2>/dev/null
}

whatdid() {
  fc -li 1 | grep -i "$1"
}

f() {
    grep -i --color=auto "$*"
}

ptxt() {
    local file="$1"
    local line="$2"
    if [ -z "$file" ] || [ -z "$line" ]; then
        echo "Usage: ptxt <file> <line_number>"
        return 1
    fi
    sed -n "${line}p" "$file"
}

# ==============================================================================
# 6. Shizuku / Rish package management assistants
# ==============================================================================
# NOTE: renamed from l() to pk() — Oh My Zsh's own libs define `alias l=...`
# on load, which silently shadowed this function every time. `lh` above
# covers the `ls -lh` shortcut instead, so `l` and `pk` no longer collide.
pk() {
    case "$1" in
        e|enabled)         rish -c "/system/bin/cmd package list packages -e" | sed 's/package://' ;;
        d|disabled)        rish -c "/system/bin/cmd package list packages -d" | sed 's/package://' ;;
        du|disabled-user)  rish -c "/system/bin/cmd package list packages -d -3" | sed 's/package://' ;;
        eu|enabled-user)   rish -c "/system/bin/cmd package list packages -e -3" | sed 's/package://' ;;
        u|user)            rish -c "/system/bin/cmd package list packages -3" | sed 's/package://' ;;
        s|system)          rish -c "/system/bin/cmd package list packages -s" | sed 's/package://' ;;
        *)
            echo "Usage: pk [e|d|du|eu|u|s]"
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

# ==============================================================================
# 7. Startup banner (must stay at the bottom)
# ==============================================================================
clear
echo -e "\e[1;35m  _  _  ____  _     _     ____  \e[0m"
echo -e "\e[1;35m / \\/ \\/  _ \\/ \\   / \\   /  _ \\ \e[0m"
echo -e "\e[1;35m | || ||  __/| |   | |   | / \\| \e[0m"
echo -e "\e[1;35m | \\_/|| |   | |_/\\| |_/\\| \\_/| \e[0m"
echo -e "\e[1;35m \\____/\\_/   \\____/\\____/\\____/ \e[0m"
echo -e "\e[1;33m Termux zsh ready! Fish-style autosuggestions active.\e[0m\n"

# To customize prompt, run `p10k configure` (interactive, run manually — don't
# add it as a command above) or edit ~/.p10k.zsh directly.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# rish 
alias rish='~/.shizuku/rish'
