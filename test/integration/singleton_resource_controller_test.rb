require "test_helper"

class SingletonResourceControllerTest < ActionDispatch::IntegrationTest
  def test_show_singleton_resource
    Magazine.create! name: "First Magazine"

    visit magazine_path

    assert page.has_content? "First Magazine"
  end

  def test_edit_singleton_resource
    magazine = Magazine.create! name: "My Magazine"

    visit edit_magazine_path

    assert_equal edit_magazine_path, current_path
    assert page.has_field? "Name", with: magazine.name
  end

  def test_update_singleton_resource
    Magazine.create! name: "Old Name"

    visit edit_magazine_path
    fill_in "Name", with: "New Name"
    click_button "Update Magazine"

    assert page.has_content? "New Name"
    assert_equal "New Name", Magazine.first.name
  end
end
