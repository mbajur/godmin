class ProfileService
  include Goodmin::Resources::ResourceService

  form do
    row do
      col(size: 6) { attribute :bio }
      col(size: 6) { attribute :website }
    end
  end
end
