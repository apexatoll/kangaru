# frozen_string_literal: true

require_relative "lib/kangaru/version"

Gem::Specification.new do |spec|
  spec.name = "kangaru"
  spec.version = Kangaru::VERSION
  spec.authors = ["Chris Welham"]
  spec.email = ["71787007+apexatoll@users.noreply.github.com"]

  spec.summary = "A lightweight framework for building command line interfaces"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files`.split("\n").reject do |f|
      f == __FILE__ || f.match?(/\A(bin|sig|spec|\.git|\.github)/)
    end
  end
  spec.bindir = "bin"
  spec.executables = []
  spec.require_paths = ["lib"]
end
