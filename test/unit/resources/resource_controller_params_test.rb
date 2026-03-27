require "test_helper"

module Goodmin
  class ResourceControllerParamsTest < ActiveSupport::TestCase
    # Minimal stubs used exclusively in this test
    module TestScope
      class Author
        def self.reflect_on_association(name)
          case name
          when :editor
            Struct.new(:macro, :foreign_key, keyword_init: true).new(
              macro: :belongs_to, foreign_key: "editor_id"
            )
          end
        end
      end

      class AuthorResource
        include Goodmin::Resources::Resource

        form do
          attribute :name
          attribute :editor
        end
      end

      # A minimal controller object that exposes resource_params_defaults
      # without needing the full ActionController stack.
      class FakeController
        # Stub ActionController class-level methods used in included blocks
        def self.helper(*) end
        def self.before_action(*) end
        def self.prepend_before_action(*) end

        include Goodmin::Resources::ResourceController

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

    def test_plain_attributes_are_permitted
      params = @controller.resource_params_defaults
      assert_includes params, :name
    end

    def test_belongs_to_association_uses_foreign_key
      params = @controller.resource_params_defaults
      assert_includes params, :editor_id
      assert_not_includes params, :editor
    end
  end
end
