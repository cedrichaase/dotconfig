#!/bin/bash

DIR=$(pwd)
DIR_DOTGEN=${DIR}/dotgen
DIR_CONFIGS=${DIR}/configs
DIR_OUTPUT=${DIR}/output

#DIR_TARGET=${HOME}
DIR_TARGET=./test

function update()
{
    git submodule update --remote
}

function build()
{
    [ ! -d ${DIR_DOTGEN}/vendor ] && cd ${DIR_DOTGEN} && composer install && cd ${DIR}
    [ ! -d ${DIR_OUTPUT} ] && mkdir -p ${DIR_OUTPUT}
    php ${DIR_DOTGEN}/src/generator.php ${DIR_CONFIGS}/$(hostname).ini
}

function install()
{
    cp -rs ${DIR_OUTPUT}/* ${DIR_TARGET}/
}

function all()
{
    build
    install
}

$1