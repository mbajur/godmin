require "test_helper"

class HasManyAssociationsTest < ActionDispatch::IntegrationTest
  def test_create_resource_with_has_many_association
    comment = Comment.create! title: "A great comment"

    visit godmin.new_article_path

    fill_in "Title", with: "foo"
    select "A great comment", from: "Comments"
    click_button "Create Article"

    assert_equal godmin.article_path(Article.last), current_path
    assert_equal [comment], Article.last.comments
  end

  def test_update_resource_with_has_many_association
    comment = Comment.create! title: "A great comment"
    article = Article.create! title: "foo"

    visit godmin.edit_article_path(article)

    select "A great comment", from: "Comments"
    click_button "Update Article"

    assert_equal godmin.article_path(article), current_path
    assert_equal [comment], article.reload.comments
  end
end
