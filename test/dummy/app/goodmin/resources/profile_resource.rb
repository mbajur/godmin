module Goodmin
  module Resources
    class ProfileResource
      include Goodmin::Resources::Resource

      form do
        attribute :bio
        attribute :website
      end
    end
  end
end
