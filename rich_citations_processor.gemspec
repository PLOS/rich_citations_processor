# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rich_citations_processor/version'

Gem::Specification.new do |spec|
  spec.name          = "rich_citations_processor"
  spec.version       = RichCitationsProcessor::VERSION
  spec.authors       = ["PLOS Labs"]
  spec.email         = ["ploslabs@plos.org"]
  spec.summary       = %q{Rich Citations Document Processor}
  spec.description   = %q{Reference implementation of processor.}
  spec.homepage      = "http://www.ploslabs.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'rails-html-sanitizer'
  spec.add_runtime_dependency 'httpclient'
  spec.add_runtime_dependency 'multi_json'
  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'nokogiri'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "equivalent-xml"

end
