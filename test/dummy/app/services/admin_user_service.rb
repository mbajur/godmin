class AdminUserService
  include Goodmin::Resources::ResourceService

  def display_name(record)
    record.email
  end
end
