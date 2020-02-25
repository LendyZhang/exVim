#!/bin/bash

EXVIM_PATH="$(realpath -s "$(dirname "$0")/..")"
cd "${EXVIM_PATH}"

# download vim-plug.
echo "Download vim-plug."
curl -fLo vimfiles/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# download and install all plugins.
echo "Install plugins."
vim -u .vimrc.mini --cmd "set rtp=./vimfiles,\$VIMRUNTIME,./vimfiles/after" +PlugClean +PlugUpdate +qall

if [ -f ~/.vimrc ]; then
	echo "Backup ~/.vimrc to ~/.vimrc.bak."
	mv ~/.vimrc ~/.vimrc.bak
fi

echo "let g:exvim_custom_path='${EXVIM_PATH}/'" >> ~/.vimrc
echo "source ${EXVIM_PATH}/.vimrc"              >> ~/.vimrc

# finish
echo ""
echo "exVim installed successfully!"
