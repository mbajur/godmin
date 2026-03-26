require "test_helper"

module Godmin
  class ResolverTest < ActiveSupport::TestCase
    def test_engine_resolver_when_not_namespaced
      resolver = EngineResolver.new("articles")

      assert_equal [
        "resource",
        "shared"
      ], resolver.template_paths("articles")
    end

    def test_engine_resolver_when_namespaced
      resolver = EngineResolver.new("godmin/resolver_test/admin/articles")

      assert_equal [
        "godmin/resolver_test/admin/resource",
        "godmin/resolver_test/admin/shared"
      ], resolver.template_paths("godmin/resolver_test/admin/articles")
    end

    def test_engine_resolver_with_subpath_when_not_namespaced
      resolver = EngineResolver.new("articles")

      assert_equal [
        "resource/columns",
        "shared/columns"
      ], resolver.template_paths("articles/columns")
    end

    def test_engine_resolver_with_subpath_when_namespaced
      resolver = EngineResolver.new("godmin/resolver_test/admin/articles")

      assert_equal [
        "godmin/resolver_test/admin/resource/columns",
        "godmin/resolver_test/admin/shared/columns"
      ], resolver.template_paths("godmin/resolver_test/admin/articles/columns")
    end

    def test_godmin_resolver_when_not_namespaced
      resolver = GodminResolver.new("articles")

      assert_equal [
        "articles",
        "resource",
        "shared"
      ], resolver.template_paths("articles")
    end

    def test_godmin_resolver_when_namespaced
      resolver = GodminResolver.new("godmin/resolver_test/admin/articles")

      assert_equal [
        "articles",
        "resource",
        "shared"
      ], resolver.template_paths("godmin/resolver_test/admin/articles")
    end

    def test_godmin_resolver_with_subpath_when_not_namespaced
      resolver = GodminResolver.new("articles")

      assert_equal [
        "articles/columns",
        "resource/columns",
        "shared/columns"
      ], resolver.template_paths("articles/columns")
    end

    def test_godmin_resolver_with_subpath_when_namespaced
      resolver = GodminResolver.new("godmin/resolver_test/admin/articles")

      assert_equal [
        "articles/columns",
        "resource/columns",
        "shared/columns"
      ], resolver.template_paths("godmin/resolver_test/admin/articles/columns")
    end
  end
end
