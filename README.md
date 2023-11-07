# Kangaru - A Ruby Framework for Building Command Line Applications

Kangaru is an open-source framework written in Ruby for building powerful and efficient command line applications. This project aims to make it easier for developers to create complex CLI programs with minimal effort, by providing a set of useful tools and libraries in a configurable ecosystem.

## Features

- MVC architecture drawing heavy inspiration from Rails
- ERB rendering of view templates with embedded Ruby capabilities
- SQLite and Sequel integration allowing databases to be created and used by your CLI
- A powerful command parser that routes terminal requests to their controller
- Zeitwerk-based autoloading of gem files
- Simple installation, integration and configuration


## Quick Setup

It is recommended to create a new Ruby gem for each Kangaru CLI application. This can be executed through `bundler` with the following command:

```sh
bundle gem gem_name
```

Next add Kangaru to your Gem's Gemfile and bundle install:

```ruby
# Gemfile
gem "kangaru"
```
```sh
bundle install
```

Kangaru's set up is bundled up into a single Ruby module that must be extended from the entry file for your Gem application. Conventionally this will be the Ruby file at `/gem_name/lib/gem_name.rb`, where `gem_name` is the name of the application specified with the `bundle gem` command.

For example:

```ruby
# gem_name/lib/gem_name.rb
require "kangaru"

module GemName
  extend Kangaru::Initialiser
end
```

This extension will set up Kangaru in the context of your Gem, including setting up processes such as the autoloader and config.

## Documentation
- TBC
