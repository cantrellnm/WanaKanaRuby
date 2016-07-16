# WanaKanaRuby

Ruby port of [WaniKani/WanaKana](https://github.com/WaniKani/WanaKana), a Javascript library that provides utilities for detecting and transliterating Hiragana <--> Katakana <--> Romaji.

This port does not have the methods .bind or .unbind for inputs as WanKana.js does.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wanakana'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wanakana

## Usage

```ruby
# Returns false if string contains mixed characters, otherwise true if Hiragana.
Wanakana.is_hiragana?(string)

# Returns false if string contains characters outside of the kana family, otherwise true if Hiragana and/or Katakana.
Wanakana.is_kana?(string)

# Returns false if string contains mixed characters, otherwise true if Katakana.
Wanakana.is_katakana>(string)

# Convert Katakana or Romaji to Hiragana.
Wanakana.to_hiragana(string [, options])

# Convert Romaji to Kana. Lowcase entries output Hiragana, while upcase entries output Katakana.
Wanakana.to_kana(string [, options])

# Convert Hiragana or Romaji to Katakana.
Wanakana.to_katakana(string [, options])

# Convert Kana to Romaji.
Wanakana.to_romaji(string [, options])

# Options:
# Many functions take an optional `options` hash.
# Here is the default hash used for options.
{
	:useObsoleteKana => false, # Set to true to use obsolete characters, such as ゐ and ゑ.
	:convertKatakanaToUppercase => false # Set to true to convert katakana characters to uppercase romaji.
}
```

## Development

After cloning the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/cantrellnm/WanaKanaRuby).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

