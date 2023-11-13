module Kangaru
  module Interface
    def run!(*argv)
      Kangaru.application!.run!(*argv)
    end

    def config
      Kangaru.application!.config
    end

    def configure(env = nil, &)
      return unless env_applies?(env)

      Kangaru.application!.configure(&)
    end

    def config_path(path)
      Kangaru.application!.config_path = path
    end

    def apply_config!
      Kangaru.application!.apply_config!
    end

    def database
      Kangaru.application!.database
    end

    private

    def env_applies?(env)
      return true if env.nil?

      Kangaru.env?(env)
    end
  end
end
