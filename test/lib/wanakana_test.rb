require 'test_helper'

class WanakanaTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wanakana::VERSION
  end
  
  def test_speed
    startTime = Date.new.to_time
    Wanakana.to_kana("aiueosashisusesonaninunenokakikukeko")
    endTime = Date.new.to_time
    elapsedTime = endTime-startTime;
    assert elapsedTime < 30, "Dang, that's fast! Romaji -> Kana in #{elapsedTime}ms" 
  end
end
