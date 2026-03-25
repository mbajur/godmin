require "test_helper"

class NestedResourcesTest < ActionDispatch::IntegrationTest
  def test_list_nested_resources
    article = Article.create! title: "foo", comments: [
      Comment.new(title: "bar")
    ]

    visit godmin.articles_path
    within "[data-resource-id='#{article.id}']" do
      click_link "Show"
    end
    click_link "Comments"

    assert_equal godmin.article_comments_path(article), current_path
    assert page.has_content? "bar"
  end

  def test_list_nested_resources_scoping
    article = Article.create! title: "foo", comments: [
      Comment.new(title: "bar")
    ]
    Comment.create! title: "baz"

    visit godmin.article_comments_path(article)

    assert page.has_content? "bar"
    assert page.has_no_content? "baz"
  end

  def test_create_nested_resource
    article = Article.create! title: "foo"

    visit godmin.new_article_comment_path(article)

    fill_in "Title", with: "bar"
    click_button "Create Comment"

    assert_equal godmin.article_comment_path(article, Comment.last), current_path

    within "#breadcrumb" do
      click_link "Comments"
    end

    assert page.has_content? "bar"
  end

  def test_breadcrumb_uses_parent_display_name
    article = Article.create! title: "foo"

    visit godmin.article_comments_path(article)

    within "#breadcrumb" do
      assert page.has_content? "Article: foo"
    end
  end
end
