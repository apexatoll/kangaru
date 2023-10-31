module Kangaru
  class PathParser
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def controller
      match(:controller)
    end

    def action
      match(:action, cast: :to_sym)
    end

    def id
      match(:id, cast: :to_i)
    end

    private

    MATCHERS = {
      controller: %r{/(.*)/[A-z]+(/\d+)?$},
      action: %r{^.*/([A-z]+)(/\d+)?$},
      id: %r{^.*/(\d+)$}
    }.freeze

    def match(key, cast: :to_s)
      return unless (value = path.scan(MATCHERS[key]).flatten.first)

      value.send(cast)
    end
  end
end
