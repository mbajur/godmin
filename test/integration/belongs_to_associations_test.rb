require "test_helper"

class BelongsToAssociationsTest < ActionDispatch::IntegrationTest
  def test_create_resource_with_belongs_to_association_using_display_name
    admin_user = AdminUser.create! email: "admin@example.com", password: "secretpassword"

    visit new_article_path

    fill_in "Title", with: "foo"
    select "admin@example.com", from: "Admin user"
    click_button "Create Article"

    assert_equal article_path(Article.last), current_path
    assert_equal admin_user, Article.last.admin_user
  end

  def test_index_shows_belongs_to_association_using_display_name
    admin_user = AdminUser.create! email: "admin@example.com", password: "secretpassword"
    Article.create! title: "foo", admin_user: admin_user

    visit articles_path

    assert page.has_content?("admin@example.com")
  end

  def test_show_displays_belongs_to_association_using_display_name
    admin_user = AdminUser.create! email: "admin@example.com", password: "secretpassword"
    article = Article.create! title: "foo", admin_user: admin_user

    visit article_path(article)

    assert page.has_content?("admin@example.com")
  end
end
