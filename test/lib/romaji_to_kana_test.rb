require 'test_helper'
require 'transliteration_table'

class CharacterConversionTest < Minitest::Test
  def test_poem_to_hiragana
    # // thanks to Yuki http://www.yesjapan.com/YJ6/question/1099/is-there-a-group-of-sentences-that-uses-every-hiragana
    opts = { useObsoleteKana: true }
    assert_equal "いろはにほへと", Wanakana.to_hiragana("IROHANIHOHETO", opts), "Even the colorful fregrant flowers"
    assert_equal "ちりぬるを", Wanakana.to_hiragana("CHIRINURUWO", opts), "Die sooner or later"
    assert_equal "わかよたれそ", Wanakana.to_hiragana("WAKAYOTARESO", opts), "Us who live in this world"
    assert_equal "つねならむ", Wanakana.to_hiragana("TSUNENARAMU", opts), "Cannot live forever, either."
    assert_equal "うゐのおくやま", Wanakana.to_hiragana("UWINOOKUYAMA", opts), "This transient mountain with shifts and changes,)"
    assert_equal "けふこえて", Wanakana.to_hiragana("KEFUKOETE", opts), "Today we are going to overcome, and reach the world of enlightenment."
    assert_equal "あさきゆめみし", Wanakana.to_hiragana("ASAKIYUMEMISHI", opts), "We are not going to have meaningless dreams"
    assert_equal "ゑひもせすん", Wanakana.to_hiragana("WEHIMOSESUN", opts), "nor become intoxicated with the fake world anymore"
  end
  
  def test_every_romaji_with_to_hiragana_and_katakana
    Table::TEST_TABLE.each do |array|
      romaji = array[0]
      hiragana = array[1]
      katakana = array[2]
      assert_equal hiragana, Wanakana.to_hiragana(romaji), "#{romaji} = #{hiragana}"
      assert_equal katakana, Wanakana.to_katakana(romaji), "#{romaji} = #{katakana}"
    end
  end
  
  def test_double_consonants_to_glottal_stops
    assert_equal "ばっば", Wanakana.to_hiragana("babba"), "double B"
    assert_equal "かっか", Wanakana.to_hiragana("cacca"), "double C"
    assert_equal "ちゃっちゃ", Wanakana.to_hiragana("chaccha"), "double Ch"
    assert_equal "だっだ", Wanakana.to_hiragana("dadda"), "double D"
    assert_equal "ふっふ", Wanakana.to_hiragana("fuffu"), "double F"
    assert_equal "がっが", Wanakana.to_hiragana("gagga"), "double G"
    assert_equal "はっは", Wanakana.to_hiragana("hahha"), "double H"
    assert_equal "じゃっじゃ", Wanakana.to_hiragana("jajja"), "double J"
    assert_equal "かっか", Wanakana.to_hiragana("kakka"), "double K"
    assert_equal "らっら", Wanakana.to_hiragana("lalla"), "double L"
    assert_equal "まっま", Wanakana.to_hiragana("mamma"), "double M"
    assert_equal "なんな", Wanakana.to_hiragana("nanna"), "double N"
    assert_equal "ぱっぱ", Wanakana.to_hiragana("pappa"), "double P"
    assert_equal "くぁっくぁ", Wanakana.to_hiragana("qaqqa"), "double Q"
    assert_equal "らっら", Wanakana.to_hiragana("rarra"), "double R"
    assert_equal "さっさ", Wanakana.to_hiragana("sassa"), "double S"
    assert_equal "しゃっしゃ", Wanakana.to_hiragana("shassha"), "double Sh"
    assert_equal "たった", Wanakana.to_hiragana("tatta"), "double T"
    assert_equal "つっつ", Wanakana.to_hiragana("tsuttsu"), "double Ts"
    assert_equal "ゔぁっゔぁ", Wanakana.to_hiragana("vavva"), "double V"
    assert_equal "わっわ", Wanakana.to_hiragana("wawwa"), "double W"
    assert_equal "やっや", Wanakana.to_hiragana("yayya"), "double X"
    assert_equal "ざっざ", Wanakana.to_hiragana("zazza"), "double Z"
  end
  
  def test_to_kana
    assert_equal Wanakana.to_hiragana("onaji"), Wanakana.to_kana("onaji"), "Lowercase characters are transliterated to hiragana."
    assert_equal Wanakana.to_katakana("onaji"), Wanakana.to_kana("ONAJI"), "Uppercase characters are transliterated to katakana."
    assert_equal "ワにカに", Wanakana.to_kana("WaniKani"), "WaniKani -> ワにカに - Mixed case uses the first character for each sylable."
    assert_equal "ワにカに アいウえオ 鰐蟹 12345 @#$%", Wanakana.to_kana("ワにカに AiUeO 鰐蟹 12345 @#$%"), "Non-romaji will be passed through."
  end
  
  def test_converting_kana_to_kana
    assert_equal "ばける", Wanakana.to_hiragana("バケル"), "katakana -> hiragana"
    assert_equal "バケル", Wanakana.to_katakana("ばける"), "hiragana -> katakana"
  end
  
  def test_case_sensitivity
    assert_equal Wanakana.to_hiragana("AIUEO"), Wanakana.to_hiragana("aiueo"), "cAse DoEsn'T MatTER for toHiragana()"
    assert_equal Wanakana.to_katakana("AIUEO"), Wanakana.to_katakana("aiueo"), "cAse DoEsn'T MatTER for toKatakana()"
    refute_equal Wanakana.to_kana("AIUEO"), Wanakana.to_kana("aiueo"), "Case DOES matter for toKana()"
  end
  
  def test_bogus_character_sequences
    assert_equal "ちゃ", Wanakana.to_kana("chya"), "Non bogus sequences work"
    assert_equal "chyx", Wanakana.to_kana("chyx"), "Bogus sequences do not work"
    assert_equal "shyp", Wanakana.to_kana("shyp"), "Bogus sequences do not work"
    assert_equal "ltsb", Wanakana.to_kana("ltsb"), "Bogus sequences do not work"
  end
  
  def test_punctuation
    assert_equal ",ワニ。カニ!", Wanakana.to_katakana(",わに。かに!"), "allows punctuation converting from hiragana to katakana"
    assert_equal "、わに。かに！", Wanakana.to_kana(",wani.kani!"), "allows punctuation converting from romaji to kana"
    assert_equal "ー。、（）「」？！", Wanakana.to_kana("-.,()“”?!"), "Japanese: dash period comma parentheses quotes question exclamation"
  end
end