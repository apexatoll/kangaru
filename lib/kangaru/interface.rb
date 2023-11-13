module Kangaru
  module Interface
    def run!(*argv)
      Kangaru.application!.run!(*argv)
    end

    def config
      Kangaru.application!.config
    end

    def configure(env = nil, &)
      return if env && !Kangaru.env?(env)

      Kangaru.application!.configure(&)
    end

    def import_config_from!(path)
      Kangaru.application!.config_path = path
    end

    def apply_config!
      Kangaru.application!.apply_config!
    end

    def database
      Kangaru.application!.database
    end
  end
end
