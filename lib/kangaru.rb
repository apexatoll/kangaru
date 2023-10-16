require "zeitwerk"

require "erb"
require "forwardable"
require "pathname"
require "sequel"
require "sqlite3"

module Kangaru
  Zeitwerk::Loader.for_gem(warn_on_extra_files: false).setup

  class << self
    attr_accessor :application
  end
end
