RSpec.describe Kangaru::Inflectors::PathInflector do
  subject(:inflector) { described_class.new(string) }

  describe "#inflect" do
    subject(:inflection) { inflector.inflect(**options) }

    let(:options) { { with_ext: }.compact }

    context "when extension is not specified" do
      let(:with_ext) { nil }

      include_examples :runs_inflections, [
        { from: "foo_bar_baz",     to: "foo_bar_baz" },
        { from: "foo_bar__baz",    to: "foo_bar_baz" },
        { from: "foo__bar_baz",    to: "foo_bar_baz" },
        { from: "foo__bar__baz",   to: "foo_bar_baz" },

        { from: "foo-bar-baz",     to: "foo_bar_baz" },
        { from: "foo--bar--baz",   to: "foo_bar_baz" },
        { from: "foo-bar--baz",    to: "foo_bar_baz" },
        { from: "foo--bar-baz",    to: "foo_bar_baz" },

        { from: "fooBarBaz",       to: "foo_bar_baz" },
        { from: "FooBarBaz",       to: "foo_bar_baz" },
        { from: "FOOBARBAZ",       to: "foobarbaz" },
        { from: "FOO_BAR_BAZ",     to: "foo_bar_baz" },

        { from: "Foo::Bar::Baz",   to: "foo/bar/baz" },
        { from: "Foo::BarBaz",     to: "foo/bar_baz" },
        { from: "FooBar::Baz",     to: "foo_bar/baz" },

        { from: "::FOOBARBAZ",     to: "/foobarbaz" },
        { from: "::Foo::Bar::Baz", to: "/foo/bar/baz" },
        { from: "::Foo::BarBaz",   to: "/foo/bar_baz" },
        { from: "::FooBar::Baz",   to: "/foo_bar/baz" },
        { from: "::FooBarBaz",     to: "/foo_bar_baz" },
        { from: "::FOO_BAR_BAZ",   to: "/foo_bar_baz" },

        { from: "foo_bar_baz.rb",  to: "foo_bar_baz" },
        { from: "foo/bar/baz.rb",  to: "foo/bar/baz" },
        { from: "foo/barBaz.rb",   to: "foo/bar_baz" },
        { from: "/foo_bar_baz.rb", to: "/foo_bar_baz" },
        { from: "/foo/bar/baz.rb", to: "/foo/bar/baz" },
        { from: "/foo/barBaz.rb",  to: "/foo/bar_baz" }
      ]
    end

    context "when extension is specified" do
      let(:with_ext) { "rb" }

      include_examples :runs_inflections, [
        { from: "foo_bar_baz",     to: "foo_bar_baz.rb" },
        { from: "foo_bar__baz",    to: "foo_bar_baz.rb" },
        { from: "foo__bar_baz",    to: "foo_bar_baz.rb" },
        { from: "foo__bar__baz",   to: "foo_bar_baz.rb" },

        { from: "foo-bar-baz",     to: "foo_bar_baz.rb" },
        { from: "foo--bar--baz",   to: "foo_bar_baz.rb" },
        { from: "foo-bar--baz",    to: "foo_bar_baz.rb" },
        { from: "foo--bar-baz",    to: "foo_bar_baz.rb" },

        { from: "fooBarBaz",       to: "foo_bar_baz.rb" },
        { from: "FooBarBaz",       to: "foo_bar_baz.rb" },
        { from: "FOOBARBAZ",       to: "foobarbaz.rb" },
        { from: "FOO_BAR_BAZ",     to: "foo_bar_baz.rb" },

        { from: "Foo::Bar::Baz",   to: "foo/bar/baz.rb" },
        { from: "Foo::BarBaz",     to: "foo/bar_baz.rb" },
        { from: "FooBar::Baz",     to: "foo_bar/baz.rb" },

        { from: "::FOOBARBAZ",     to: "/foobarbaz.rb" },
        { from: "::Foo::Bar::Baz", to: "/foo/bar/baz.rb" },
        { from: "::Foo::BarBaz",   to: "/foo/bar_baz.rb" },
        { from: "::FooBar::Baz",   to: "/foo_bar/baz.rb" },
        { from: "::FooBarBaz",     to: "/foo_bar_baz.rb" },
        { from: "::FOO_BAR_BAZ",   to: "/foo_bar_baz.rb" },

        { from: "foo_bar_baz.rb",  to: "foo_bar_baz.rb" },
        { from: "foo/bar/baz.rb",  to: "foo/bar/baz.rb" },
        { from: "foo/barBaz.rb",   to: "foo/bar_baz.rb" },
        { from: "/foo_bar_baz.rb", to: "/foo_bar_baz.rb" },
        { from: "/foo/bar/baz.rb", to: "/foo/bar/baz.rb" },
        { from: "/foo/barBaz.rb",  to: "/foo/bar_baz.rb" }
      ]
    end
  end
end
