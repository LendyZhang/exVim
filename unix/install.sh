#!/bin/bash

# download vim-plug.
echo "Download vim-plug."
curl -fLo vimfiles/bundle/vim-plug/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# download and install all plugins.
echo "Install plugins."
vim -u .vimrc.mini --cmd "set rtp=./vimfiles,\$VIMRUNTIME,./vimfiles/after" +PlugClean +PlugUpdate +qall

echo "Please install nerd-fonts manually."

# finish
echo "|"
echo "exVim installed successfully!"
echo "|"
echo "You can run 'sh unix/gvim.sh' to preview exVim."
echo "You can also run 'sh unix/replace-my-vim.sh' to replace exVim with your Vim."
