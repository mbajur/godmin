require "test_helper"
require "generators/goodmin/field/field_generator"

module Goodmin
  class FieldGeneratorTest < ::Rails::Generators::TestCase
    tests FieldGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    def test_field_generator_creates_field_class
      run_generator ["color"]

      assert_file "app/goodmin/fields/color_field.rb" do |content|
        assert_match "class ColorField < Base", content
        assert_match "module Goodmin", content
        assert_match "module Fields", content
      end
    end

    def test_field_generator_creates_form_view
      run_generator ["color"]

      assert_file "app/views/goodmin/fields/color/_form.html.erb" do |content|
        assert_match "form-group", content
        assert_match "field.attribute", content
        assert_match "form-control", content
      end
    end

    def test_field_generator_creates_index_view
      run_generator ["color"]

      assert_file "app/views/goodmin/fields/color/_index.html.erb" do |content|
        assert_match "field.value", content
      end
    end

    def test_field_generator_creates_show_view
      run_generator ["color"]

      assert_file "app/views/goodmin/fields/color/_show.html.erb" do |content|
        assert_match "field.value", content
      end
    end
  end
end
