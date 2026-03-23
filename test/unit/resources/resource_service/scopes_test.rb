require "test_helper"

module Godmin
  module Resource
    class ScopesTest < ActiveSupport::TestCase
      def setup
        @article_resource = Fakes::ArticleResource.new
      end

      def test_returns_resources_when_no_scopes_are_defined
        resource_class = Class.new do
          include Godmin::Resources::Resource
        end

        resource = resource_class.new
        assert_equal :resources, resource.apply_scope("", :resources)
      end

      def test_calls_default_scope
        @article_resource.apply_scope("", :resources)
        assert_equal :resources, @article_resource.called_methods[:scopes][:unpublished]
      end

      def test_calls_non_default_scope
        @article_resource.apply_scope("published", :resources)
        assert_equal :resources, @article_resource.called_methods[:scopes][:published]
      end

      def test_calls_unimplemented_scope
        assert_raises NotImplementedError do
          @article_resource.apply_scope("trashed", :resources)
        end
      end

      def test_current_scope
        @article_resource.apply_scope("", :resources)
        assert_equal "unpublished", @article_resource.scope
      end

      def test_currently_scoped_by
        @article_resource.apply_scope("", :resources)
        assert     @article_resource.scoped_by?("unpublished")
        assert_not @article_resource.scoped_by?("published")
      end

      def test_scope_count
        assert_equal 2, @article_resource.scope_count("unpublished")
        assert_equal 1, @article_resource.scope_count("published")
      end

      def test_scope_map
        assert_equal({ default: true }, @article_resource.scope_map[:unpublished])
        assert_equal({ default: false }, @article_resource.scope_map[:published])
      end
    end
  end
end
