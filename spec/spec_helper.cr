require "../src/hunspell"
require "spectator"

if (hunspell_root = ENV["HUNSPELL_ROOT"]?)
  Hunspell.directories << hunspell_root
end
