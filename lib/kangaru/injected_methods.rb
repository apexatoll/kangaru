module Kangaru
  module InjectedMethods
    def run!(argv)
      Kangaru.application.run!(argv)
    end

    def config
      Kangaru.application.config
    end

    def configure(env = nil, &)
      Kangaru.application.configure(env, &)
    end

    def apply_config!
      Kangaru.application.apply_config!
    end

    def database
      Kangaru.application.database
    end
  end
end
