module Goodmin
  module Resources
    class MagazineResource
      include Goodmin::Resources::Resource

      index do
        attribute :id
        attribute :name
      end

      show do
        attribute :name
      end

      form do
        attribute :name
      end
    end
  end
end
