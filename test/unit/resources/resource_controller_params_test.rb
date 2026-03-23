require "test_helper"

module Godmin
  class ResourceControllerParamsTest < ActiveSupport::TestCase
    # Minimal stubs used exclusively in this test
    module TestScope
      class ProfileResource
        include Godmin::Resources::Resource

        form do
          attribute :bio
          attribute :website
        end
      end

      class Profile
        def self.name
          "Godmin::ResourceControllerParamsTest::TestScope::Profile"
        end
      end

      class Author
        # Simulates accepts_nested_attributes_for :profile
        def profile_attributes=(_attributes); end

        def self.reflect_on_association(name)
          case name
          when :profile
            Struct.new(:macro, :klass, :foreign_key, :name, :options, keyword_init: true).new(
              macro: :has_one, klass: Profile, foreign_key: nil, name: :profile, options: {}
            )
          end
        end
      end

      class AuthorResource
        include Godmin::Resources::Resource

        form do
          attribute :name
          attribute :profile
        end
      end

      # A minimal controller object that exposes resource_params_defaults
      # without needing the full ActionController stack.
      class FakeController
        # Stub ActionController class-level hooks so including
        # ResourceController does not raise NoMethodError.
        def self.helper(*); end
        def self.before_action(*); end
        def self.prepend_before_action(*); end

        include Godmin::Resources::ResourceController

        # Expose the protected method for testing
        public :resource_params_defaults

        def initialize(resource_class, resource_service)
          @resource_class = resource_class
          @resource_service = resource_service
        end
      end
    end

    def setup
      @controller = TestScope::FakeController.new(
        TestScope::Author,
        TestScope::AuthorResource.new
      )
    end

    def test_nested_has_one_attributes_are_permitted
      params = @controller.resource_params_defaults
      nested_entry = params.find { |p| p.is_a?(Hash) && p.key?(:profile_attributes) }
      assert nested_entry, "Expected profile_attributes key in permitted params"
      assert_includes nested_entry[:profile_attributes], :id
      assert_includes nested_entry[:profile_attributes], :bio
      assert_includes nested_entry[:profile_attributes], :website
    end

    def test_plain_attributes_are_still_permitted
      params = @controller.resource_params_defaults
      assert_includes params, :name
    end
  end
end
