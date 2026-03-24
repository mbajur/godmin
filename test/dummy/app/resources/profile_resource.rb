class ProfileResource
  include Godmin::Resources::Resource

  form do
    attribute :bio
    attribute :website
  end
end
