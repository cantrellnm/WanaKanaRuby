require 'test_helper'

class CharacterTypeTest < Minitest::Test
  def test_is_hiragana
    assert Wanakana.is_hiragana?("あ"), "あ is hiragana"
    assert !Wanakana.is_hiragana?("ア"), "ア is not hiragana"
    assert !Wanakana.is_hiragana?("A"), "A is not hiragana"
    assert !Wanakana.is_hiragana?("あア"), "あア is not hiragana"
    assert Wanakana.is_hiragana?("ああ"), "ああ is hiragana"
  end
  
  def test_is_katakana
    assert !Wanakana.is_katakana?("あ"), "あ is not katakana"
    assert  Wanakana.is_katakana?("ア"), "ア is katakana"
    assert !Wanakana.is_katakana?("A"), "A is not katakana"
    assert !Wanakana.is_katakana?("あア"), "あア is not katakana"
    assert  Wanakana.is_katakana?("アア"), "アア is katakana"
  end
  
  def test_is_kana
    assert  Wanakana.is_kana?("あ"), "あ is kana"
    assert  Wanakana.is_kana?("ア"), "ア is kana"
    assert !Wanakana.is_kana?("A"), "A is not kana"
    assert  Wanakana.is_kana?("あア"), "あア is kana"
    assert !Wanakana.is_kana?("あAア"), "あAア is not kana"
  end
  
  def test_is_romaji
    assert !Wanakana.is_romaji?("あ"), "あ is not romaji"
    assert !Wanakana.is_romaji?("ア"), "ア is not romaji"
    assert  Wanakana.is_romaji?("A"), "A is romaji"
    assert !Wanakana.is_romaji?("あア"), "あア is not romaji"
    assert !Wanakana.is_romaji?("Aア"), "Aア is not romaji"
    assert  Wanakana.is_romaji?("ABC"), "ABC is romaji"
    assert  Wanakana.is_romaji?("xYz"), "xYz is romaji"
  end
end