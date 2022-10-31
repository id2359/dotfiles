#!/bin/sh
if [ -d ~/.vim ]; then
  rm -rf ~/.vim
fi

mkdir -p ~/.vim/bundle/
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~/.vim/bundle/ && git clone --recursive https://github.com/davidhalter/jedi-vim.git
cp ~/.vimrc ~/vimrc.old
rm ~/.vimrc
cp  ~/src/dotfiles/vim/vim.symlink ~/.vimrc


