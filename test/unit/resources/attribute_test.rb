require "test_helper"

module Goodmin
  class AttributeTest < ActiveSupport::TestCase
    module TestScope
      class ProfileResource
        include Goodmin::Resources::Resource

        form do
          attribute :bio
          attribute :website
        end
      end

      class Profile
        def self.name
          "Goodmin::AttributeTest::TestScope::Profile"
        end
      end

      class ArticleResource
        include Goodmin::Resources::Resource
      end

      class Article
        def self.reflect_on_association(name)
          case name
          when :profile
            Struct.new(:klass, :macro, :options).new(Profile, :has_one, {})
          when :comments
            Struct.new(:klass, :macro, :options).new(nil, :has_many, {})
          end
        end

        def self.defined_enums
          { "status" => { "draft" => 0, "published" => 1 } }
        end

        def self.has_attribute?(_name)
          false
        end
      end
    end

    def build_attribute(name)
      Resources::Attribute.new(name)
    end

    def to_field(attribute_name)
      build_attribute(attribute_name).to_field(
        record: TestScope::Article.new,
        resource_service: TestScope::ArticleResource.new
      )
    end

    def test_has_one_association_resolves_to_nested_has_one_field
      field = to_field(:profile)
      assert_instance_of Fields::NestedHasOne, field
    end

    def test_has_many_association_resolves_to_association_field
      field = to_field(:comments)
      assert_instance_of Fields::Association, field
    end

    def test_enum_attribute_resolves_to_enum_field
      field = to_field(:status)
      assert_instance_of Fields::Enum, field
    end

    def test_explicit_field_class_is_respected
      attribute = Resources::Attribute.new(:profile, field_class: Fields::Association)
      field = attribute.to_field(
        record: TestScope::Article.new,
        resource_service: TestScope::ArticleResource.new
      )
      assert_instance_of Fields::Association, field
    end
  end
end
