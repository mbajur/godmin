require "test_helper"
require "generators/godmin/resource/resource_generator"

module Godmin
  class ResourceGeneratorTest < ::Rails::Generators::TestCase
    tests ResourceGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination
    teardown :prepare_destination

    setup do
      @__env_ci = ENV["CI"]
      ENV.delete("CI")
    end

    teardown do
      ENV["CI"] = @__env_ci if @__env_ci
    end

    def system!(cmd)
      system(cmd) or fail("Failed to execute: #{cmd}")
    end

    # Rails 8 uses Propshaft by default but godmin's bundle includes Sprockets
    # (via sass-rails / bootstrap-sass). When a generated Rails 8 app is booted
    # using godmin's bundle, sprockets-rails is loaded and requires a manifest
    # file to be present. Create it so the app can boot successfully.
    def ensure_sprockets_manifest(app_root)
      config_dir = File.join(app_root, "app", "assets", "config")
      FileUtils.mkdir_p(config_dir)
      manifest = File.join(config_dir, "manifest.js")
      File.write(manifest, "//= link_tree ../images\n") unless File.exist?(manifest)
    end

    def test_resource_generator_in_standalone_install
      system! "cd #{destination_root} && rails new . --skip-test --skip-spring --skip-bundle --skip-git --quiet"
      ensure_sprockets_manifest(destination_root)
      system! "cd #{destination_root} && bin/rails generate godmin:install --quiet"
      system! "cd #{destination_root} && bin/rails generate godmin:resource foo bar --quiet"

      assert_file "config/routes.rb", /resources :foos/
      assert_file "app/views/shared/_navigation.html.erb", /<%= navbar_item Foo %>/

      assert_file "app/controllers/foos_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          class FoosController < ApplicationController
            include Godmin::Resources::ResourceController
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "app/services/foo_service.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          class FooService
            include Godmin::Resources::ResourceService

            index do
              attribute :bar
            end

            show do
              attribute :bar
            end

            form do
              attribute :bar
            end
          end
        CONTENT
        assert_match expected_content, content
      end
    end

    def test_resource_generator_in_engine_install
      system! "cd #{destination_root} && rails new . --skip-test --skip-spring --skip-bundle --skip-git --quiet"
      ensure_sprockets_manifest(destination_root)
      system! "cd #{destination_root} && bin/rails plugin new fakemin --mountable --quiet"
      system! "cd #{destination_root} && fakemin/bin/rails generate godmin:install --quiet"
      system! "cd #{destination_root} && fakemin/bin/rails generate godmin:resource foo bar --quiet"

      assert_file "fakemin/config/routes.rb", /resources :foos/
      assert_file "fakemin/app/views/fakemin/shared/_navigation.html.erb", /<%= navbar_item Foo %>/

      assert_file "fakemin/app/controllers/fakemin/foos_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Fakemin
            class FoosController < ApplicationController
              include Godmin::Resources::ResourceController
            end
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "fakemin/app/services/fakemin/foo_service.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Fakemin
            class FooService
              include Godmin::Resources::ResourceService

              index do
                attribute :bar
              end

              show do
                attribute :bar
              end

              form do
                attribute :bar
              end
            end
          end
        CONTENT
        assert_match expected_content, content
      end
    end
  end
end
