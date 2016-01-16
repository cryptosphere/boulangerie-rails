# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "boulangerie/rails/version"

Gem::Specification.new do |spec|
  spec.name          = "boulangerie-rails"
  spec.version       = Boulangerie::Rails::VERSION
  spec.authors       = ["Tony Arcieri"]
  spec.email         = ["bascule@gmail.com"]

  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/cryptosphere/boulangerie-rails"
  spec.summary       = "Rails support creating and verifying Macaroons with Boulangerie"
  spec.description   = <<-DESCRIPTION.strip.gsub(/\s+/, " ")
    Boulangerie provides schemas, creation, and verification for the
    Macaroons bearer credential format. This gem contains support for
    using Boulangerie with Ruby on Rails.
  DESCRIPTION

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency "boulangerie"

  spec.add_development_dependency "rake", "~> 10.0"
end
