class AuthenticatedArticlesController < ArticlesController
  include Goodmin::Authentication

  def admin_user_class
    AdminUser
  end

  def resource_service_class
    Goodmin::Resources::ArticleResource
  end
end
