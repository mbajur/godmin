require "test_helper"

module Goodmin
  class PasswordFieldTest < ActiveSupport::TestCase
    module TestScope
      class ArticleResource
        include Goodmin::Resources::Resource
      end

      class Article
        include ActiveModel::Model

        def self.model_name
          ActiveModel::Name.new(self, nil, "Article")
        end

        attr_accessor :password

        def initialize(password: nil)
          @password = password
        end
      end
    end

    def build_field(**options)
      Fields::Password.new(
        attribute: :password,
        record: TestScope::Article.new,
        resource_service: TestScope::ArticleResource.new,
        **options
      )
    end

    def test_hint_returns_string_when_hint_option_is_a_string
      field = build_field(hint: "Enter a secure password")
      assert_equal "Enter a secure password", field.hint
    end

    def test_hint_returns_nil_when_no_option_is_set
      field = build_field
      assert_nil field.hint
    end
  end
end
