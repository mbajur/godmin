require "goodmin/generators/named_base"

class Goodmin::PolicyGenerator < Goodmin::Generators::NamedBase
  def create_policy
    template "policy.rb", File.join("app/policies", goodmin_class_path, "#{file_name}_policy.rb")
  end

  private

  def goodmin_class_path
    class_path.first == "goodmin" ? class_path : ["goodmin"] + class_path
  end
end
