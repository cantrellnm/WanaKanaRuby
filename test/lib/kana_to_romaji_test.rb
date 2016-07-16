require 'test_helper'

class KanaToRomajiTest < Minitest::Test
  def test_to_romaji
    assert_equal "wanikani ga sugoi da", Wanakana.to_romaji("ワニカニ　ガ　スゴイ　ダ"), "Convert katakana to romaji. convertKatakanaToUppercase is false by default"
    assert_equal "wanikani ga sugoi da", Wanakana.to_romaji("わにかに　が　すごい　だ"), "Convert hiragana to romaji"
    assert_equal "wanikani ga sugoi da", Wanakana.to_romaji("ワニカニ　が　すごい　だ"), "Convert mixed kana to romaji"
    assert_equal "WANIKANI", Wanakana.to_romaji("ワニカニ", {convertKatakanaToUppercase: true}), "Use the convertKatakanaToUppercase flag to preserve casing. Works for katakana."
    assert_equal "wanikani", Wanakana.to_romaji("わにかに", {convertKatakanaToUppercase: true}), "Use the convertKatakanaToUppercase flag to preserve casing. Works for hiragana."
    assert_equal "WANIKANI ga sugoi da", Wanakana.to_romaji("ワニカニ　が　すごい　だ", {convertKatakanaToUppercase: true}), "Use the convertKatakanaToUppercase flag to preserve casing. Works for mixed kana."
    refute_equal "wanikani ga sugoi da", Wanakana.to_romaji("わにかにがすごいだ"), "Spaces must be manually entered"
  end
  
  def test_poem_to_romaji
    assert_equal "irohanihoheto", Wanakana.to_romaji("いろはにほへと"), "Even the colorful fregrant flowers"
    assert_equal "chirinuruwo", Wanakana.to_romaji("ちりぬるを"), "Die sooner or later"
    assert_equal "wakayotareso", Wanakana.to_romaji("わかよたれそ"), "Us who live in this world"
    assert_equal "tsunenaramu", Wanakana.to_romaji("つねならむ"), "Cannot live forever, either."
    assert_equal "uwinookuyama", Wanakana.to_romaji("うゐのおくやま"), "This transient mountain with shifts and changes,)"
    assert_equal "kefukoete", Wanakana.to_romaji("けふこえて"), "Today we are going to overcome, and reach the world of enlightenment."
    assert_equal "asakiyumemishi", Wanakana.to_romaji("あさきゆめみし"), "We are not going to have meaningless dreams"
    assert_equal "wehimosesun", Wanakana.to_romaji("ゑひもせすん"), "nor become intoxicated with the fake world anymore"
  end
  
  def test_double_n_and_consonants
    assert_equal "kinnikuman", Wanakana.to_romaji("きんにくまん"), "Double and single n"
    assert_equal "nnninninnyan'yan", Wanakana.to_romaji("んんにんにんにゃんやん"), "N extravaganza"
    assert_equal "kappa tatta shusshu chaccha yattsu", Wanakana.to_romaji("かっぱ　たった　しゅっしゅ ちゃっちゃ　やっつ"), "Double consonants"
  end
  
  def test_small_kana
    assert_equal "", Wanakana.to_romaji("っ"), "Small tsu doesn't transliterate"
    assert_equal "ya", Wanakana.to_romaji("ゃ"), "Small ya"
    assert_equal "yu", Wanakana.to_romaji("ゅ"), "Small yu"
    assert_equal "yo", Wanakana.to_romaji("ょ"), "Small yo"
    assert_equal "a", Wanakana.to_romaji("ぁ"), "Small a"
    assert_equal "i", Wanakana.to_romaji("ぃ"), "Small i"
    assert_equal "u", Wanakana.to_romaji("ぅ"), "Small u"
    assert_equal "e", Wanakana.to_romaji("ぇ"), "Small e"
    assert_equal "o", Wanakana.to_romaji("ぉ"), "Small o"
    assert_equal "ka", Wanakana.to_romaji("ヶ"), "Small ke (ka)"
    assert_equal "ka", Wanakana.to_romaji("ヵ"), "Small ka"
    assert_equal "wa", Wanakana.to_romaji("ゎ"), "Small wa"
  end
  
  def test_punctuation
    assert_equal " -.,()“”?!", Wanakana.to_romaji("　ー。、（）「」？！"), "English: space dash period comma parentheses quotes question exclamation"
  end
end