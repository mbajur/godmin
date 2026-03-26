<% module_namespacing do -%>
class <%= class_name %>Policy < Goodmin::Authorization::Policy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
<% end -%>
