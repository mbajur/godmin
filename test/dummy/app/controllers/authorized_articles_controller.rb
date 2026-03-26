class AuthorizedArticlesController < ArticlesController
  include Goodmin::Authorization

  def admin_user
    "admin"
  end

  def resource_service_class
    Goodmin::Resources::ArticleResource
  end
end
