require "test_helper"

module Godmin
  class EnumFieldTest < ActiveSupport::TestCase
    module TestScope
      class ArticleResource
        include Godmin::Resources::Resource
      end

      class Article
        def self.defined_enums
          { "status" => { "draft" => 0, "published" => 1, "archived" => 2 } }
        end

        def self.reflect_on_association(_name)
          nil
        end

        attr_reader :status

        def initialize(status = nil)
          @status = status
        end
      end
    end

    def build_field(status = nil)
      Fields::Enum.new(
        attribute: :status,
        record: TestScope::Article.new(status),
        resource_service: TestScope::ArticleResource.new
      )
    end

    def test_collection_returns_humanized_key_value_pairs
      assert_equal [["Draft", "draft"], ["Published", "published"], ["Archived", "archived"]], build_field.collection
    end

    def test_value_returns_current_enum_value
      assert_equal "published", build_field("published").value
    end
  end
end
