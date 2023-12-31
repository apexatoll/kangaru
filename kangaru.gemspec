require_relative "lib/kangaru/version"

Gem::Specification.new do |spec|
  spec.name = "kangaru"
  spec.version = Kangaru::VERSION
  spec.authors = ["Chris Welham"]
  spec.email = ["71787007+apexatoll@users.noreply.github.com"]

  spec.summary = "A lightweight framework for building command line interfaces"
  spec.homepage = "https://github.com/apexatoll/kangaru"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files`.split("\n").reject do |f|
      f == __FILE__ || f.match?(/\A(bin|spec|\.git|\.github)/)
    end
  end

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  spec.bindir = "bin"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize", "~> 1.1"
  spec.add_dependency "erb", "~> 4.0"
  spec.add_dependency "sequel", "~> 5.72"
  spec.add_dependency "sqlite3", "~> 1.6"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
