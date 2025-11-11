require "date"
require_relative "lib/tonal/attributions"

Gem::Specification.new do |spec|
  spec.name        = "tonal-scales"
  spec.version     = Tonal::SCALES_VERSION
  spec.summary     = "Tonal scales"
  spec.description = "A collection of scales, sequences and their analysis tools for microtonal music making"
  spec.authors     = ["Jose Hales-Garcia"]
  spec.email       = "jose@halesgarcia.com"
  spec.homepage    = "https://mtonal.github.io/scales/"
  spec.metadata = {
    "source_code_uri" => "https://github.com/mTonal/scales/",
    "documentation_uri" => "https://mtonal.github.io/scales/",
  }
  spec.license     = "MIT"
  spec.date        = Date.today.to_s
  spec.files       = Dir.glob("lib/**/*")
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1")
  spec.required_rubygems_version = Gem::Requirement.new(">= 3.1")
  spec.rubygems_version = "3.5.23"
  spec.add_runtime_dependency "tonal-tools", ["~> 7"]
  #spec.add_runtime_dependency "tonal-strings", ["~> 1.0"]
  spec.add_runtime_dependency "rubyzip", ["~> 3"]
  spec.add_runtime_dependency "caxlsx", ["~> 4"]
  spec.add_runtime_dependency "erb", ["~> 4"]
  spec.add_runtime_dependency "csv", ["~> 3"]
  spec.add_runtime_dependency "typhoeus", ["~> 1.5"]
  spec.add_runtime_dependency "pathname", ["~> 0.4"]
  spec.add_runtime_dependency "readline", ["~> 0.0"]
  spec.add_runtime_dependency "readline-ext", ["~> 0.2"]
  spec.add_runtime_dependency "activesupport", ["~> 8 "]
  spec.add_runtime_dependency "terminal-table", ["~> 4.0"]
  spec.add_development_dependency "rspec", ["~> 3"]
  spec.add_development_dependency "byebug", ["~> 12"]
  spec.add_development_dependency "yard", ["~> 0.9"]
end
