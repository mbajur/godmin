require "test_helper"

module Godmin
  class ResolverTest < ActiveSupport::TestCase
    def test_engine_resolver_template_paths
      resolver = EngineResolver.new("godmin/articles")

      assert_equal [
        "godmin/resource"
      ], resolver.template_paths("godmin/articles")
    end

    def test_engine_resolver_template_paths_for_nested_prefix
      resolver = EngineResolver.new("godmin/articles")

      assert_equal [
        "godmin/resource/columns"
      ], resolver.template_paths("godmin/articles/columns")
    end

    def test_godmin_resolver_template_paths
      resolver = GodminResolver.new("godmin/articles")

      assert_equal [
        "articles",
        "resource"
      ], resolver.template_paths("godmin/articles")
    end

    def test_godmin_resolver_template_paths_for_application
      resolver = GodminResolver.new("godmin/application")

      assert_equal [
        "application",
        "resource"
      ], resolver.template_paths("godmin/application")
    end
  end
end
