RSpec.describe "rendering erb templates" do
  subject(:run_command!) { SomeGem.run! }

  let(:action) { nil }

  include_context :kangaru_initialised

  before do
    gem.path("default_controller").write(<<~RUBY)
      module SomeGem
        class DefaultController < Kangaru::Controller
          def default
            #{action}
          end
        end
      end
    RUBY
  end

  context "when view file does not exist" do
    before { gem.load! }

    it "does not output to stdout" do
      expect { run_command! }.not_to output.to_stdout
    end
  end

  context "when view file exists" do
    before do
      gem.path("views", ext: nil).mkdir
      gem.path("views", "default", ext: nil).mkdir
      gem.path("views", "default", "default", ext: :erb).write(view_file)

      gem.load!
    end

    describe "instance variable interpolation" do
      let(:action) do
        <<~RUBY
          @name = "Some Name"
          @age = 30
        RUBY
      end

      let(:view_file) do
        <<~ERB
          Hello <%= @name %>, you are <%= @age %> years old.
        ERB
      end

      it "outputs the interpolated view file" do
        expect { run_command! }.to output(<<~TEXT).to_stdout
          Hello Some Name, you are 30 years old.
        TEXT
      end
    end

    describe "referencing constants within target namespace" do
      let(:view_file) do
        <<~ERB
          <%= Foobar.hello_world %>
        ERB
      end

      context "when relative const is not defined in target gem namespace" do
        it "raises an error" do
          expect { run_command! }.to raise_error(NameError)
        end
      end

      context "when relative const is defined in target gem namespace" do
        before { stub_const "SomeGem::Foobar", foobar }

        let(:foobar) do
          Class.new { def self.hello_world = "Hello world" }
        end

        it "does not raise any errors", :suppress_output do
          expect { run_command! }.not_to raise_error
        end

        it "outputs the expected text" do
          expect { run_command! }.to output(<<~TEXT).to_stdout
            Hello world
          TEXT
        end
      end
    end

    describe "whitespace trimming" do
      context "when trim tags are not used" do
        let(:view_file) do
          <<~ERB
            <% %i[foo bar baz].each do |symbol| %>
            <%= symbol %>
            <% end %>
          ERB
        end

        it "outputs the text with the expected formatting" do
          expect { run_command! }.to output(<<~TEXT).to_stdout

            foo

            bar

            baz

          TEXT
        end
      end

      context "when trim tags are used" do
        let(:view_file) do
          <<~ERB
            <% %i[foo bar baz].each do |symbol| -%>
            <%= symbol %>
            <% end -%>
          ERB
        end

        it "outputs the text with the expected formatting" do
          expect { run_command! }.to output(<<~TEXT).to_stdout
            foo
            bar
            baz
          TEXT
        end
      end
    end
  end
end
