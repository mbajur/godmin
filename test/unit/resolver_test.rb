require "test_helper"

# Defined outside any engine namespace so EngineWrapper falls back to Rails.application
class GodminResolverTestPlainController < ActionController::Base; end

module Godmin
  class ResolverTest < ActiveSupport::TestCase
    module Admin
      class Engine < Rails::Engine
        isolate_namespace Admin
      end

      class Controller < ActionController::Base; end
    end

    # A controller whose first ancestor with use_relative_model_naming? is Godmin,
    # so EngineWrapper maps it to Godmin::Engine.
    class GodminController < ActionController::Base; end

    def setup
      @engine_wrapper_plain = EngineWrapper.new(GodminResolverTestPlainController)
      @engine_wrapper_godmin = EngineWrapper.new(GodminController)
      @engine_wrapper_admin = EngineWrapper.new(Admin::Controller)
    end

    def test_engine_resolver_when_not_namespaced
      resolver = EngineResolver.new("articles", @engine_wrapper_plain)

      assert_equal [
        "resource"
      ], resolver.template_paths("articles")
    end

    def test_engine_resolver_when_godmin_engine
      resolver = EngineResolver.new("godmin/articles", @engine_wrapper_godmin)

      assert_equal [
        "godmin/resource"
      ], resolver.template_paths("godmin/articles")
    end

    def test_engine_resolver_when_namespaced
      resolver = EngineResolver.new("godmin/resolver_test/admin/articles", @engine_wrapper_admin)

      assert_equal [
        "godmin/resolver_test/admin/resource"
      ], resolver.template_paths("godmin/resolver_test/admin/articles")
    end

    def test_godmin_resolver_when_not_namespaced
      resolver = GodminResolver.new("articles", @engine_wrapper_plain)

      assert_equal [
        "articles",
        "resource"
      ], resolver.template_paths("articles")
    end

    def test_godmin_resolver_when_godmin_engine
      resolver = GodminResolver.new("godmin/articles", @engine_wrapper_godmin)

      assert_equal [
        "articles",
        "resource"
      ], resolver.template_paths("godmin/articles")
    end

    def test_godmin_resolver_when_namespaced
      resolver = GodminResolver.new("godmin/resolver_test/admin/articles", @engine_wrapper_admin)

      assert_equal [
        "articles",
        "resource"
      ], resolver.template_paths("godmin/resolver_test/admin/articles")
    end
  end
end
