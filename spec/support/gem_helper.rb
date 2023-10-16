require "tmpdir"

module GemHelper
  RSpec.configure do |config|
    config.around(with_gem_deprecated: true) do |spec|
      self.class.class_eval { attr_reader :gem }

      Dir.mktmpdir do |dir|
        @gem = Kangaru::Testing::Gem.new(dir:).tap(&:create!)

        spec.run

        Object.send(:remove_const, :SomeGem) if Object.const_defined?(:SomeGem)

        if Kangaru.instance_variable_defined?(:@application)
          Kangaru.remove_instance_variable(:@application)
        end
      end
    end
  end
end
