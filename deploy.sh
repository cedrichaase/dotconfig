#!/bin/bash

DIR=$(pwd)
DIR_DOTGEN=${DIR}/dotgen
DIR_CONFIGS=${DIR}/configs
DIR_OUTPUT=${DIR}/output

DIR_PLUGINS=${DIR}/plugin
DIR_PLUG_VIM=${DIR_PLUGINS}/vim
DIR_PLUG_ZSH=${DIR_PLUGINS}/zsh

DIR_TARGET=${HOME}

function update()
{
    git stash
    git submodule update --remote
    git diff-index --quiet HEAD -- || {
        git add .
        git commit -m "Update submodules"
    }
    git stash pop
}

function build()
{
    [ ! -d ${DIR_DOTGEN}/vendor ] && cd ${DIR_DOTGEN} && composer install && cd ${DIR}
    [ ! -d ${DIR_OUTPUT} ] && mkdir -p ${DIR_OUTPUT}
    php ${DIR_DOTGEN}/src/generator.php ${DIR_CONFIGS}/$(hostname).ini
}

function install()
{
    # don't ignore dotfiles
    shopt -s dotglob

    # install dotfiles
    cp -rs ${DIR_OUTPUT}/* ${DIR_TARGET}

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