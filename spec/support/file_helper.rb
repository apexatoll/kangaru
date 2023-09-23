module FileHelper
  extend RSpec::Matchers::DSL

  matcher :create_dir do |filename|
    supports_block_expectations

    match do |action|
      path = File.join(@dir, filename)

      expect(&action).to change { Dir.exist?(path) }.from(false).to(true)
    end

    chain :in do |dir|
      @dir = dir
    end
  end

  matcher :create_file do |filename|
    supports_block_expectations

    match do |action|
      path = File.join(@dir, filename)

      expect(&action).to change { File.exist?(path) }.from(false).to(true)
    end

    chain :in do |dir|
      @dir = dir
    end
  end
end
