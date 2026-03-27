require "test_helper"
require "generators/goodmin/resource/resource_generator"

module Goodmin
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

    def test_resource_generator_in_standalone_install
      system! "cd #{destination_root} && rails new . --skip-test --skip-spring --skip-bundle --skip-git --quiet"
      system! "cd #{destination_root} && bin/rails generate goodmin:install --quiet"
      system! "cd #{destination_root} && bin/rails generate goodmin:resource foo bar --quiet"

      assert_file "config/routes.rb", /mount Goodmin::Engine/
      assert_file "config/routes.rb", /resources :foos/
      assert_file "app/views/goodmin/shared/_navigation.html.erb", /<%= navbar_item Foo %>/

      assert_file "app/controllers/goodmin/base_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Goodmin
            class BaseController < ActionController::Base
              include Goodmin::ApplicationController
            end
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "app/controllers/foos_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          class FoosController < Goodmin::BaseController
            include Goodmin::Resources::ResourceController
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "app/goodmin/resources/foo_resource.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Goodmin
            module Resources
              class FooResource
                include Goodmin::Resources::Resource

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
          end
        CONTENT
        assert_match expected_content, content
      end
    end

    def test_resource_generator_in_engine_install
      system! "cd #{destination_root} && rails new . --skip-test --skip-spring --skip-bundle --skip-git --quiet"
      system! "cd #{destination_root} && bin/rails plugin new fakemin --mountable --quiet"
      system! "cd #{destination_root} && fakemin/bin/rails generate goodmin:install --quiet"
      system! "cd #{destination_root} && fakemin/bin/rails generate goodmin:resource foo bar --quiet"

      assert_file "fakemin/config/routes.rb", /resources :foos/
      assert_file "fakemin/app/views/goodmin/shared/_navigation.html.erb", /<%= navbar_item Foo %>/

      assert_file "fakemin/app/controllers/goodmin/base_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Goodmin
            class BaseController < ActionController::Base
              include Goodmin::ApplicationController
            end
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "fakemin/app/controllers/fakemin/foos_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Fakemin
            class FoosController < Goodmin::BaseController
              include Goodmin::Resources::ResourceController
            end
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "fakemin/app/goodmin/resources/foo_resource.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Goodmin
            module Resources
              class FooResource
                include Goodmin::Resources::Resource

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
          end
        CONTENT
        assert_match expected_content, content
      end
    end
  end
end
