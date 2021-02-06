# hunspell.cr

* [Source](https://github.com/postmodern/hunspell.cr)
* [Issues](https://github.com/postmodern/hunspell.cr/issues)
* [Documentation](http://postmodern.github.io/docs/hunspell.cr)
* [Email](postmodern.mod3 at gmail.com)

[Crystal][crystal] bindings for [Hunspell][libhunspell]. Crystal port of the
Ruby [ffi-hunspell] gem and should be API compatible.

## Installation

1. Install `libhunspell`

   * Debian / Ubuntu:

         $ sudo apt install libhunspell-dev hunspell-en-us

   * RedHat / Fedora:

         $ sudo dnf install hunspell-devel hunspell-en

   * macOS:

         $ brew install hunspell

2. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     hunspell:
       github: your-github-user/hunspell.cr
   ```

3. Run `shards install`

## Examples

Open a dictionary:

```crystal
require "hunspell"
    
Hunspell.dict do |dict|
  # ...
end

Hunspell.dict("en_GB") do |dict|
  # ...
end

dict = Hunspell.dict("en_GB")
# ...
dict.close
```

Check if a word is valid:

```crystal
dict.check?("dog")
# => true

dict.check?("d0g")
# => false
```

Find the stems of a word:

```crystal
dict.stem("dogs")
# => ["dog"]
```

Suggest alternate spellings for a word:

```crystal
dict.suggest("arbitrage")
# => ["arbitrage", "arbitrages", "arbitrager", "arbitraged", "arbitrate"]
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/postmodern/hunspell.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Postmodern](https://github.com/postmodern) - creator and maintainer

[crystal]: https://crystal-lang.org/
[libhunspell]: http://hunspell.github.io/
[ffi-hunspell]: https://github.com/postmodern/ffi-hunspell#readme
