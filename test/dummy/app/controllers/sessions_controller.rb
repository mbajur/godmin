class SessionsController < ApplicationController
  include Goodmin::Authentication::SessionsController
  include Goodmin::Authentication

  def admin_user_class
    AdminUser
  end
end
