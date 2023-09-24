RSpec.shared_context :kangaru_initialised do
  before do
    gem.main_file.write(<<~RUBY)
      require "kangaru"

      module SomeGem
        extend Kangaru::Initialiser
      end
    RUBY
  end
end
