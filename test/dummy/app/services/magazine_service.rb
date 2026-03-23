class MagazineService
  include Godmin::Resources::ResourceService

  index do
    attribute :id
    attribute :name
  end

  form do
    attribute :name
  end
end
