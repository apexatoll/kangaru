RSpec.configure do |config|
  path_tags = {
    %r{spec/features} => { type: :feature }
  }.freeze

  path_tags.each do |file_path, tags|
    config.define_derived_metadata(file_path:) do |metadata|
      metadata.merge!(tags)
    end
  end
end
