class AdminUserService
  include Godmin::Resources::ResourceService

  def display_name(record)
    record.email
  end
end
