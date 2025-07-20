if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  # transparency
  mkdir -p ~/.config/nvim/plugin/after
  cp config/nvim/transparency.lua ~/.config/nvim/plugin/after/

  # gokyo
  cp config/nvim/catppuccin.lua ~/.config/nvim/lua/plugins/theme.lua

  # no animation
  cp config/nvim/snacks-animated-scrolling-off.lua ~/.config/nvim/lua/plugins/
  # monorepo look at git not package json
  cp config/nvim/monorepo.lua ~/.config/nvim/lua/plugins/

fi
