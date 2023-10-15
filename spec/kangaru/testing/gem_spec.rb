RSpec.describe Kangaru::Testing::Gem, :with_temp_dir do
  subject(:gem) { described_class.new(**attributes) }

  let(:attributes) { { dir:, name: }.compact }

  let(:name) { "some_gem" }
  let(:dir)  { temp_dir }

  shared_examples :returns_path do |options|
    let(:expected_path) { options[:for] }

    it "returns a Pathname" do
      expect(subject).to be_a(Pathname)
    end

    it "sets the expected path" do
      expect(subject.to_s).to eq(expected_path)
    end
  end

  describe "#initialize" do
    context "when gem name is not specified" do
      let(:name) { nil }

      it "sets the directory" do
        expect(gem.dir.to_s).to eq(dir)
      end

      it "sets the name to the default" do
        expect(gem.name).to eq(described_class::DEFAULT_NAME)
      end
    end

    context "when gem name is specified" do
      let(:name) { "some_gem" }

      it "sets the directory" do
        expect(gem.dir.to_s).to eq(dir)
      end

      it "sets the name to the specified value" do
        expect(gem.name).to eq(name)
      end
    end
  end

  describe "#path" do
    subject(:path) { gem.path }

    it "returns a Pathname" do
      expect(path).to be_a(Pathname)
    end

    it "returns the expected path" do
      expect(path.to_s).to eq("#{dir}/#{name}")
    end
  end

  describe "#lib_path" do
    subject(:lib_path) { gem.lib_path }

    it "returns a Pathname" do
      expect(lib_path).to be_a(Pathname)
    end

    it "sets the expected path" do
      expect(lib_path.to_s).to eq("#{dir}/#{name}/lib")
    end
  end

  describe "#main_file" do
    subject(:main_file) { gem.main_file }

    it "returns a Pathname" do
      expect(main_file).to be_a(Pathname)
    end

    it "returns the expected path" do
      expect(main_file.to_s).to eq("#{dir}/#{name}/lib/#{name}.rb")
    end
  end

  describe "#gem_file" do
    subject(:gem_file) { gem.gem_file(file) }

    let(:file) { "some_file" }

    it "returns a Pathname" do
      expect(gem_file).to be_a(Pathname)
    end

    it "returns the expected path" do
      expect(gem_file.to_s).to eq("#{dir}/#{name}/lib/#{name}/#{file}.rb")
    end
  end

  describe "#gem_dir" do
    subject(:gem_dir) { gem.gem_dir(dir_arg) }

    let(:dir_arg) { "some_dir" }

    it "returns a Pathname" do
      expect(gem_dir).to be_a(Pathname)
    end

    it "returns the expected path" do
      expect(gem_dir.to_s).to eq("#{dir}/#{name}/lib/#{name}/#{dir_arg}")
    end
  end

  describe "#view_file", skip: :deprecated do
    subject(:view_file) { gem.view_file(controller:, action:) }

    let(:controller) { "default" }

    let(:action) { :do_something }

    include_examples :returns_path, for:
      "/foo/bar/double/lib/double/views/default/do_something.erb"
  end

  describe "#created?" do
    context "when gem has not been created" do
      it "returns false" do
        expect(gem).not_to be_created
      end
    end

    context "when gem has been created" do
      before { gem.create! }

      it "returns true" do
        expect(gem).to be_created
      end
    end
  end

  describe "#create!" do
    subject(:create!) { gem.create! }

    let(:gem_path) { File.join(temp_dir, name) }

    let(:lib_dir)  { File.join(gem_path, "lib") }

    it "creates the gem in the specified directory" do
      expect { create! }.to create_dir(name).in(temp_dir)
    end

    it "generates a Gemfile" do
      expect { create! }.to create_file("Gemfile").in(gem_path)
    end

    it "generates a gemspec" do
      expect { create! }.to create_file("#{name}.gemspec").in(gem_path)
    end

    it "generates a lib directory" do
      expect { create! }.to create_dir("lib").in(gem_path)
    end

    it "generates a main file" do
      expect { create! }.to create_file("#{name}.rb").in(lib_dir)
    end
  end

  describe "#load!" do
    subject(:load!) { gem.load! }

    after do
      Object.send(:remove_const, :SomeGem) if Object.const_defined?(:SomeGem)
    end

    context "when gem has not been created" do
      it "raises an error" do
        expect { load! }.to raise_error(
          described_class::GemNotCreatedError,
          "gem must be created first"
        )
      end
    end

    context "when gem has been created" do
      before { gem.create! }

      it "loads the gem" do
        expect { load! }
          .to change { Object.const_defined?(:SomeGem) }
          .from(false)
          .to(true)
      end
    end
  end
end
