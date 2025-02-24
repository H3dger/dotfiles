# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/liulab/shanhanjie/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/liulab/shanhanjie/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/liulab/shanhanjie/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/liulab/shanhanjie/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/home/liulab/shanhanjie/software/sratoolkit.3.1.1-ubuntu64/bin:$PATH"

# ncurses
export CXXFLAGS="-fPIC"
export CFLAGS="-fPIC"
export NCURSES_HOME=$HOME/ncurses  # 你自己的 ncurses 目录
export PATH=$NCURSES_HOME/bin:$PATH
export LD_LIBRARY_PATH=$NCURSES_HOME/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$NCURSES_HOME/include" LDFLAGS="-L$NCURSES_HOME/lib"

export PATH=$HOME/Applications/zsh/zsh-5.9/bin:$PATH
