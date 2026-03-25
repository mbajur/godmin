require "test_helper"

module Godmin
  class SelectFieldTest < ActiveSupport::TestCase
    module TestScope
      class ArticleResource
        include Godmin::Resources::Resource
      end

      class Article
        attr_reader :status

        def initialize(status = nil)
          @status = status
        end
      end
    end

    def build_field(status = nil, **options)
      Field::Select.new(
        attribute: :status,
        record: TestScope::Article.new(status),
        resource_service: TestScope::ArticleResource.new,
        **options
      )
    end

    def test_collection_returns_empty_array_by_default
      assert_equal [], build_field.collection
    end

    def test_collection_returns_static_array_when_passed
      col = [["Draft", "draft"], ["Published", "published"]]
      assert_equal col, build_field(nil, collection: col).collection
    end

    def test_collection_calls_proc_with_record_when_passed
      col = ->(record) { [["Value", record.status]] }
      assert_equal [["Value", "draft"]], build_field("draft", collection: col).collection
    end

    def test_value_returns_current_attribute_value
      assert_equal "draft", build_field("draft").value
    end

    def test_enum_field_inherits_from_select_field
      assert Field::Enum < Field::Select
    end

    def test_enum_field_uses_select_form_partial
      assert_equal Field::Select.partial_form, Field::Enum.partial_form
    end
  end
end
