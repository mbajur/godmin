require "goodmin/generators/named_base"

class Goodmin::ResourceGenerator < Goodmin::Generators::NamedBase
  argument :attributes, type: :array, default: [], banner: "attribute attribute"

  def add_route
    route_content = "resources :#{file_name.pluralize}"

    if namespaced?
      inject_into_file "config/routes.rb", before: /^end/ do
        "    #{route_content}\n"
      end
    else
      routes_file = File.join(destination_root, "config/routes.rb")
      if File.exist?(routes_file) && File.read(routes_file).match?(/Goodmin::Engine\.routes\.draw/)
        inject_into_file "config/routes.rb", after: /Goodmin::Engine\.routes\.draw do\s*\n/ do
          "  #{route_content}\n"
        end
      else
        append_to_file "config/routes.rb" do
          "\nGoodmin::Engine.routes.draw do\n  #{route_content}\nend\n"
        end
      end
    end
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
