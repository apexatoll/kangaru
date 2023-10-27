RSpec.describe "Autoloader" do
  include_context :kangaru_initialised

  describe "collapsed directories" do
    describe "controllers" do
      shared_examples :does_not_find_controller do
        it "does not find the controller" do
          gem.load!
          expect(SomeGem).not_to be_const_defined(:SomeController)
        end
      end

      shared_examples :finds_controller do
        it "finds the controller" do
          gem.load!
          expect(SomeGem).to be_const_defined(:SomeController)
        end
      end

      context "when controller is not defined" do
        include_examples :does_not_find_controller
      end

      context "when controller is defined" do
        before do
          gem.path("controllers", ext: nil).mkdir

          model_path.write(<<~RUBY)
            module SomeGem
              class SomeController < Kangaru::Controller
                def default = nil
              end
            end
          RUBY
        end

        context "and controller exists in gem base directory" do
          let(:model_path) { gem.path("some_controller") }

          include_examples :finds_controller
        end

        context "and controller exists in controllers directory" do
          let(:model_path) { gem.path("controllers", "some_controller") }

          include_examples :finds_controller
        end
      end
    end

    describe "models" do
      shared_examples :does_not_find_model do
        it "does not find the model" do
          gem.load!
          expect(SomeGem).not_to be_const_defined(:SomeModel)
        end
      end

      shared_examples :finds_model do
        it "finds the model" do
          gem.load!
          expect(SomeGem).to be_const_defined(:SomeModel)
        end
      end

      context "when model is not defined" do
        include_examples :does_not_find_model
      end

      context "when model is defined" do
        before do
          gem.path("models", ext: nil).mkdir

          model_path.write(<<~RUBY)
            module SomeGem
              class SomeModel < Sequel::Model
                def default = nil
              end
            end
          RUBY
        end

        context "and model exists in gem base directory" do
          let(:model_path) { gem.path("some_model") }

          include_examples :finds_model
        end

        context "and model exists in models directory" do
          let(:model_path) { gem.path("models", "some_model") }

          include_examples :finds_model
        end
      end
    end
  end
end
