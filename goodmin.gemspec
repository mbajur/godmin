require_relative "lib/goodmin/version"

Gem::Specification.new do |spec|
  spec.name        = "goodmin"
  spec.version     = Goodmin::VERSION
  spec.authors     = ["Jens Ljungblad", "Linus Pettersson", "Varvet", "Mike Bajur"]
  spec.email       = ["mbajur@gmail.com"]
  spec.homepage    = "https://github.com/mbajur/goodmin"
  spec.summary     = "Goodmin is an admin framework for Rails 8+"
  spec.description = "Goodmin is an admin framework for Rails 8+. Use it to build dedicated admin sections for your apps, or stand alone admin apps such as internal tools."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mbajur/goodmin"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", [">= 5.0", "< 9.0"]
  spec.add_dependency "csv", ">= 3.0"
  spec.add_dependency "csv_builder", "~> 2.1"
  spec.add_dependency "pundit", [">= 2.2.0", "< 3.0"]
  spec.add_dependency "importmap-rails"
  spec.add_dependency "propshaft"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "bcrypt", [">= 3.0", "< 4.0"]

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bootsnap"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "cuprite"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "sqlite3"
end
