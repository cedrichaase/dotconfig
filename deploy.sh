#!/bin/bash

DIR=$(pwd)
DIR_DOTGEN=${DIR}/dotgen
DIR_CONFIGS=${DIR}/configs
DIR_TEMPLATES=${DIR}/templates
DIR_OUTPUT=${DIR}/output

DIR_PLUGINS=${DIR}/plugin
DIR_PLUG_BASH=${DIR_PLUGINS}/bash
DIR_PLUG_VIM=${DIR_PLUGINS}/vim
DIR_PLUG_ZSH=${DIR_PLUGINS}/zsh

DIR_TARGET=${HOME}

function init()
{
  git submodule init
  git submodule update --init
}

function update()
{
    git stash
    git submodule update --remote
    git diff-index --quiet HEAD -- || {
        cd ${DIR_DOTGEN} && composer install && cd ${DIR}
        git add .
        git commit -m "Update submodules"
    }
    git stash pop
}

function build()
{
    # install dotgen deps if necessary
    [ ! -d ${DIR_DOTGEN}/vendor ] && cd ${DIR_DOTGEN} && composer install && cd ${DIR}

    # create dir structure if necessary
    [ ! -d ${DIR_OUTPUT} ] && mkdir -p ${DIR_OUTPUT}

    # find config file for current host
    local config_file=${DIR_CONFIGS}/host/$(hostname).yml
    [ ! -f ${config_file} ] && echo "No config found for host $(hostname)" && exit 1

    # render templates
    ${DIR_DOTGEN}/bin/dotgen render -vv -I${DIR_CONFIGS} -I${DIR_CONFIGS}/type -I${DIR_CONFIGS}/themes -t ${DIR_TEMPLATES} -o ${DIR_OUTPUT} ${config_file}
}

function watch()
{
    # recursively monitor templates and configs for changes
    inotifywait -m -r -e modify,close_write ${DIR_TEMPLATES} ${DIR_CONFIGS} | while read file; do
        echo ${file} changed, rebuilding
        build
        reload
    done
}

function reload()
{
    export DISPLAY=:0.0
    i3-msg restart
    xrdb -merge ${HOME}/.Xresources
    xmodmap ${HOME}/.Xmodmap
}

function install()
{
    # don't ignore dotfiles
    shopt -s dotglob

    # make shell scripts executable
    find ${DIR_OUTPUT} -name '*.sh' -exec chmod +x {} \;

    # link rendered files to target dir
    cp -rs ${DIR_OUTPUT}/* ${DIR_TARGET}

    # install bash plugins
    ln -s ${DIR_PLUG_BASH}/z/z.sh ${DIR_TARGET}/.z.sh

    # install zsh plugins
    cp -rs ${DIR_PLUG_ZSH}/oh-my-zsh ${DIR_TARGET}/.oh-my-zsh

    # install vim plugins
    dir_vim_autoload=${DIR_TARGET}/.vim/autoload
    [ ! -d  ${dir_vim_autoload} ] && mkdir -p ${dir_vim_autoload}

    dir_vim_bundle=${DIR_TARGET}/.vim/bundle
    [ ! -d  ${dir_vim_bundle} ] && mkdir -p ${dir_vim_bundle}

    dir_vim_colors=${DIR_TARGET}/.vim/colors
    [ ! -d  ${dir_vim_colors} ] && mkdir -p ${dir_vim_colors}

    cp -rs ${DIR_PLUG_VIM}/vim-pathogen/autoload/* ${dir_vim_autoload}/
    cp -rs ${DIR_PLUG_VIM}/rust.vim ${dir_vim_bundle}/
    cp -rs ${DIR_PLUG_VIM}/sourcerer.vim ${dir_vim_bundle}/
    ln -s ${DIR_PLUG_VIM}/sourcerer.vim/colors/sourcerer.vim ${dir_vim_colors}/

    # ignore dotfiles again
    shopt -u dotglob
}

function all()
{
    update
    build
    install
}

$1
