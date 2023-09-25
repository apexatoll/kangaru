require "zeitwerk"

require "erb"
require "pathname"

module Kangaru
  Zeitwerk::Loader.for_gem(warn_on_extra_files: false).setup

  using Patches::Inflections
  using Patches::Constantise

  class << self
    attr_accessor :application
  end
end
