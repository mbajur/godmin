require "godmin/generators/named_base"

class Godmin::ResourceGenerator < Godmin::Generators::NamedBase
  argument :attributes, type: :array, default: [], banner: "attribute attribute"

  def add_route
    inject_into_file "config/routes.rb",
      "    resources :#{file_name.pluralize}\n",
      after: /Godmin::Engine\.routes\.draw do\s*\n/m
  end

  def add_navigation
    append_to_file File.join("app/views", admin_path, "shared/_navigation.html.erb") do
      <<-END.strip_heredoc
        <%= navbar_item #{class_name} %>
      END
    end
  end

  def create_controller
    template "resource_controller.rb",
      File.join("app/controllers", admin_path, class_path, "#{file_name.pluralize}_controller.rb")
  end

  def create_resource
    template "resource.rb", File.join("app/resources", class_path, "#{file_name}_resource.rb")
  end
end
