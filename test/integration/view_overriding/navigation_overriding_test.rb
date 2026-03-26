require "test_helper"

class NavigationOverridingTest < ActionDispatch::IntegrationTest
  def test_application_navigation_is_used_for_resource_pages
    remove_template "app/views/godmin/shared/_navigation.html.erb"
    add_template "app/views/godmin/application/_navigation.html.erb", "application-nav-marker"

    visit articles_path

    assert page.has_content? "application-nav-marker"
  end

  def test_shared_navigation_takes_priority_over_application_navigation
    add_template "app/views/godmin/shared/_navigation.html.erb", "shared-nav-marker"
    add_template "app/views/godmin/application/_navigation.html.erb", "application-nav-marker"

    visit articles_path

    assert page.has_content? "shared-nav-marker"
    assert page.has_no_content? "application-nav-marker"
  end

  def test_application_navigation_is_used_for_resource_pages_in_engine
    remove_template "admin/app/views/admin/shared/_navigation.html.erb"
    add_template "admin/app/views/admin/application/_navigation.html.erb", "engine-application-nav-marker"

    visit admin.articles_path

    assert page.has_content? "engine-application-nav-marker"
  end
end
