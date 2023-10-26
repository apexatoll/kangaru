require "zeitwerk"

require "colorize"
require "erb"
require "forwardable"
require "pathname"
require "sequel"
require "sqlite3"
require "yaml"

module Kangaru
  @loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false).tap(&:setup)

  class << self
    attr_accessor :application

    def eager_load(namespace)
      @loader.eager_load_namespace(namespace)
    end
  end
end
