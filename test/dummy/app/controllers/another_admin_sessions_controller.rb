class AnotherAdminSessionsController < ApplicationController
  include Goodmin::Authentication::SessionsController
  include Goodmin::Authentication

  def admin_user_class
    AnotherAdminUser
  end
end
