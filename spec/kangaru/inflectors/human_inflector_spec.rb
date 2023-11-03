RSpec.describe Kangaru::Inflectors::HumanInflector do
  subject(:inflector) { described_class.new(string) }

  describe "#inflect" do
    subject(:inflection) { inflector.inflect }

    include_examples :runs_inflections, [
      { from: "foo_bar_baz",     to: "Foo bar baz" },
      { from: "foo_bar__baz",    to: "Foo bar baz" },
      { from: "foo__bar_baz",    to: "Foo bar baz" },
      { from: "foo__bar__baz",   to: "Foo bar baz" },

      { from: "foo-bar-baz",     to: "Foo bar baz" },
      { from: "foo--bar--baz",   to: "Foo bar baz" },
      { from: "foo-bar--baz",    to: "Foo bar baz" },
      { from: "foo--bar-baz",    to: "Foo bar baz" },

      { from: "fooBarBaz",       to: "Foo bar baz" },
      { from: "FooBarBaz",       to: "Foo bar baz" },
      { from: "FOOBARBAZ",       to: "Foobarbaz" },
      { from: "FOO_BAR_BAZ",     to: "Foo bar baz" },

      { from: "Foo::Bar::Baz",   to: "Foo bar baz" },
      { from: "Foo::BarBaz",     to: "Foo bar baz" },
      { from: "FooBar::Baz",     to: "Foo bar baz" },

      { from: "::FOOBARBAZ",     to: "Foobarbaz" },
      { from: "::Foo::Bar::Baz", to: "Foo bar baz" },
      { from: "::Foo::BarBaz",   to: "Foo bar baz" },
      { from: "::FooBar::Baz",   to: "Foo bar baz" },
      { from: "::FooBarBaz",     to: "Foo bar baz" },
      { from: "::FOO_BAR_BAZ",   to: "Foo bar baz" },

      { from: "foo_bar_baz.rb",  to: "Foo bar baz.rb" },
      { from: "foo/bar/baz.rb",  to: "Foo bar baz.rb" },
      { from: "foo/barBaz.rb",   to: "Foo bar baz.rb" },
      { from: "/foo_bar_baz.rb", to: "Foo bar baz.rb" },
      { from: "/foo/bar/baz.rb", to: "Foo bar baz.rb" },
      { from: "/foo/barBaz.rb",  to: "Foo bar baz.rb" }
    ]
  end
end
