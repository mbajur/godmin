require "test_helper"

module Godmin
  class BaseFieldTest < ActiveSupport::TestCase
    module TestScope
      class ArticleResource
        include Godmin::Resources::Resource
      end

      class Article
        include ActiveModel::Model

        def self.model_name
          ActiveModel::Name.new(self, nil, "Article")
        end

        attr_accessor :title

        def initialize(title: nil)
          @title = title
        end
      end
    end

    def build_field(**options)
      Fields::String.new(
        attribute: :title,
        record: TestScope::Article.new,
        resource_service: TestScope::ArticleResource.new,
        **options
      )
    end

    def test_hint_returns_string_when_hint_option_is_a_string
      field = build_field(hint: "Enter the article title")
      assert_equal "Enter the article title", field.hint
    end

    def test_hint_calls_proc_with_record_when_hint_option_is_a_proc
      record = TestScope::Article.new(title: "Hello")
      field = Fields::String.new(
        attribute: :title,
        record: record,
        resource_service: TestScope::ArticleResource.new,
        hint: ->(r) { "Current: #{r.title}" }
      )
      assert_equal "Current: Hello", field.hint
    end

    def test_hint_falls_back_to_i18n_when_no_option_is_set
      I18n.backend.store_translations(:en, activerecord: { hints: { article: { title: "The article title hint" } } })
      field = build_field
      assert_equal "The article title hint", field.hint
    ensure
      I18n.backend.reload!
    end

    def test_hint_returns_nil_when_neither_option_nor_i18n_key_is_set
      field = build_field
      assert_nil field.hint
    end

    def test_hint_prefers_option_over_i18n
      I18n.backend.store_translations(:en, activerecord: { hints: { article: { title: "The i18n hint" } } })
      field = build_field(hint: "The explicit hint")
      assert_equal "The explicit hint", field.hint
    ensure
      I18n.backend.reload!
    end

    def test_partial_paths_for_custom_field_class
      custom_field_class = Class.new(Fields::Base) do
        def self.name
          "Godmin::Fields::Color"
        end
      end
      assert_equal "godmin/fields/color/index", custom_field_class.partial_index
      assert_equal "godmin/fields/color/show", custom_field_class.partial_show
      assert_equal "godmin/fields/color/form", custom_field_class.partial_form
    end
  end
end
