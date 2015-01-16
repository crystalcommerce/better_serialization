# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'better_serialization/version'

Gem::Specification.new do |spec|
  spec.name          = "better_serialization"
  spec.version       = BetterSerialization::VERSION
  spec.authors       = ["http://github.com/crystalcommerce", "http://github.com/rhburrows", "http://github.com/mccraigmccraig"]
  spec.email         = ["dbalatero@gmail.com"]
  spec.description   = %q{Rails 3 version of better_serialization}
  spec.summary       = %q{Rails 3 version of better_serialization}
  spec.homepage      = "https://github.com/dbalatero/better_serialization"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  deps = [
    ["activerecord", '>= 3.0']
  ]

  deps.each do |dep|
    spec.add_dependency *dep
  end

  dev_deps = [
    ["bundler", "~> 1.3"],
    ["guard"],
    ["guard-rspec"],
    ["rspec", "~> 2.14.0"],
    ["sqlite3-ruby", "~> 1.3.1"]
  ]

  dev_deps.each do |dep|
    spec.add_development_dependency *dep
  end
end
