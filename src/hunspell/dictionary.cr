require "../libhunspell"

module Hunspell
  #
  # Represents a dictionary for a specific language.
  #
  class Dictionary

    # The affix file extension
    AFF_EXT = "aff"

    # The dictionary file extension
    DIC_EXT = "dic"

    @ptr : LibHunspell::HunhandlePtr?

    getter(encoding : String) do
      String.new(LibHunspell.Hunspell_get_dic_encoding(self))
    end

    def initialize(@ptr : LibHunspell::HunhandlePtr)
    end

    #
    # Creates a new dictionary.
    #
    # @param [String] affix_path
    #   The path to the `.aff` file.
    #
    # @param [String] dic_path
    #   The path to the `.dic` file.
    #
    # @param [String] key
    #   The optional key for encrypted dictionary files.
    #
    # @raise [RuntimeError]
    #   Either the `.aff` or `.dic` files did not exist.
    #
    def initialize(affix_path : String, dic_path : String, key : String? = nil)
      unless File.file?(affix_path)
        raise(ArgumentError.new("invalid affix path #{affix_path.inspect}"))
      end

      unless File.file?(dic_path)
        raise(ArgumentError.new("invalid dic path #{dic_path.inspect}"))
      end

      initialize(
        if key
          LibHunspell.Hunspell_create_key(affix_path,dic_path,key)
        else
          LibHunspell.Hunspell_create(affix_path,dic_path)
        end
      )
    end

    #
    # Finalizes the underlying `libhunspell` handler pointer, if it already
    # hasn't been deallocated by `#close`.
    #
    def finalize
      close
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
    # @return [Dictionary]
    #   If no block is given, the open dictionary will be returned.
    #
    # @raise [ArgumentError]
    #   The dictionary files could not be found in any of the directories.
    #
    def self.open(name : String) : Dictionary
      Hunspell.directories.each do |dir|
        affix_path = File.join(dir,"#{name}.#{AFF_EXT}")
        dic_path   = File.join(dir,"#{name}.#{DIC_EXT}")

        if (File.file?(affix_path) && File.file?(dic_path))
          return new(affix_path,dic_path)
        end
      end

      raise(ArgumentError.new("unable to find the dictionary #{name.dump} in any of the directories"))
    end

    def self.open(name : String, &block : (Dictionary) ->)
      dict = open(name)

      yield dict

      dict.close
    end

    #
    # Determines if the dictionary is closed.
    #
    # @return [Boolean]
    #   Specifies whether the dictionary was closed.
    #
    def closed?
      @ptr.nil?
    end

    #
    # Adds a word to the dictionary.
    #
    # @param [String] word
    #   The word to add to the dictionary.
    #
    def add(word : String)
      LibHunspell.Hunspell_add(self,word)
    end

    def <<(word : String)
      add(word)
    end

    #
    # Adds a word to the dictionary with affix flags.
    #
    # @param [String] word
    #   The word to add to the dictionary.
    #
    # @param [String] example
    #   Affix flags.
    #
    # @since 0.4.0
    #
    def add_with_affix(word : String, example : String)
      LibHunspell.Hunspell_add_with_affix(self,word,example)
    end

    #
    # @deprecated Please use {#add_with_affix} instead.
    #
    def add_affix(word : Stirng, example : String)
      add_with_affix(word,example)
    end

    #
    # Load an extra dictionary file. The extra dictionaries use the
    # affix file of the allocated Hunspell object.
    #
    # Maximal number of extra dictionaries is limited in the source code (20)
    #
    # @param [String] dic_path
    #   The path to the extra `.dic` file.
    #
    # @raise [ArgumentError]
    #   The extra `.dic` file did not exist.
    #
    # @since 0.6.0
    #
    def add_dic(dic_path : String)
      unless File.file?(dic_path)
        raise(ArgumentError.new("invalid extra dictionary path #{dic_path.inspect}"))
      end

      LibHunspell.Hunspell_add_dic(self,dic_path)
    end

    #
    # Removes a word from the dictionary.
    #
    # @param [#to_s] word
    #   The word to remove.
    #
    def remove(word : String)
      LibHunspell.Hunspell_remove(self,word)
    end

    def delete(word : String)
      remove(word)
    end

    #
    # Checks if the word is validate.
    #
    # @param [#to_s] word
    #   The word in question.
    #
    # @return [Boolean]
    #   Specifies whether the word is valid.
    #
    def check?(word : String) : Bool
      LibHunspell.Hunspell_spell(self,word) != 0
    end

    def valid?(word : String)
      check?(word)
    end

    #
    # Finds the stems of a word.
    #
    # @param [#to_s] word
    #   The word in question.
    #
    # @return [Array<String>]
    #   The stems of the word.
    #
    def stem(word : String) : Array(String)
      stems = [] of String

      output = uninitialized LibC::Char **
      count = LibHunspell.Hunspell_stem(self,pointerof(output),word)

      if count > 0
        stems = Array.new(count) do |i|
          force_encoding(output[i])
        end

        LibHunspell.Hunspell_free_list(self,pointerof(output),count)
      end

      return stems
    end

    #
    # Suggests alternate spellings of a word.
    #
    # @param [#to_s] word
    #   The word in question.
    #
    # @return [Array<String>]
    #   The suggestions for the word.
    #
    def suggest(word : String) : Array(String)
      suggestions = [] of String

      output = uninitialized LibC::Char **
      count  = LibHunspell.Hunspell_suggest(self,pointerof(output),word)

      if count > 0
        suggestions = Array.new(count) do |i|
          force_encoding(output[i])
        end

        LibHunspell.Hunspell_free_list(self,pointerof(output),count)
      end

      return suggestions
    end

    #
    # Closes the dictionary.
    #
    # @return [nil]
    #
    def close
      @ptr.try do |ptr|
        LibHunspell.Hunspell_destroy(ptr)
        @ptr = nil
      end
    end

    #
    # Converts the dictionary to a pointer.
    #
    # @return [LibHunspell::HunhandlePtr]
    #   The pointer for the dictionary.
    #
    def to_unsafe : LibHunspell::HunhandlePtr
      @ptr.not_nil!
    end

    private def force_encoding(ptr : LibC::Char *) : String
      String.new(Bytes.new(ptr,LibC.strlen(ptr)),encoding)
    end

  end
end
