require "test_helper"

class PartialOverridingTest < ActionDispatch::IntegrationTest
  def test_default_partial
    visit godmin.new_article_path
    assert page.has_content? "Title"
  end

  def test_override_partial
    add_template "app/views/godmin/articles/_form.html.erb", "foo"
    visit godmin.new_article_path
    assert page.has_content? "foo"
  end

  def test_override_resource_partial
    add_template "app/views/godmin/resource/_form.html.erb", "foo"
    visit godmin.new_article_path
    assert page.has_content? "foo"
  end

  def test_override_partial_and_resource_partial
    add_template "app/views/godmin/articles/_form.html.erb", "foo"
    add_template "app/views/godmin/resource/_form.html.erb", "bar"
    visit godmin.new_article_path
    assert page.has_content? "foo"
  end
end
