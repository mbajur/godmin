class AdminUser < ActiveRecord::Base
  include Goodmin::Authentication::User

  def self.login_column
    :email
  end
end
