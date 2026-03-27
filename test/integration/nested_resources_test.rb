require "test_helper"

class NestedResourcesTest < ActionDispatch::IntegrationTest
  def test_list_nested_resources
    article = Article.create! title: "foo", comments: [
      Comment.new(title: "bar")
    ]

    visit articles_path
    within "[data-resource-id='#{article.id}']" do
      click_link "Show"
    end
    click_link "Comments"

    assert_equal article_comments_path(article), current_path
    assert page.has_content? "bar"
  end

  def test_list_nested_resources_scoping
    article = Article.create! title: "foo", comments: [
      Comment.new(title: "bar")
    ]
    Comment.create! title: "baz"

    visit article_comments_path(article)

    assert page.has_content? "bar"
    assert page.has_no_content? "baz"
  end

  def test_create_nested_resource
    article = Article.create! title: "foo"

    visit new_article_comment_path(article)

    fill_in "Title", with: "bar"
    click_button "Create Comment"

    assert_equal article_comment_path(article, Comment.last), current_path

    within "#breadcrumb" do
      click_link "Comments"
    end

    assert page.has_content? "bar"
  end

  def test_breadcrumb_shows_sibling_dropdown_on_nested_index
    article = Article.create! title: "foo"

    visit article_comments_path(article)

    within "#breadcrumb" do
      assert page.has_css?("li.dropdown.active")
      assert page.has_content? "Comments"
      assert page.has_content? "Magazines"
    end
  end

  def test_breadcrumb_sibling_dropdown_links_to_sibling_resource
    article = Article.create! title: "foo"

    visit article_comments_path(article)

    within "#breadcrumb li.dropdown.active" do
      click_link "Magazines"
    end

    assert_equal article_magazines_path(article), current_path
  end

  def test_breadcrumb_shows_plain_text_when_not_nested
    Article.create! title: "foo"

    visit articles_path

    within "#breadcrumb" do
      assert page.has_no_css?("li.dropdown")
      assert page.has_content? "Articles"
    end
  end

  def test_breadcrumb_uses_parent_display_name
    article = Article.create! title: "foo"

    visit article_comments_path(article)

    within "#breadcrumb" do
      assert page.has_content? "Article: foo"
    end
  end
end
