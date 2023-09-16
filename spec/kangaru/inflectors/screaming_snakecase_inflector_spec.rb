RSpec.describe Kangaru::Inflectors::ScreamingSnakecaseInflector do
  subject(:inflector) { described_class.new(string) }

  describe "#inflect" do
    subject(:inflection) { inflector.inflect }

    include_examples :runs_inflections, [
      { from: "foo_bar_baz",     to: "FOO_BAR_BAZ" },
      { from: "foo_bar__baz",    to: "FOO_BAR_BAZ" },
      { from: "foo__bar_baz",    to: "FOO_BAR_BAZ" },
      { from: "foo__bar__baz",   to: "FOO_BAR_BAZ" },

      { from: "foo-bar-baz",     to: "FOO_BAR_BAZ" },
      { from: "foo--bar--baz",   to: "FOO_BAR_BAZ" },
      { from: "foo-bar--baz",    to: "FOO_BAR_BAZ" },
      { from: "foo--bar-baz",    to: "FOO_BAR_BAZ" },

      { from: "fooBarBaz",       to: "FOO_BAR_BAZ" },
      { from: "FooBarBaz",       to: "FOO_BAR_BAZ" },
      { from: "FOOBARBAZ",       to: "FOOBARBAZ" },
      { from: "FOO_BAR_BAZ",     to: "FOO_BAR_BAZ" },

      { from: "Foo::Bar::Baz",   to: "FOO::BAR::BAZ" },
      { from: "Foo::BarBaz",     to: "FOO::BAR_BAZ" },
      { from: "FooBar::Baz",     to: "FOO_BAR::BAZ" },

      { from: "::FOOBARBAZ",     to: "::FOOBARBAZ" },
      { from: "::Foo::Bar::Baz", to: "::FOO::BAR::BAZ" },
      { from: "::Foo::BarBaz",   to: "::FOO::BAR_BAZ" },
      { from: "::FooBar::Baz",   to: "::FOO_BAR::BAZ" },
      { from: "::FooBarBaz",     to: "::FOO_BAR_BAZ" },
      { from: "::FOO_BAR_BAZ",   to: "::FOO_BAR_BAZ" },

      { from: "foo_bar_baz.rb",  to: "FOO_BAR_BAZ.RB" },
      { from: "foo/bar/baz.rb",  to: "FOO::BAR::BAZ.RB" },
      { from: "foo/barBaz.rb",   to: "FOO::BAR_BAZ.RB" },
      { from: "/foo_bar_baz.rb", to: "::FOO_BAR_BAZ.RB" },
      { from: "/foo/bar/baz.rb", to: "::FOO::BAR::BAZ.RB" },
      { from: "/foo/barBaz.rb",  to: "::FOO::BAR_BAZ.RB" }
    ]
  end
end
