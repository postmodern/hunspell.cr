@[Link("hunspell")]
lib LibHunspell
  alias Char = LibC::Char
  alias Int = LibC::Int
  alias HunhandlePtr = Void *

  fun Hunspell_create(affpath : Char *, dpath : Char *) : HunhandlePtr
  fun Hunspell_create_key(affpath : Char *, dpath : Char *, key : Char *) : HunhandlePtr
  fun Hunspell_destroy(pHunspell : HunhandlePtr) : Void
  fun Hunspell_add_dic(pHunspell : HunhandlePtr, dpath : Char *) : Int
  fun Hunspell_spell(pHunspell : HunhandlePtr, word : Char *) : Int
  fun Hunspell_get_dic_encoding(pHunspell : HunhandlePtr) : Char *
  fun Hunspell_suggest(pHunspell : HunhandlePtr, slst : Char ***, word : Char *) : Int
  fun Hunspell_analyze(pHunspell : HunhandlePtr, slst : Char ***, word : Char *) : Int
  fun Hunspell_stem(pHunspell : HunhandlePtr, slst : Char ***, word : Char *) : Int
  fun Hunspell_stem2(pHunspell : HunhandlePtr, slst : Char ***, desc : Char **, n : Int) : Int
  fun Hunspell_generate(pHunspell : HunhandlePtr, slst : Char ***, word : Char *, word2 : Char *) : Int
  fun Hunspell_generate2(pHunspell : HunhandlePtr, slst : Char ***, word : Char *, desc : Char **, n : Int) : Int
  fun Hunspell_add(pHunspell : HunhandlePtr, word : Char *) : Int
  fun Hunspell_add_with_affix(pHunspell : HunhandlePtr, word : Char *, example : Char *) : Int
  fun Hunspell_remove(pHunspell : HunhandlePtr, word : Char *) : Int
  fun Hunspell_free_list(pHunspell : HunhandlePtr, slst : Char ***, n : Int) : Void
end
