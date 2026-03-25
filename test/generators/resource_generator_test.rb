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

    def test_resource_generator
      system! "cd #{destination_root} && rails new . --skip-test --skip-spring --skip-bundle --skip-git --quiet"
      system! "cd #{destination_root} && bin/rails generate godmin:install --quiet"
      system! "cd #{destination_root} && bin/rails generate godmin:resource foo bar --quiet"

      assert_file "config/routes.rb", /resources :foos/
      assert_file "app/views/godmin/shared/_navigation.html.erb", /<%= navbar_item Foo %>/

      assert_file "app/controllers/godmin/foos_controller.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          module Godmin
            class FoosController < ApplicationController
              include Godmin::Resources::ResourceController
            end
          end
        CONTENT
        assert_match expected_content, content
      end

      assert_file "app/resources/foo_resource.rb" do |content|
        expected_content = <<-CONTENT.strip_heredoc
          class FooResource
            include Godmin::Resources::Resource

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
  end
end
