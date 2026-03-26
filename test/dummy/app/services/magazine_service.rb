class MagazineService
  include Goodmin::Resources::ResourceService

  index do
    attribute :id
    attribute :name
  end

  form do
    attribute :name
  end
end
