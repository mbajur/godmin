require "test_helper"

class HasOneAssociationsTest < ActionDispatch::IntegrationTest
  def test_create_resource_with_has_one_nested_form
    visit godmin.new_article_path

    fill_in "Title", with: "foo"
    fill_in "Bio", with: "Author bio"
    fill_in "Website", with: "https://example.com"
    click_button "Create Article"

    assert_equal godmin.article_path(Article.last), current_path
    assert_not_nil Article.last.profile
    assert_equal "Author bio", Article.last.profile.bio
    assert_equal "https://example.com", Article.last.profile.website
  end

  def test_update_resource_with_has_one_nested_form
    article = Article.create! title: "foo"
    article.create_profile! bio: "Old bio", website: "https://old.com"

    visit godmin.edit_article_path(article)

    fill_in "Bio", with: "New bio"
    click_button "Update Article"

    assert_equal godmin.article_path(article), current_path
    assert_equal "New bio", article.reload.profile.bio
  end
end
