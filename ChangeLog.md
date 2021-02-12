### 0.1.1 / 2021-02-11

* Add `Hunspell::Dictionary#finalize` to handle closing and deallocating
  the libhunspell handle pointer when the dictionary object is garbage
  collected.

### 0.1.0 / 2021-02-11

* Initial release.
  * Port of [ffi-hunspell] 0.6.0.

[ffi-hunspell]: https://github.com/postmodern/ffi-hunspell
