class ArticlePolicy < Goodmin::Authorization::Policy
  def index?
    true
  end

  def show?
    user == "admin"
  end

  def destroy?
    false
  end
end
