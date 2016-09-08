#!/bin/bash

DIR=$(pwd)
DIR_DOTGEN=./dotgen
DIR_CONFIGS=./configs
DIR_OUTPUT=./output

[ ! -d ${DIR_DOTGEN}/vendor ] && cd ${DIR_DOTGEN} && composer install && cd ${DIR}
[ ! -d ${DIR_OUTPUT} ] && mkdir -p ${DIR_OUTPUT}
php ${DIR_DOTGEN}/src/generator.php ${DIR_CONFIGS}/$(hostname).ini
