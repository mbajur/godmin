module Admin
  class ArticleService
    include Godmin::Resources::ResourceService

    index do
      attribute :id
      attribute :title
      attribute :published
    end

    show do
      attribute :id
      attribute :title
      attribute :body
      attribute :published
    end

    form do
      attribute :title
      attribute :body
      attribute :published
    end

    filter :title
  end
end
