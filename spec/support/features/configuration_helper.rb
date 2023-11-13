module ConfigurationHelper
  def configure_block(env: nil)
    <<~RUBY
      configure #{env && "env: :#{env}"} do |config|
        #{yield}
      end
    RUBY
  end
end
