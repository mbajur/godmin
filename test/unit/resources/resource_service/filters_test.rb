require "test_helper"

module Goodmin
  module Resource
    class FiltersTest < ActiveSupport::TestCase
      def setup
        @article_resource = Fakes::ArticleResource.new
      end

      def test_calls_one_filter
        @article_resource.apply_filters({ title: "foobar" }, :resources)
        assert_equal [:resources, "foobar"], @article_resource.called_methods[:filters][:title]
      end

      def test_calls_multiple_filters
        @article_resource.apply_filters({ title: "foobar", country: "Sweden" }, :resources)
        assert_equal [:resources, "foobar"], @article_resource.called_methods[:filters][:title]
        assert_equal [:resources, "Sweden"], @article_resource.called_methods[:filters][:country]
      end

      def test_calls_filter_when_present_multiselect
        @article_resource.apply_filters({ tags: ["Banana"] }, :resources)
        assert_equal [:resources, ["Banana"]], @article_resource.called_methods[:filters][:tags]
      end

      def test_does_not_call_filter_when_empty_multiselect
        @article_resource.apply_filters({ tags: [""] }, :resources)
        assert_nil @article_resource.called_methods[:filters][:tags]
      end

      def test_filter_map_with_default_options
        expected_filter_map = { as: :string, option_text: "to_s", option_value: "id", collection: nil }
        assert_equal expected_filter_map, @article_resource.filter_map[:title]
      end

      def test_filter_map_with_custom_options
        expected_filter_map = { as: :select, option_text: "to_s", option_value: "id", collection: %w(Sweden Canada) }
        assert_equal expected_filter_map, @article_resource.filter_map[:country]
      end
    end
  end
end
