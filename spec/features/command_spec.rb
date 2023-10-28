RSpec.describe "Running a command" do
  subject(:run_command!) { SomeGem.run!(argv) }

  let(:argv) { [] }

  include_context :kangaru_initialised

  describe "calling SomeGem.run! directly" do
    let(:target) do
      Module.new { def self.do_something = nil }
    end

    before do
      stub_const "Target", target

      allow(Target).to receive(:do_something)
    end

    shared_examples :unsuccessful_command do
      it "does not call the target" do
        run_command!
      rescue
        expect(Target).not_to have_received(:do_something)
      end
    end

    shared_examples :handles_undefined_controller do |**options|
      include_examples :unsuccessful_command

      it "raises an UndefinedControllerError" do
        expect { run_command! }.to raise_error(
          Kangaru::Router::UndefinedControllerError,
          "#{options[:controller]} is not defined in SomeGem"
        )
      end
    end

    shared_examples :handles_undefined_action do |**options|
      it "raises an UndefinedActionError" do
        expect { run_command! }.to raise_error(
          Kangaru::Router::UndefinedActionError,
          "#{options[:action]} is not defined by #{options[:controller]}"
        )
      end
    end

    shared_examples :successful_command do
      it "does not raise any errors" do
        expect { run_command! }.not_to raise_error
      end

      it "runs the default action" do
        run_command!
        expect(Target).to have_received(:do_something).once
      end
    end

    context "when no arguments are given" do
      let(:argv) { [] }

      context "and default controller is not defined" do
        before { gem.load! }

        include_examples :handles_undefined_controller,
                         controller: "DefaultController"
      end

      context "and default controller is defined" do
        before do
          gem.path("default_controller").write(controller)
          gem.load!
        end

        context "and default action is not defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                class DefaultController < Kangaru::Controller
                  def foobar
                    Target.do_something
                  end
                end
              end
            RUBY
          end

          include_examples :handles_undefined_action,
                           controller: "DefaultController",
                           action: "default"
        end

        context "and default action is defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                class DefaultController < Kangaru::Controller
                  def default
                    Target.do_something
                  end
                end
              end
            RUBY
          end

          include_examples :successful_command
        end
      end
    end

    context "when one argument is given" do
      let(:argv) { %w[foobar] }

      context "and specified controller is not defined" do
        before { gem.load! }

        include_examples :handles_undefined_controller,
                         controller: "FoobarController"
      end

      context "and specified controller is defined" do
        before do
          gem.path("foobar_controller").write(controller)
          gem.load!
        end

        context "and default action is not defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                class FoobarController < Kangaru::Controller
                  def foobar
                    Target.do_something
                  end
                end
              end
            RUBY
          end

          include_examples :handles_undefined_action,
                           controller: "FoobarController",
                           action: "default"
        end

        context "and default action is defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                class FoobarController < Kangaru::Controller
                  def default
                    Target.do_something
                  end
                end
              end
            RUBY
          end

          include_examples :successful_command
        end
      end
    end

    context "when two arguments are given" do
      let(:argv) { %w[foobar some_action] }

      context "and specified controller is not defined" do
        before { gem.load! }

        include_examples :handles_undefined_controller,
                         controller: "FoobarController"
      end

      context "and specified controller is defined" do
        before do
          gem.path("foobar_controller").write(controller)
          gem.load!
        end

        context "and specified action is not defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                class FoobarController < Kangaru::Controller
                  def foobar
                    Target.do_something
                  end
                end
              end
            RUBY
          end

          include_examples :handles_undefined_action,
                           controller: "FoobarController",
                           action: "some_action"
        end

        context "and specified action is defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                class FoobarController < Kangaru::Controller
                  def some_action
                    Target.do_something
                  end
                end
              end
            RUBY
          end

          include_examples :successful_command
        end
      end
    end

    context "when three arguments are given" do
      let(:argv) { %w[namespace foobar some_action] }

      context "and specified nested controller is not defined" do
        before { gem.load! }

        include_examples :handles_undefined_controller,
                         controller: "Namespace::FoobarController"
      end

      context "and specified nested controller is defined" do
        before do
          gem.path("namespace", ext: nil).mkdir
          gem.path("namespace", "foobar_controller").write(controller)
          gem.load!
        end

        context "and specified action is not defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                module Namespace
                  class FoobarController < Kangaru::Controller
                    def foobar
                      Target.do_something
                    end
                  end
                end
              end
            RUBY
          end

          include_examples :handles_undefined_action,
                           controller: "Namespace::FoobarController",
                           action: "some_action"
        end

        context "and specified action is defined" do
          let(:controller) do
            <<~RUBY
              module SomeGem
                module Namespace
                  class FoobarController < Kangaru::Controller
                    def some_action
                      Target.do_something
                    end
                  end
                end
              end
            RUBY
          end

          include_examples :successful_command
        end
      end
    end
  end
end
