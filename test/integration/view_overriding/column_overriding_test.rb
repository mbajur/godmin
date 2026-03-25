require "test_helper"

class ColumnOverridingTest < ActionDispatch::IntegrationTest
  def test_default_column
    Article.create! title: "foo"
    visit godmin.articles_path
    assert find("#table").has_content? "foo"
  end

  def test_override_column
    Article.create! title: "foo"
    add_template "app/views/godmin/articles/columns/_title.html.erb", "bar"
    visit godmin.articles_path
    assert find("#table").has_content? "bar"
  end

  def test_override_resource_column
    Article.create! title: "foo"
    add_template "app/views/godmin/resource/columns/_title.html.erb", "bar"
    visit godmin.articles_path
    assert find("#table").has_content? "bar"
  end

  def test_override_column_and_resource_column
    Article.create! title: "foo"
    add_template "app/views/godmin/articles/columns/_title.html.erb", "bar"
    add_template "app/views/godmin/resource/columns/_title.html.erb", "baz"
    visit godmin.articles_path
    assert find("#table").has_content? "bar"
  end
end
