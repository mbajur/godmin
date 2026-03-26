require "test_helper"

module Goodmin
  class ResolverTest < ActiveSupport::TestCase
    def test_engine_resolver_when_not_namespaced
      resolver = EngineResolver.new("articles")

      assert_equal [
        "goodmin/resource",
        "goodmin/shared",
        "goodmin/application",
        "resource",
        "shared",
        "application"
      ], resolver.template_paths("articles")
    end

    def test_engine_resolver_when_namespaced
      resolver = EngineResolver.new("goodmin/resolver_test/admin/articles")

      assert_equal [
        "goodmin/resolver_test/admin/resource",
        "goodmin/resolver_test/admin/shared",
        "goodmin/resolver_test/admin/application"
      ], resolver.template_paths("goodmin/resolver_test/admin/articles")
    end

    def test_engine_resolver_with_subpath_when_not_namespaced
      resolver = EngineResolver.new("articles")

      assert_equal [
        "goodmin/resource/columns",
        "goodmin/shared/columns",
        "goodmin/shared",
        "goodmin/application",
        "resource/columns",
        "shared/columns",
        "shared",
        "application"
      ], resolver.template_paths("articles/columns")
    end

    def test_engine_resolver_with_subpath_when_namespaced
      resolver = EngineResolver.new("goodmin/resolver_test/admin/articles")

      assert_equal [
        "goodmin/resolver_test/admin/resource/columns",
        "goodmin/resolver_test/admin/shared/columns",
        "goodmin/resolver_test/admin/shared",
        "goodmin/resolver_test/admin/application"
      ], resolver.template_paths("goodmin/resolver_test/admin/articles/columns")
    end

    def test_goodmin_resolver_when_not_namespaced
      resolver = GoodminResolver.new("articles")

      assert_equal [
        "articles",
        "resource",
        "shared"
      ], resolver.template_paths("articles")
    end

    def test_goodmin_resolver_when_namespaced
      resolver = GoodminResolver.new("goodmin/resolver_test/admin/articles")

      assert_equal [
        "articles",
        "resource",
        "shared"
      ], resolver.template_paths("goodmin/resolver_test/admin/articles")
    end

    def test_goodmin_resolver_with_subpath_when_not_namespaced
      resolver = GoodminResolver.new("articles")

      assert_equal [
        "articles/columns",
        "resource/columns",
        "shared/columns"
      ], resolver.template_paths("articles/columns")
    end

    def test_goodmin_resolver_with_subpath_when_namespaced
      resolver = GoodminResolver.new("goodmin/resolver_test/admin/articles")

      assert_equal [
        "articles/columns",
        "resource/columns",
        "shared/columns"
      ], resolver.template_paths("goodmin/resolver_test/admin/articles/columns")
    end
  end
end
