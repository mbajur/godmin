class AnotherAdminUser < ActiveRecord::Base
  include Goodmin::Authentication::User

  def self.login_column
    :email
  end
end
