require "test_helper"

module Godmin
  class EngineWrapperTest < ActiveSupport::TestCase
    def test_namespace
      assert_equal Godmin, EngineWrapper.new.namespace
    end

    def test_namespaced?
      assert_equal true, EngineWrapper.new.namespaced?
    end

    def test_namespaced_path
      assert_equal ["godmin"], EngineWrapper.new.namespaced_path
    end

    def test_root
      assert_equal Rails.application.root, EngineWrapper.new.root
    end
  end
end
