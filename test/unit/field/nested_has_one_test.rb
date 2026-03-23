require "test_helper"

module Godmin
  class NestedHasOneFieldTest < ActiveSupport::TestCase
    # Minimal fake models and resources used exclusively in this test
    module TestScope
      class ProfileResource
        include Godmin::Resources::Resource

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
          "Godmin::NestedHasOneFieldTest::TestScope::Profile"
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
        include Godmin::Resources::Resource
      end
    end

    def setup
      @record = TestScope::Article.new
      @resource_service = TestScope::ArticleResource.new
      @field = Field::NestedHasOne.new(
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
      field = Field::NestedHasOne.new(
        attribute: :missing,
        record: TestScope::Article.new,
        resource_service: @resource_service
      )
      assert_equal [], field.nested_attributes
    end

    def test_partial_paths
      assert_equal "godmin/fields/nested_has_one/form", Field::NestedHasOne.partial_form
      assert_equal "godmin/fields/nested_has_one/index", Field::NestedHasOne.partial_index
      assert_equal "godmin/fields/nested_has_one/show", Field::NestedHasOne.partial_show
    end
  end
end
