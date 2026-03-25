require "test_helper"

class AuthorizationTest < ActionDispatch::IntegrationTest
  def test_can_index?
    visit godmin.authorized_articles_path
    assert_equal 200, page.status_code
  end

  def test_can_show?
    article = Article.create! title: "foo"

    visit godmin.authorized_articles_path
    within "[data-resource-id='#{article.id}']" do
      click_link "Show"
    end

    assert_equal godmin.article_path(article), current_path
    assert_equal 200, page.status_code
  end

  def test_cannot_destroy?
    article = Article.create! title: "foo"

    visit godmin.authorized_articles_path
    within "[data-resource-id='#{article.id}']" do
      assert page.has_no_content? "Destroy"
    end

    page.driver.delete godmin.authorized_article_path(article)
    assert_equal 403, page.status_code
  end
end
