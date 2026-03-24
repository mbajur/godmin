class ProfileService
  include Godmin::Resources::ResourceService

  form do
    attribute :bio
    attribute :website
  end
end
