module Goodmin
  module Resources
    class CommentResource
      include Goodmin::Resources::Resource

      index do
        attribute :id
        attribute :title
      end

      show do
        attribute :id
        attribute :title
        attribute :body
      end

      form do
        attribute :title
        attribute :body
      end
    end
  end
end
