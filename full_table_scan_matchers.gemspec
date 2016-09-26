# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'full_table_scan_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = "full_table_scan_matchers"
  spec.version       = FullTableScanMatchers::VERSION
  spec.authors       = ["Justin Aiken"]
  spec.email         = ["60tonangel@gmail.com"]

  spec.summary       = %q{Matchers for rspec to detect full table scans}
  spec.description   = %q{Matchers for rspec to detect full table scans}
  spec.homepage      = "https://github.com/JustinAiken/full_table_scan_matchers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.0"
  spec.add_dependency "activerecord",  ">= 3.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.0"
end
