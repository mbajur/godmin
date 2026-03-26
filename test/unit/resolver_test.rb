require "test_helper"

module Godmin
  class ResolverTest < ActiveSupport::TestCase
    def test_engine_resolver_when_not_namespaced
      resolver = EngineResolver.new("articles")

      assert_equal [
        "resource"
      ], resolver.template_paths("articles")
    end

    def test_engine_resolver_when_namespaced
      resolver = EngineResolver.new("godmin/resolver_test/admin/articles")

      assert_equal [
        "godmin/resolver_test/admin/resource"
      ], resolver.template_paths("godmin/resolver_test/admin/articles")
    end

    def test_godmin_resolver_when_not_namespaced
      resolver = GodminResolver.new("articles")

      assert_equal [
        "articles",
        "resource"
      ], resolver.template_paths("articles")
    end

    def test_godmin_resolver_when_namespaced
      resolver = GodminResolver.new("godmin/resolver_test/admin/articles")

      assert_equal [
        "articles",
        "resource"
      ], resolver.template_paths("godmin/resolver_test/admin/articles")
    end
  end
end
