require "test_helper"

class NestedManyToManyResourcesTest < ActionDispatch::IntegrationTest
  def test_list_nested_habtm_resources
    article = Article.create! title: "foo"
    magazine = Magazine.create! name: "Wired"
    article.magazines << magazine

    visit godmin.article_magazines_path(article)

    assert page.has_content? "Wired"
  end

  def test_list_nested_habtm_resources_scoping
    article = Article.create! title: "foo"
    magazine = Magazine.create! name: "Wired"
    other_magazine = Magazine.create! name: "National Geographic"
    article.magazines << magazine

    visit godmin.article_magazines_path(article)

    assert page.has_content? "Wired"
    assert page.has_no_content? "National Geographic"
  end

  def test_new_nested_habtm_resource_renders_form
    article = Article.create! title: "foo"

    visit godmin.new_article_magazine_path(article)

    assert page.has_field? "Name"
  end
end
