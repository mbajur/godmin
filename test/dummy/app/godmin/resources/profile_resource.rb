module Godmin
  module Resources
    class ProfileResource
      include Godmin::Resources::Resource

      form do
        attribute :bio
        attribute :website
      end
    end
  end
end
