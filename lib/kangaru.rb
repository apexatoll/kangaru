require "zeitwerk"

require "colorize"
require "erb"
require "fileutils"
require "forwardable"
require "pathname"
require "sequel"
require "sqlite3"
require "yaml"

module Kangaru
  COLLAPSED_DIRS = [
    "#{__dir__}/kangaru/components",
    "#{__dir__}/kangaru/concerns"
  ].freeze

  DEFAULT_ENV = :runtime

  INFLECTIONS = {
    "rspec" => "RSpec"
  }.freeze

  @loader = Zeitwerk::Loader.for_gem(
    warn_on_extra_files: false
  ).tap do |loader|
    loader.inflector.inflect(INFLECTIONS)
    loader.collapse(COLLAPSED_DIRS)
    loader.setup
  end

  class << self
    attr_accessor :application

    def application!
      application || raise("application not set")
    end

    def env=(value)
      @env = value.to_sym
    end

    def env
      @env ||= DEFAULT_ENV
    end

    def env?(value)
      env == value
    end

    def eager_load(namespace)
      @loader.eager_load_namespace(namespace)
    end

    def test?
      env == :test
    end
  end
end
