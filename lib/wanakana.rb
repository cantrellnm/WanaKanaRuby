require "wanakana/version"

module Wanakana
  # based on wanakana.js version 1.3.7

  LOWERCASE_START = 0x61;
  LOWERCASE_END = 0x7A;
  UPPERCASE_START = 0x41;
  UPPERCASE_END = 0x5A;
  HIRAGANA_START = 0x3041;
  HIRAGANA_END = 0x3096;
  KATAKANA_START = 0x30A1;
  KATAKANA_END = 0x30FA;
  LOWERCASE_FULLWIDTH_START = 0xFF41;
  LOWERCASE_FULLWIDTH_END = 0xFF5A;
  UPPERCASE_FULLWIDTH_START = 0xFF21;
  UPPERCASE_FULLWIDTH_END = 0xFF3A;

  #
  # .bind, .unbind, ._onInput excluded from this port and IMEMode commented out
  #
  
  @@default_options = {
    useObsoleteKana: false,
    convertKatakanaToUppercase: false
    # IMEMode: false
  }
  
  def self.default_options(opt=nil)
    @@default_options = extend(opt, @@default_options) if opt
    @@default_options
  end

  def self.is_hiragana?(input)
    chars = input.split('')
    are_hira = chars.select { |c| is_char_hiragana?(c) }
    chars.length == are_hira.length
  end

  def self.is_katakana?(input)
    chars = input.split('')
    are_kata = chars.select { |c| is_char_katakana?(c) }
    chars.length == are_kata.length
  end

  def self.is_kana?(input)
    chars = input.split('')
    are_kana = chars.select { |c| is_char_hiragana?(c) || is_char_katakana?(c) }
    chars.length == are_kana.length
  end

  def self.is_romaji?(input)
    chars = input.split('')
    are_roma = chars.select { |c| !is_char_hiragana?(c) && !is_char_katakana?(c) }
    chars.length == are_roma.length
  end

  def self.to_hiragana(input, options={})
    return romaji_to_hiragana(input, options) if is_romaji?(input)
    return katakana_to_hiragana(input) if is_katakana?(input)
    input
  end

  def self.to_katakana(input, options={})
    return hiragana_to_katakana(input) if is_hiragana?(input)
    if is_romaji?(input)
      input = romaji_to_hiragana(input, options)
      return hiragana_to_katakana(input)
    end
    input
  end

  def self.to_kana(input, options={})
    romaji_to_kana(input, options)
  end

  def self.to_romaji(input, options={})
    hiragana_to_romaji(input, options)
  end
  
  protected

  # For adding defaults to options hash 
  def self.extend(target, source)
    return source if !target || target.empty?
    source.each do |key, value|
      target[key] = value unless target.has_key?(key)
    end
    target
  end

  def self.is_char_in_range?(char, start, finish)
    code = char[0].ord
    code.between?(start, finish)
  end

  def self.is_char_vowel?(char, includeY=true)
    return false unless char
    regexp = (includeY ? /[aeiouy]/ : /[aeiou]/)
    char.downcase[0] =~ regexp
  end

  def self.is_char_consonant?(char, includeY=true)
    return false unless char
    regexp = (includeY ? /[bcdfghjklmnpqrstvwxyz]/ : /[bcdfghjklmnpqrstvwxz]/)
    char.downcase[0] =~ regexp
  end

  def self.is_char_katakana?(char)
    is_char_in_range?(char, Wanakana::KATAKANA_START, Wanakana::KATAKANA_END)
  end

  def self.is_char_hiragana?(char)
    is_char_in_range?(char, Wanakana::HIRAGANA_START, Wanakana::HIRAGANA_END)
  end

  def self.is_char_kana?(char)
    is_char_hiragana?(char) || is_char_katakana?(char)
  end

  def self.is_char_not_kana?(char)
    !is_char_hiragana?(char) && !is_char_katakana?(char)
  end

  def self.convert_full_width_chars_to_ASCII(string)
    chars = string.split('')
    chars.map! do |char|
      code = char[0].ord
      if is_char_in_range?(char, Wanakana::LOWERCASE_FULLWIDTH_START, Wanakana::LOWERCASE_FULLWIDTH_END)
        char = [code - Wanakana::LOWERCASE_FULLWIDTH_START + Wanakana::LOWERCASE_START].pack('U*')
      elsif is_char_in_range?(char, Wanakana::UPPERCASE_FULLWIDTH_START, Wanakana::UPPERCASE_FULLWIDTH_END)
        char = [code - Wanakana::UPPERCASE_FULLWIDTH_START + Wanakana::UPPERCASE_START].pack('U*')
      end
    end
    chars.join('')
  end

  def self.katakana_to_hiragana(kata)
    chars = kata.split('')
    chars.map! do |char|
      if is_char_katakana?(char)
        code = char[0].ord + (Wanakana::HIRAGANA_START - Wanakana::KATAKANA_START)
        char = [code].pack('U*')
      else
        char
      end
    end
    chars.join('')
  end

  def self.hiragana_to_katakana(hira)
    chars = hira.split('')
    chars.map! do |char|
      if is_char_hiragana?(char)
        code = char[0].ord + (Wanakana::KATAKANA_START - Wanakana::HIRAGANA_START)
        char = [code].pack('U*')
      else
        char
      end
    end
    chars.join('')
  end
  
  def self.hiragana_to_romaji(hira, options)
    options = extend(options, @@default_options)
    len = hira.length
    roma = []
    cursor = 0
    chunk_size = 0
    chunk = nil
    roma_char = nil
    next_char_is_double_consonant = false
    is_kata = false
    while cursor < len do
      chunk_size = [2, len - cursor].min
      while chunk_size > 0 do
        chunk = hira.slice(cursor, chunk_size)
        if is_katakana?(chunk)
          is_kata = true
          chunk = katakana_to_hiragana(chunk)
        end
        if (chunk[0] == "っ" && chunk_size == 1 && cursor < (len - 1))
          next_char_is_double_consonant = true
          roma_char = ''
          break
        end
        roma_char = Wanakana::J_TO_R[chunk.to_sym]
        if (roma_char && next_char_is_double_consonant)
          roma_char = roma_char[0].concat(roma_char)
          next_char_is_double_consonant = false
        end
        if roma_char && is_kata
          roma_char = roma_char.upcase if options[:convertKatakanaToUppercase]
        end
        is_kata = false
        break if roma_char
        chunk_size -= 1
      end
      roma_char = chunk unless roma_char
      roma.push(roma_char)
      cursor += chunk_size > 0 ? chunk_size : 1
    end
    roma.join('')
  end

  def self.romaji_to_hiragana(roma, options)
    romaji_to_kana(roma, options, true)
  end
  
  def self.romaji_to_kana(roma, options, ignore_case=false)
    options = extend(options, @@default_options)
    len = roma.length
    kana = []
    cursor = 0
    chunk_size = 0
    chunk = nil
    kana_char = nil
    chunk_LC = nil
    set_chunk = lambda {
      chunk = roma.slice(cursor, chunk_size)
      chunk_LC = chunk.downcase
    }
    is_char_upper_case = lambda { |char| is_char_in_range?(char, Wanakana::UPPERCASE_START, Wanakana::UPPERCASE_END) }
    while cursor < len do
      chunk_size = [3, len - cursor].min
      while chunk_size > 0 do
        set_chunk.call()
        if (Wanakana::FOUR_CHARACTER_EDGE_CASES.include?(chunk_LC) && (len - cursor) >= 4)
          chunk_size += 1
          set_chunk.call()
        else
          if chunk_LC[0] == 'n'
            # if (options[:IMEMode] && chunk_LC[1] == "'" && chunk_size ==2)
            #   kana_char = 'ん'
            #   break
            # end
            if (is_char_consonant?(chunk_LC[1], false) && is_char_vowel?(chunk_LC[2]))
              chunk_size = 1
              set_chunk.call()
            end
          end
          if (chunk_LC[0] != 'n' && is_char_consonant?(chunk_LC[0]) && chunk[0] == chunk[1])
            chunk_size = 1
            chunk_LC = chunk = (is_char_in_range?(chunk[0], Wanakana::UPPERCASE_START, Wanakana::UPPERCASE_END) ? 'ッ' : 'っ')
          end
        end
        kana_char = Wanakana::R_TO_J[chunk_LC.to_sym]
        break if kana_char
        chunk_size -= chunk_size == 4 ? 2 : 1
      end
      kana_char = chunk unless kana_char
      if options[:useObsoleteKana]
        kana_char = 'ゐ' if chunk_LC == 'wi'
        kana_char = 'ゑ' if chunk_LC == 'we'
      end
      # if (options[:IMEMode] && chunk_LC[0] == 'n')
      #   kana_char = chunk[0] if ( roma[cursor+1].downcase == 'y' &&
      #                             !is_char_vowel?(roma[cursor + 2]) ||
      #                             cursor == (len - 1) ||
      #                             is_kana?(roma[cursor + 1]) )
      # end
      unless ignore_case
        kana_char = hiragana_to_katakana(kana_char) if is_char_upper_case.call(chunk[0])
      end
      kana.push(kana_char)
      cursor += chunk_size > 0 ? chunk_size : 1
    end
    kana.join('')
  end

  FOUR_CHARACTER_EDGE_CASES = ['lts', 'chy', 'shy']

  R_TO_J = {
    a: 'あ',
    i: 'い',
    u: 'う',
    e: 'え',
    o: 'お',
    yi: 'い',
    wu: 'う',
    whu: 'う',
    xa: 'ぁ',
    xi: 'ぃ',
    xu: 'ぅ',
    xe: 'ぇ',
    xo: 'ぉ',
    xyi: 'ぃ',
    xye: 'ぇ',
    ye: 'いぇ',
    wha: 'うぁ',
    whi: 'うぃ',
    whe: 'うぇ',
    who: 'うぉ',
    wi: 'うぃ',
    we: 'うぇ',
    va: 'ゔぁ',
    vi: 'ゔぃ',
    vu: 'ゔ',
    ve: 'ゔぇ',
    vo: 'ゔぉ',
    vya: 'ゔゃ',
    vyi: 'ゔぃ',
    vyu: 'ゔゅ',
    vye: 'ゔぇ',
    vyo: 'ゔょ',
    ka: 'か',
    ki: 'き',
    ku: 'く',
    ke: 'け',
    ko: 'こ',
    lka: 'ヵ',
    lke: 'ヶ',
    xka: 'ヵ',
    xke: 'ヶ',
    kya: 'きゃ',
    kyi: 'きぃ',
    kyu: 'きゅ',
    kye: 'きぇ',
    kyo: 'きょ',
    ca: 'か',
    ci: 'き',
    cu: 'く',
    ce: 'け',
    co: 'こ',
    lca: 'ヵ',
    lce: 'ヶ',
    xca: 'ヵ',
    xce: 'ヶ',
    qya: 'くゃ',
    qyu: 'くゅ',
    qyo: 'くょ',
    qwa: 'くぁ',
    qwi: 'くぃ',
    qwu: 'くぅ',
    qwe: 'くぇ',
    qwo: 'くぉ',
    qa: 'くぁ',
    qi: 'くぃ',
    qe: 'くぇ',
    qo: 'くぉ',
    kwa: 'くぁ',
    qyi: 'くぃ',
    qye: 'くぇ',
    ga: 'が',
    gi: 'ぎ',
    gu: 'ぐ',
    ge: 'げ',
    go: 'ご',
    gya: 'ぎゃ',
    gyi: 'ぎぃ',
    gyu: 'ぎゅ',
    gye: 'ぎぇ',
    gyo: 'ぎょ',
    gwa: 'ぐぁ',
    gwi: 'ぐぃ',
    gwu: 'ぐぅ',
    gwe: 'ぐぇ',
    gwo: 'ぐぉ',
    sa: 'さ',
    si: 'し',
    shi: 'し',
    su: 'す',
    se: 'せ',
    so: 'そ',
    za: 'ざ',
    zi: 'じ',
    zu: 'ず',
    ze: 'ぜ',
    zo: 'ぞ',
    ji: 'じ',
    sya: 'しゃ',
    syi: 'しぃ',
    syu: 'しゅ',
    sye: 'しぇ',
    syo: 'しょ',
    sha: 'しゃ',
    shu: 'しゅ',
    she: 'しぇ',
    sho: 'しょ',
    shya: 'しゃ',
    shyu: 'しゅ',
    shye: 'しぇ',
    shyo: 'しょ',
    swa: 'すぁ',
    swi: 'すぃ',
    swu: 'すぅ',
    swe: 'すぇ',
    swo: 'すぉ',
    zya: 'じゃ',
    zyi: 'じぃ',
    zyu: 'じゅ',
    zye: 'じぇ',
    zyo: 'じょ',
    ja: 'じゃ',
    ju: 'じゅ',
    je: 'じぇ',
    jo: 'じょ',
    jya: 'じゃ',
    jyi: 'じぃ',
    jyu: 'じゅ',
    jye: 'じぇ',
    jyo: 'じょ',
    ta: 'た',
    ti: 'ち',
    tu: 'つ',
    te: 'て',
    to: 'と',
    chi: 'ち',
    tsu: 'つ',
    ltu: 'っ',
    xtu: 'っ',
    tya: 'ちゃ',
    tyi: 'ちぃ',
    tyu: 'ちゅ',
    tye: 'ちぇ',
    tyo: 'ちょ',
    cha: 'ちゃ',
    chu: 'ちゅ',
    che: 'ちぇ',
    cho: 'ちょ',
    cya: 'ちゃ',
    cyi: 'ちぃ',
    cyu: 'ちゅ',
    cye: 'ちぇ',
    cyo: 'ちょ',
    chya: 'ちゃ',
    chyu: 'ちゅ',
    chye: 'ちぇ',
    chyo: 'ちょ',
    tsa: 'つぁ',
    tsi: 'つぃ',
    tse: 'つぇ',
    tso: 'つぉ',
    tha: 'てゃ',
    thi: 'てぃ',
    thu: 'てゅ',
    the: 'てぇ',
    tho: 'てょ',
    twa: 'とぁ',
    twi: 'とぃ',
    twu: 'とぅ',
    twe: 'とぇ',
    two: 'とぉ',
    da: 'だ',
    di: 'ぢ',
    du: 'づ',
    de: 'で',
    :do => 'ど',
    dya: 'ぢゃ',
    dyi: 'ぢぃ',
    dyu: 'ぢゅ',
    dye: 'ぢぇ',
    dyo: 'ぢょ',
    dha: 'でゃ',
    dhi: 'でぃ',
    dhu: 'でゅ',
    dhe: 'でぇ',
    dho: 'でょ',
    dwa: 'どぁ',
    dwi: 'どぃ',
    dwu: 'どぅ',
    dwe: 'どぇ',
    dwo: 'どぉ',
    na: 'な',
    ni: 'に',
    nu: 'ぬ',
    ne: 'ね',
    no: 'の',
    nya: 'にゃ',
    nyi: 'にぃ',
    nyu: 'にゅ',
    nye: 'にぇ',
    nyo: 'にょ',
    ha: 'は',
    hi: 'ひ',
    hu: 'ふ',
    he: 'へ',
    ho: 'ほ',
    fu: 'ふ',
    hya: 'ひゃ',
    hyi: 'ひぃ',
    hyu: 'ひゅ',
    hye: 'ひぇ',
    hyo: 'ひょ',
    fya: 'ふゃ',
    fyu: 'ふゅ',
    fyo: 'ふょ',
    fwa: 'ふぁ',
    fwi: 'ふぃ',
    fwu: 'ふぅ',
    fwe: 'ふぇ',
    fwo: 'ふぉ',
    fa: 'ふぁ',
    fi: 'ふぃ',
    fe: 'ふぇ',
    fo: 'ふぉ',
    fyi: 'ふぃ',
    fye: 'ふぇ',
    ba: 'ば',
    bi: 'び',
    bu: 'ぶ',
    be: 'べ',
    bo: 'ぼ',
    bya: 'びゃ',
    byi: 'びぃ',
    byu: 'びゅ',
    bye: 'びぇ',
    byo: 'びょ',
    pa: 'ぱ',
    pi: 'ぴ',
    pu: 'ぷ',
    pe: 'ぺ',
    po: 'ぽ',
    pya: 'ぴゃ',
    pyi: 'ぴぃ',
    pyu: 'ぴゅ',
    pye: 'ぴぇ',
    pyo: 'ぴょ',
    ma: 'ま',
    mi: 'み',
    mu: 'む',
    me: 'め',
    mo: 'も',
    mya: 'みゃ',
    myi: 'みぃ',
    myu: 'みゅ',
    mye: 'みぇ',
    myo: 'みょ',
    ya: 'や',
    yu: 'ゆ',
    yo: 'よ',
    xya: 'ゃ',
    xyu: 'ゅ',
    xyo: 'ょ',
    ra: 'ら',
    ri: 'り',
    ru: 'る',
    re: 'れ',
    ro: 'ろ',
    rya: 'りゃ',
    ryi: 'りぃ',
    ryu: 'りゅ',
    rye: 'りぇ',
    ryo: 'りょ',
    la: 'ら',
    li: 'り',
    lu: 'る',
    le: 'れ',
    lo: 'ろ',
    lya: 'りゃ',
    lyi: 'りぃ',
    lyu: 'りゅ',
    lye: 'りぇ',
    lyo: 'りょ',
    wa: 'わ',
    wo: 'を',
    lwe: 'ゎ',
    xwa: 'ゎ',
    n: 'ん',
    nn: 'ん',
    'n '.to_sym => 'ん',
    xn: 'ん',
    ltsu: 'っ',
    '-'.to_sym => 'ー',
    '.'.to_sym => '。',
    ','.to_sym => '、',
    '('.to_sym => '（',
    ')'.to_sym => '）',
    '“'.to_sym => '「',
    '”'.to_sym => '」',
    '?'.to_sym => '？',
    '!'.to_sym => '！'
  }

  J_TO_R = {
    あ: 'a',
    い: 'i',
    う: 'u',
    え: 'e',
    お: 'o',
    ゔぁ: 'va',
    ゔぃ: 'vi',
    ゔ: 'vu',
    ゔぇ: 've',
    ゔぉ: 'vo',
    か: 'ka',
    き: 'ki',
    きゃ: 'kya',
    きぃ: 'kyi',
    きゅ: 'kyu',
    く: 'ku',
    け: 'ke',
    こ: 'ko',
    が: 'ga',
    ぎ: 'gi',
    ぐ: 'gu',
    げ: 'ge',
    ご: 'go',
    ぎゃ: 'gya',
    ぎぃ: 'gyi',
    ぎゅ: 'gyu',
    ぎぇ: 'gye',
    ぎょ: 'gyo',
    さ: 'sa',
    す: 'su',
    せ: 'se',
    そ: 'so',
    ざ: 'za',
    ず: 'zu',
    ぜ: 'ze',
    ぞ: 'zo',
    し: 'shi',
    しゃ: 'sha',
    しゅ: 'shu',
    しょ: 'sho',
    じ: 'ji',
    じゃ: 'ja',
    じゅ: 'ju',
    じょ: 'jo',
    た: 'ta',
    ち: 'chi',
    ちゃ: 'cha',
    ちゅ: 'chu',
    ちょ: 'cho',
    つ: 'tsu',
    て: 'te',
    と: 'to',
    だ: 'da',
    ぢ: 'di',
    づ: 'du',
    で: 'de',
    ど: 'do',
    な: 'na',
    に: 'ni',
    にゃ: 'nya',
    にゅ: 'nyu',
    にょ: 'nyo',
    ぬ: 'nu',
    ね: 'ne',
    の: 'no',
    は: 'ha',
    ひ: 'hi',
    ふ: 'fu',
    へ: 'he',
    ほ: 'ho',
    ひゃ: 'hya',
    ひゅ: 'hyu',
    ひょ: 'hyo',
    ふぁ: 'fa',
    ふぃ: 'fi',
    ふぇ: 'fe',
    ふぉ: 'fo',
    ば: 'ba',
    び: 'bi',
    ぶ: 'bu',
    べ: 'be',
    ぼ: 'bo',
    びゃ: 'bya',
    びゅ: 'byu',
    びょ: 'byo',
    ぱ: 'pa',
    ぴ: 'pi',
    ぷ: 'pu',
    ぺ: 'pe',
    ぽ: 'po',
    ぴゃ: 'pya',
    ぴゅ: 'pyu',
    ぴょ: 'pyo',
    ま: 'ma',
    み: 'mi',
    む: 'mu',
    め: 'me',
    も: 'mo',
    みゃ: 'mya',
    みゅ: 'myu',
    みょ: 'myo',
    や: 'ya',
    ゆ: 'yu',
    よ: 'yo',
    ら: 'ra',
    り: 'ri',
    る: 'ru',
    れ: 're',
    ろ: 'ro',
    りゃ: 'rya',
    りゅ: 'ryu',
    りょ: 'ryo',
    わ: 'wa',
    を: 'wo',
    ん: 'n',
    ゐ: 'wi',
    ゑ: 'we',
    きぇ: 'kye',
    きょ: 'kyo',
    じぃ: 'jyi',
    じぇ: 'jye',
    ちぃ: 'cyi',
    ちぇ: 'che',
    ひぃ: 'hyi',
    ひぇ: 'hye',
    びぃ: 'byi',
    びぇ: 'bye',
    ぴぃ: 'pyi',
    ぴぇ: 'pye',
    みぇ: 'mye',
    みぃ: 'myi',
    りぃ: 'ryi',
    りぇ: 'rye',
    にぃ: 'nyi',
    にぇ: 'nye',
    しぃ: 'syi',
    しぇ: 'she',
    いぇ: 'ye',
    うぁ: 'wha',
    うぉ: 'who',
    うぃ: 'wi',
    うぇ: 'we',
    ゔゃ: 'vya',
    ゔゅ: 'vyu',
    ゔょ: 'vyo',
    すぁ: 'swa',
    すぃ: 'swi',
    すぅ: 'swu',
    すぇ: 'swe',
    すぉ: 'swo',
    くゃ: 'qya',
    くゅ: 'qyu',
    くょ: 'qyo',
    くぁ: 'qwa',
    くぃ: 'qwi',
    くぅ: 'qwu',
    くぇ: 'qwe',
    くぉ: 'qwo',
    ぐぁ: 'gwa',
    ぐぃ: 'gwi',
    ぐぅ: 'gwu',
    ぐぇ: 'gwe',
    ぐぉ: 'gwo',
    つぁ: 'tsa',
    つぃ: 'tsi',
    つぇ: 'tse',
    つぉ: 'tso',
    てゃ: 'tha',
    てぃ: 'thi',
    てゅ: 'thu',
    てぇ: 'the',
    てょ: 'tho',
    とぁ: 'twa',
    とぃ: 'twi',
    とぅ: 'twu',
    とぇ: 'twe',
    とぉ: 'two',
    ぢゃ: 'dya',
    ぢぃ: 'dyi',
    ぢゅ: 'dyu',
    ぢぇ: 'dye',
    ぢょ: 'dyo',
    でゃ: 'dha',
    でぃ: 'dhi',
    でゅ: 'dhu',
    でぇ: 'dhe',
    でょ: 'dho',
    どぁ: 'dwa',
    どぃ: 'dwi',
    どぅ: 'dwu',
    どぇ: 'dwe',
    どぉ: 'dwo',
    ふぅ: 'fwu',
    ふゃ: 'fya',
    ふゅ: 'fyu',
    ふょ: 'fyo',
    ぁ: 'a',
    ぃ: 'i',
    ぇ: 'e',
    ぅ: 'u',
    ぉ: 'o',
    ゃ: 'ya',
    ゅ: 'yu',
    ょ: 'yo',
    っ: '',
    ゕ: 'ka',
    ゖ: 'ka',
    ゎ: 'wa',
    んあ: 'n\'a',
    んい: 'n\'i',
    んう: 'n\'u',
    んえ: 'n\'e',
    んお: 'n\'o',
    んや: 'n\'ya',
    んゆ: 'n\'yu',
    んよ: 'n\'yo',
    '　'.to_sym => ' ',
    'ー'.to_sym => '-',
    '。'.to_sym => '.',
    '、'.to_sym => ',',
    '（'.to_sym => '(',
    '）'.to_sym => ')',
    '「'.to_sym => '“',
    '」'.to_sym => '”',
    '？'.to_sym => '?',
    '！'.to_sym => '!'
  }
end
