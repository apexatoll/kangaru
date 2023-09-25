RSpec.describe Kangaru::ApplicationPaths do
  subject(:application) { application_class.new(dir:, name:) }

  let(:application_class) do
    Class.new do
      include Kangaru::ApplicationPaths

      attr_reader :dir, :name

      def initialize(dir:, name:)
        @dir = dir
        @name = name
      end
    end
  end

  let(:dir) { "/foo/bar" }

  let(:name) { "double" }

  matcher :cache_attribute do |attribute|
    supports_block_expectations

    def cached?(attribute)
      application.instance_variable_defined?(:"@#{attribute}")
    end

    match do |action|
      expect { action.call }
        .to change { cached?(attribute) }
        .from(false)
        .to(true)
    end
  end

  shared_examples :returns_path do |options|
    let(:expected_path) { options[:for] }

    it "returns a Pathname" do
      expect(subject).to be_a(Pathname)
    end

    it "sets the expected path" do
      expect(subject.to_s).to eq(expected_path)
    end
  end

  describe "#path" do
    subject(:path) { application.path }

    include_examples :returns_path, for: "/foo/bar/double"

    it "caches the attribute" do
      expect { path }.to cache_attribute(:path)
    end
  end

  describe "#lib_path" do
    subject(:lib_path) { application.lib_path }

    include_examples :returns_path, for: "/foo/bar/double/lib"

    it "caches the attribute" do
      expect { lib_path }.to cache_attribute(:lib_path)
    end
  end

  describe "#main_file" do
    subject(:main_file) { application.main_file }

    include_examples :returns_path, for: "/foo/bar/double/lib/double.rb"

    it "caches the attribute" do
      expect { main_file }.to cache_attribute(:main_file)
    end
  end

  describe "#gem_file" do
    subject(:gem_file) { application.gem_file(file) }

    let(:file) { "some_file" }

    include_examples :returns_path,
                     for: "/foo/bar/double/lib/double/some_file.rb"
  end

  describe "#gem_dir" do
    subject(:gem_dir) { application.gem_dir(dir_arg) }

    let(:dir_arg) { "some_dir" }

    include_examples :returns_path,
                     for: "/foo/bar/double/lib/double/some_dir"
  end

  describe "#view_file" do
    subject(:view_file) { application.view_file(controller:, action:) }

    let(:controller) { "default" }

    let(:action) { :do_something }

    include_examples :returns_path, for:
      "/foo/bar/double/lib/double/views/default/do_something.erb"
  end
end
