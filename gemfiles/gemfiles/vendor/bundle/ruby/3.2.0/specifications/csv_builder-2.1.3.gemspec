# -*- encoding: utf-8 -*-
# stub: csv_builder 2.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "csv_builder".freeze
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Econsultancy".freeze, "Vidmantas Kabosis".freeze, "Gabe da Silveira".freeze]
  s.date = "2012-05-24"
  s.description = "CSV template handler for Rails.  Enables :format => 'csv' in controllers, with templates of the form report.csv.csvbuilder.".freeze
  s.email = "gabe@websaviour.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "https://github.com/gtd/csv_builder".freeze
  s.licenses = ["MIT".freeze]
  s.requirements = ["iconv or Ruby 1.9".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "CSV template handler for Rails".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 3.0.0"])
  s.add_development_dependency(%q<rails>.freeze, [">= 4.0.0", "< 5.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 2.5"])
  s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 2.5"])
  s.add_development_dependency(%q<rack>.freeze, [">= 0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0", "< 1.4"])
end
