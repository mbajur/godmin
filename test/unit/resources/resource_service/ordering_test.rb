require "test_helper"

module Godmin
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
    end
  end
end
