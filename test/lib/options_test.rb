require 'test_helper'

class OptionsTest < Minitest::Test
  def test_use_obsolete_kana
    opts = {useObsoleteKana: true}
    assert_equal 'ゐ', Wanakana.to_hiragana('wi', opts), "wi = ゐ (when useObsoleteKana is true)"
    assert_equal 'ゑ', Wanakana.to_hiragana('we', opts), "we = ゑ"
    assert_equal 'ヰ', Wanakana.to_katakana('wi', opts), "WI = ヰ"
    assert_equal 'ヱ', Wanakana.to_katakana('we', opts), "WE = ヱ"
  
    opts = {useObsoleteKana: false}
    assert_equal 'うぃ', Wanakana.to_hiragana('wi', opts), "wi = うぃ when useObsoleteKana is false"
    assert_equal 'うぃ', Wanakana.to_hiragana('wi'), "useObsoleteKana is false by default"
  end
  
  # def test_IMEMode
  #   # Not included in this port
  # end
  
  def test_apostrophes_for_consonant_vowel_combos
    assert_equal "on'yomi" , Wanakana.to_romaji('おんよみ'), "おんよみ = on'yomi"
    assert_equal "n'yo n'a n'yu" , Wanakana.to_romaji('んよ んあ　んゆ'), "Checking other combinations"
  end
  
  def test_options_use_default_options
    Wanakana.default_options(useObsoleteKana: true)
    assert_equal 'ゐ', Wanakana.to_hiragana('wi'), "Overwrite default (temporarily)"
    opts = {IMEMode: true}
    assert_equal 'ゐ', Wanakana.to_hiragana('wi', opts), "Defaults aren't overwritten by being omitted"
    Wanakana.default_options(useObsoleteKana: false) 
  end
end