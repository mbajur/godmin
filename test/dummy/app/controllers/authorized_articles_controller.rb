class AuthorizedArticlesController < ArticlesController
  include Godmin::Authorization

  def admin_user
    "admin"
  end

  def resource_service_class
    Godmin::Resources::ArticleResource
  end
end
