# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wanakana/version'

Gem::Specification.new do |spec|
  spec.name          = "Wanakana"
  spec.version       = Wanakana::VERSION
  spec.authors       = ["Cantrell NM"]
  spec.email         = ["cantrellnm@gmail.com"]

  spec.summary       = %q{Ruby port of WaniKani/WanaKana.js}
  spec.description   = %q{Change Japanese text to and from romaji, hiragana, and katakana. This gem is a port of WaniKani's JavaScript library.}
  spec.homepage      = "https://github.com/cantrellnm/WanaKanaRuby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 11.2"
  spec.add_development_dependency "minitest", "~> 5.8"
end
