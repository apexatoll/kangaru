module Kangaru
  class Router
    using Patches::Constantise

    attr_reader :command, :namespace

    def initialize(command, namespace: Object)
      @command   = command
      @namespace = namespace
    end
  end
end
