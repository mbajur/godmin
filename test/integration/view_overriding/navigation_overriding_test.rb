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

  def test_shared_navigation_is_used_when_application_navigation_does_not_exist
    add_template "app/views/godmin/shared/_navigation.html.erb", "shared-nav-marker"
    remove_template "app/views/godmin/application/_navigation.html.erb"

    visit articles_path

    assert page.has_content? "shared-nav-marker"
    assert page.has_no_content? "application-nav-marker"
  end

  def test_resource_navigation_in_main_app_takes_priority_over_engine_shared_navigation
    remove_template "app/views/godmin/shared/_navigation.html.erb"
    add_template "app/views/godmin/resource/_navigation.html.erb", "resource-nav-marker"

    visit articles_path

    assert page.has_content? "resource-nav-marker"
  end
end
