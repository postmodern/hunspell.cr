require "./hunspell/dictionary"

module Hunspell
  # The language to default to, if no 'LANG' env variable was set.
  DEFAULT_LANG = ENV.fetch("LANG","en_US.UTF-8").split('.',2).first

  #
  # The default language.
  #
  # @return [String]
  #   The name of the default language.
  #
  class_property lang : String = DEFAULT_LANG

  # The directory name used to store user installed dictionaries.
  USER_DIR = ".hunspell_default"

  # Known directories to search within for dictionaries.
  KNOWN_DIRECTORIES = [
    # User
    File.join(Path.home,USER_DIR),
    # OS X brew-instlled hunspell
    File.join(Path.home,"Library/Spelling"),
    "/Library/Spelling",
    # Debian
    "/usr/local/share/myspell/dicts",
    "/usr/share/myspell/dicts",
    # Ubuntu
    "/usr/share/hunspell",
    # Fedora
    "/usr/local/share/myspell",
    "/usr/share/myspell",
    # Mac Ports
    "/opt/local/share/hunspell",
    "/opt/share/hunspell"
  ]

  #
  # The dictionary directories to search for dictionary files.
  #
  # @return [Array<String, Pathname>]
  #   The directory paths.
  #
  # @since 0.2.0
  #
  class_property(directories : Array(String)) do
    KNOWN_DIRECTORIES.select do |path|
      File.directory?(path)
    end
  end

  #
  # Opens a Hunspell dictionary.
  #
  # @param [Symbol, String] name
  #   The name of the dictionary to open.
  #
  # @return [nil]
  #
  def self.dict(name=self.lang) : Dictionary
    Dictionary.open(name)
  end

  #
  # Opens a Hunspell dictionary.
  #
  # @param [Symbol, String] name
  #   The name of the dictionary to open.
  #
  # @yield [dict]
  #   The given block will be passed the Hunspell dictionary.
  #
  # @yieldparam [Dictionary] dict
  #   The opened dictionary.
  #
  # @return [nil]
  #
  def self.dict(name=self.lang, &block : (Dictionary) ->)
    Dictionary.open(name,&block)
  end
end
