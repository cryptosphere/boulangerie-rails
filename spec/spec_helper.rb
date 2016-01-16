$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "boulangerie/rails"

RSpec.configure(&:disable_monkey_patching!)
