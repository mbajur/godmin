require "test_helper"

class ManyToManyAssociationsTest < ActionDispatch::IntegrationTest
  def test_create_resource_with_many_to_many_association
    magazine = Magazine.create! name: "Wired"

    visit godmin.new_article_path

    fill_in "Title", with: "foo"
    select "Wired", from: "Magazines"
    click_button "Create Article"

    assert_equal godmin.article_path(Article.last), current_path
    assert_equal [magazine], Article.last.magazines
  end

  def test_update_resource_with_many_to_many_association
    magazine = Magazine.create! name: "Wired"
    article = Article.create! title: "foo"

    visit godmin.edit_article_path(article)

    select "Wired", from: "Magazines"
    click_button "Update Article"

    assert_equal godmin.article_path(article), current_path
    assert_equal [magazine], article.reload.magazines
  end
end
