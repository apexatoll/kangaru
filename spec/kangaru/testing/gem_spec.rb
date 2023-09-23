RSpec.describe Kangaru::Testing::Gem, :with_temp_dir do
  subject(:gem) { described_class.new(**attributes) }

  let(:attributes) { { dir:, name: }.compact }

  let(:name) { "some_gem" }
  let(:dir)  { temp_dir }

  describe "#initialize" do
    context "when gem name is not specified" do
      let(:name) { nil }

      it "sets the directory" do
        expect(gem.dir).to eq(dir)
      end

      it "sets the name to the default" do
        expect(gem.name).to eq(described_class::DEFAULT_NAME)
      end
    end

    context "when gem name is specified" do
      let(:name) { "some_gem" }

      it "sets the directory" do
        expect(gem.dir).to eq(dir)
      end

      it "sets the name to the specified value" do
        expect(gem.name).to eq(name)
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
end
