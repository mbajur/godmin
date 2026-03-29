require "test_helper"

module Goodmin
  class NestedHasOneFieldTest < ActiveSupport::TestCase
    # Minimal fake models and resources used exclusively in this test
    module TestScope
      class ProfileResource
        include Goodmin::Resources::Resource

        index do
          attribute :bio
          attribute :website
        end

        form do
          attribute :bio
          attribute :website
        end
      end

      class Profile
        def self.name
          "Goodmin::NestedHasOneFieldTest::TestScope::Profile"
        end
      end

      class Article
        def self.reflect_on_association(name)
          return nil unless name == :profile

          Struct.new(:klass).new(Profile)
        end

        def profile
          @profile ||= Profile.new
        end

        def build_profile
          Profile.new
        end
      end

      class ArticleResource
        include Goodmin::Resources::Resource
      end
    end

    def setup
      @record = TestScope::Article.new
      @resource_service = TestScope::ArticleResource.new
      @field = Fields::NestedHasOne.new(
        attribute: :profile,
        record: @record,
        resource_service: @resource_service
      )
    end

    def test_associated_record_returns_existing_record
      assert_instance_of TestScope::Profile, @field.associated_record
    end

    def test_associated_service_finds_service_by_convention
      assert_instance_of TestScope::ProfileResource, @field.associated_service
    end

    def test_nested_attributes_returns_form_attrs_from_associated_service
      attrs = @field.nested_attributes
      assert_equal [:bio, :website], attrs.map(&:name)
    end

    def test_nested_attributes_returns_empty_when_no_service
      field = Fields::NestedHasOne.new(
        attribute: :missing,
        record: TestScope::Article.new,
        resource_service: @resource_service
      )
      assert_equal [], field.nested_attributes
    end

    def test_nested_permitted_attributes_calls_permitted_attribute_on_sub_fields
      # A field whose permitted_attribute returns a hash (e.g. for JSON/hash attributes)
      hash_field_class = Class.new(Goodmin::Fields::Base) do
        def permitted_attribute
          { attribute => [:foo, :bar] }
        end
      end

      profile_resource = Class.new do
        include Goodmin::Resources::Resource
        form { attribute :properties, as: hash_field_class }
      end

      field = Class.new(Goodmin::Fields::NestedHasOne) do
        define_method(:associated_service) { profile_resource.new }
        define_method(:nested_record_instance) { TestScope::Profile.new }
      end.new(
        attribute: :profile,
        record: @record,
        resource_service: @resource_service
      )

      permitted = field.nested_permitted_attributes
      assert_includes permitted, { properties: [:foo, :bar] },
        "Expected hash permitted_attribute from sub-field to be included recursively"
      assert_not_includes permitted, :properties,
        "Expected bare :properties symbol NOT to appear when a hash is returned"
    end

    def test_partial_paths
      assert_equal "goodmin/fields/nested_has_one/form", Fields::NestedHasOne.partial_form
      assert_equal "goodmin/fields/nested_has_one/index", Fields::NestedHasOne.partial_index
      assert_equal "goodmin/fields/nested_has_one/show", Fields::NestedHasOne.partial_show
    end
  end
end
