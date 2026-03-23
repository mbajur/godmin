class MagazineService
  include Godmin::Resources::ResourceService

  attrs_for_index :id, :name
  attrs_for_form :name
end
