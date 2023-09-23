module TempDirHelper
  RSpec.configure do |config|
    config.around(with_temp_dir: true) do |spec|
      self.class.class_eval { attr_reader :temp_dir }

      Dir.mktmpdir do |temp_dir|
        @temp_dir = temp_dir

        spec.run

        remove_instance_variable(:@temp_dir)
      end
    end
  end
end
