module Godmin
  module Resources
    class MagazineResource
      include Godmin::Resources::Resource

      index do
        attribute :id
        attribute :name
      end

      form do
        attribute :name
      end
    end
  end
end
