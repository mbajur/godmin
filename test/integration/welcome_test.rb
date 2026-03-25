require "test_helper"

class WelcomeTest < ActionDispatch::IntegrationTest
  def test_welcome
    visit godmin.root_path
    assert page.has_content? "Welcome"
  end
end
