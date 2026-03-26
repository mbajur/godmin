require "test_helper"

module Godmin
  class ResourceServiceTest < ActiveSupport::TestCase
    def setup
      @article_resource = Fakes::ArticleResource.new
    end

    def test_resource_class
      assert_equal Fakes::Article, @article_resource.resource_class
    end

    def test_attrs_for_index
      attrs = @article_resource.attrs_for_index
      assert_equal [:id, :title, :country], attrs.map(&:name)
      assert attrs.all? { |a| a.is_a?(Resources::Attribute) }
    end

    def test_attrs_for_show
      attrs = @article_resource.attrs_for_show
      assert_equal [:title, :country], attrs.map(&:name)
      assert attrs.all? { |a| a.is_a?(Resources::Attribute) }
    end

    def test_attrs_for_form
      attrs = @article_resource.attrs_for_form
      assert_equal [:id, :title, :country, :body], attrs.map(&:name)
      assert attrs.all? { |a| a.is_a?(Resources::Attribute) }
    end

    def test_attrs_for_export
      attrs = @article_resource.attrs_for_export
      assert_equal [:id, :title], attrs.map(&:name)
      assert attrs.all? { |a| a.is_a?(Resources::Attribute) }
    end

    def test_attribute_with_custom_field
      klass = Class.new do
        include Godmin::Resources::Resource

        index do
          attribute :title, field: Fields::Text
        end
      end
      attrs = klass.attrs_for_index
      assert_equal :title, attrs.first.name
      assert_equal Fields::Text, attrs.first.field_class
    end

    def test_attribute_with_extra_options
      val = ->(record) { record.to_s }
      klass = Class.new do
        include Godmin::Resources::Resource

        index do
          attribute :title, field: Fields::Text, value: val, label: "My Label"
        end
      end
      attr = klass.attrs_for_index.first
      assert_equal val, attr.options[:value]
      assert_equal "My Label", attr.options[:label]
    end

    def test_display_name
      record = Object.new
      def record.to_s; "my record"; end
      assert_equal "my record", @article_resource.display_name(record)
    end
  end
end
