require "zeitwerk"

module Kangaru
  Zeitwerk::Loader.for_gem(warn_on_extra_files: false).setup

  using Patches::Inflections
  using Patches::Constantise
end
