RSpec.describe Kangaru::Inflectors::ClassInflector do
  subject(:inflector) { described_class.new(string) }

  describe "#inflect" do
    subject(:inflection) { inflector.inflect }

    include_examples :runs_inflections, [
      { from: "foo_bar_baz",     to: "FooBarBaz" },
      { from: "foo_bar__baz",    to: "FooBarBaz" },
      { from: "foo__bar_baz",    to: "FooBarBaz" },
      { from: "foo__bar__baz",   to: "FooBarBaz" },

      { from: "foo-bar-baz",     to: "FooBarBaz" },
      { from: "foo--bar--baz",   to: "FooBarBaz" },
      { from: "foo-bar--baz",    to: "FooBarBaz" },
      { from: "foo--bar-baz",    to: "FooBarBaz" },

      { from: "fooBarBaz",       to: "FooBarBaz" },
      { from: "FooBarBaz",       to: "FooBarBaz" },
      { from: "FOOBARBAZ",       to: "Foobarbaz" },
      { from: "FOO_BAR_BAZ",     to: "FooBarBaz" },

      { from: "Foo::Bar::Baz",   to: "Foo::Bar::Baz" },
      { from: "Foo::BarBaz",     to: "Foo::BarBaz" },
      { from: "FooBar::Baz",     to: "FooBar::Baz" },

      { from: "::FOOBARBAZ",     to: "::Foobarbaz" },
      { from: "::Foo::Bar::Baz", to: "::Foo::Bar::Baz" },
      { from: "::Foo::BarBaz",   to: "::Foo::BarBaz" },
      { from: "::FooBar::Baz",   to: "::FooBar::Baz" },
      { from: "::FooBarBaz",     to: "::FooBarBaz" },
      { from: "::FOO_BAR_BAZ",   to: "::FooBarBaz" },

      { from: "foo_bar_baz.rb",  to: "FooBarBaz" },
      { from: "foo/bar/baz.rb",  to: "Foo::Bar::Baz" },
      { from: "foo/barBaz.rb",   to: "Foo::BarBaz" },
      { from: "/foo_bar_baz.rb", to: "::FooBarBaz" },
      { from: "/foo/bar/baz.rb", to: "::Foo::Bar::Baz" },
      { from: "/foo/barBaz.rb",  to: "::Foo::BarBaz" }
    ]
  end
end
