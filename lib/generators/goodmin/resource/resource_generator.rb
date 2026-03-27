require "goodmin/generators/named_base"

class Goodmin::ResourceGenerator < Goodmin::Generators::NamedBase
  argument :attributes, type: :array, default: [], banner: "attribute attribute"

  def add_route
    invoke "resource_route"
  end

  def add_navigation
    append_to_file "app/views/goodmin/shared/_navigation.html.erb" do
      <<-END.strip_heredoc
        <%= navbar_item #{class_name} %>
      END
    end
  end

  def create_model
    if namespaced?
      template "resource_model.rb", File.join("app/models", class_path, "#{file_name}.rb")
    end
  end

  def create_controller
    if namespaced?
      template "resource_controller.rb", File.join("app/controllers", class_path, "#{file_name.pluralize}_controller.rb")
    else
      template "resource_controller.rb", File.join("app/controllers", "goodmin", "#{file_name.pluralize}_controller.rb")
    end
  end

  def create_resource
    template "resource.rb", File.join("app/goodmin/resources", "#{file_name}_resource.rb")
  end
end
