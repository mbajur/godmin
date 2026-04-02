require "test_helper"

module Goodmin
  class AssociationFieldTest < ActiveSupport::TestCase
    # Fake classes scoped to this test. Museum#name returns its full constant
    # path so that safe_constantize can resolve MuseumResource the same way.
    module TestScope
      class MuseumResource
        include Goodmin::Resources::Resource

        def display_name(record)
          "display: #{record.title}"
        end
      end

      class Museum
        def self.name
          "Goodmin::AssociationFieldTest::TestScope::Museum"
        end

        def self.all
          []
        end

        attr_reader :title, :id

        def initialize(title, id)
          @title = title
          @id = id
        end

        def to_s
          "to_s: #{@title}"
        end
      end

      class UserResource
        include Goodmin::Resources::Resource
      end

      class User
        def self.reflect_on_association(assoc)
          return nil unless assoc == :museum

          Struct.new(:klass, :macro, :options).new(Museum, :belongs_to, {})
        end
      end
    end

    def build_field(**options)
      Fields::Association.new(
        attribute: :museum,
        record: TestScope::User.new,
        resource_service: TestScope::UserResource.new,
        **options
      )
    end

    def test_associated_service_finds_service_by_convention
      assert_instance_of TestScope::MuseumResource, build_field.associated_service
    end

    def test_display_name_for_uses_service_display_name
      museum = TestScope::Museum.new("The Louvre", 1)
      assert_equal "display: The Louvre", build_field.display_name_for(museum)
    end

    def test_display_name_for_returns_nil_for_nil_record
      assert_nil build_field.display_name_for(nil)
    end

    def test_collection_uses_service_display_name
      museum = TestScope::Museum.new("The Louvre", 1)
      TestScope::Museum.define_singleton_method(:all) { [museum] }
      assert_equal [["display: The Louvre", 1]], build_field.collection
    ensure
      TestScope::Museum.define_singleton_method(:all) { [] }
    end

    def test_resource_class_option_overrides_associated_service
      custom_resource = Class.new do
        include Goodmin::Resources::Resource

        def display_name(record)
          "custom: #{record.title}"
        end
      end

      field = build_field(resource_class: custom_resource)
      assert_instance_of custom_resource, field.associated_service
    end

    def test_resource_class_option_affects_display_name
      custom_resource = Class.new do
        include Goodmin::Resources::Resource

        def display_name(record)
          "custom: #{record.title}"
        end
      end

      museum = TestScope::Museum.new("The Louvre", 1)
      field = build_field(resource_class: custom_resource)
      assert_equal "custom: The Louvre", field.display_name_for(museum)
    end

    def test_select_options_returns_empty_hash_by_default
      assert_equal({}, build_field.select_options)
    end

    def test_select_options_returns_passed_options
      assert_equal({ include_blank: true }, build_field(options: { include_blank: true }).select_options)
    end

    def test_select_html_options_includes_form_select_class_by_default
      assert_equal({ class: "form-select" }, build_field.select_html_options)
    end

    def test_select_html_options_merges_passed_html_options
      result = build_field(html_options: { disabled: true }).select_html_options
      assert_equal({ class: "form-select", disabled: true }, result)
    end

    def test_select_html_options_allows_class_override
      result = build_field(html_options: { class: "my-select" }).select_html_options
      assert_equal({ class: "my-select" }, result)
    end
  end
end
