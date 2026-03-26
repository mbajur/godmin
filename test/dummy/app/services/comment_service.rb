class CommentService
  include Goodmin::Resources::ResourceService

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
