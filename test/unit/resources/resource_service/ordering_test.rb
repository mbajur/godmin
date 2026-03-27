require "test_helper"

module Goodmin
  module Resource
    class OrderingTest < ActiveSupport::TestCase
      def setup
        @resources_class = Class.new do
          attr_reader :order_param

          def order(order_param)
            @order_param = order_param
          end
        end

        @resources = @resources_class.new
        @article_resource = Fakes::ArticleResource.new(resources: @resources)
      end

      def test_apply_order
        resources = @resources_class.new
        @article_resource.apply_order("title_desc", resources)
        assert_equal "articles.title desc", resources.order_param
      end

      def test_apply_order_without_order
        resources = @resources_class.new
        @article_resource.apply_order("", resources)
        assert_nil resources.order_param
      end

      def test_apply_order_with_custom_ordering_method
        @article_resource.apply_order("foobar_desc", @resources)
        assert_equal [@resources, "desc"], @article_resource.called_methods[:ordering][:by_foobar]
      end

      def test_apply_order_uses_default_order_when_order_param_blank
        klass = Class.new(Fakes::ArticleResource) do
          default_order :title, :asc
          def resource_class; Fakes::Article; end
        end
        resource = klass.new(resources: @resources)
        resources = @resources_class.new
        resource.apply_order("", resources)
        assert_equal "articles.title asc", resources.order_param
      end

      def test_apply_order_explicit_param_overrides_default_order
        klass = Class.new(Fakes::ArticleResource) do
          default_order :title, :asc
          def resource_class; Fakes::Article; end
        end
        resource = klass.new(resources: @resources)
        resources = @resources_class.new
        resource.apply_order("title_desc", resources)
        assert_equal "articles.title desc", resources.order_param
      end

      def test_default_order_not_set_returns_nil
        assert_nil Fakes::ArticleResource.default_ordering
      end

      def test_default_order_set_returns_formatted_string
        resource_class = Class.new(Fakes::ArticleResource) do
          default_order :created_at, :desc
        end
        assert_equal "created_at_desc", resource_class.default_ordering
      end
    end
  end
end
