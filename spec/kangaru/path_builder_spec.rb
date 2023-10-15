RSpec.describe Kangaru::PathBuilder do
  subject(:path_builder) { described_class.new(source:) }

  let(:source) { "/foo/bar/#{gem_name}#{version}/lib/#{gem_name}.rb" }

  let(:gem_name) { "gem" }

  shared_context :local_gem_path do
    let(:version) { nil }
  end

  shared_context :installed_gem_path do
    let(:version) { "-0.1.0" }
  end

  shared_examples :builds_path do |**options|
    let(:base) { options[:as] }

    context "when gem is not installed" do
      include_context :local_gem_path

      let(:expected) { format(base, version: nil) }

      it "returns a pathname" do
        expect(subject).to be_a(Pathname)
      end

      it "returns the expected path" do
        expect(subject.to_s).to eq(expected)
      end
    end

    context "when gem is installed" do
      include_context :installed_gem_path

      let(:expected) { format(base, version:) }

      it "returns a pathname" do
        expect(subject).to be_a(Pathname)
      end

      it "returns the expected path" do
        expect(subject.to_s).to eq(expected)
      end
    end
  end

  describe "#dir" do
    subject(:dir) { path_builder.dir }

    include_examples :builds_path, as: "/foo/bar"
  end

  describe "#name" do
    subject(:name) { path_builder.name }

    context "when gem is not installed" do
      include_context :local_gem_path

      it "extracts the name from the source" do
        expect(name).to eq(gem_name)
      end
    end

    context "when gem is installed" do
      include_context :installed_gem_path

      it "extracts the name from the source" do
        expect(name).to eq(gem_name)
      end
    end
  end

  describe "#gem_path" do
    subject(:gem_path) { path_builder.gem_path(*fragments, ext:) }

    context "when path fragments are not specified" do
      let(:fragments) { [] }

      context "and extension is not specified" do
        let(:ext) { nil }

        include_examples :builds_path, as: "/foo/bar/gem%{version}"
      end

      context "and extension is specified" do
        let(:ext) { :rb }

        include_examples :builds_path, as: "/foo/bar/gem%{version}"
      end
    end

    context "when one path fragment is specified" do
      let(:fragments) { %w[file] }

      context "and extension is not specified" do
        let(:ext) { nil }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/file"
      end

      context "and extension is specified" do
        let(:ext) { :rb }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/file.rb"
      end
    end

    context "when multiple path fragments are specified" do
      let(:fragments) { %w[dir file] }

      context "and extension is not specified" do
        let(:ext) { nil }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/dir/file"
      end

      context "and extension is specified" do
        let(:ext) { :rb }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/dir/file.rb"
      end
    end
  end

  describe "#lib_path" do
    subject(:lib_path) { path_builder.lib_path(*fragments, ext:) }

    context "when path fragments are not specified" do
      let(:fragments) { [] }

      context "and extension is not specified" do
        let(:ext) { nil }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/lib"
      end

      context "and extension is specified" do
        let(:ext) { :rb }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/lib"
      end
    end

    context "when one path fragment is specified" do
      let(:fragments) { %w[file] }

      context "and extension is not specified" do
        let(:ext) { nil }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/lib/file"
      end

      context "and extension is specified" do
        let(:ext) { :rb }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/lib/file.rb"
      end
    end

    context "when multiple path fragments are specified" do
      let(:fragments) { %w[dir file] }

      context "and extension is not specified" do
        let(:ext) { nil }

        include_examples :builds_path, as: "/foo/bar/gem%{version}/lib/dir/file"
      end

      context "and extension is specified" do
        let(:ext) { :rb }

        include_examples :builds_path,
                         as: "/foo/bar/gem%{version}/lib/dir/file.rb"
      end
    end
  end
end