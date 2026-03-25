require "godmin/generators/base"

class Godmin::InstallGenerator < Godmin::Generators::Base
  def create_routes
    inject_into_file "config/routes.rb", before: /^end/ do
      <<-END.strip_heredoc.indent(2)
        mount Godmin::Engine, at: "/admin"

        Godmin::Engine.routes.draw do
          # Add admin routes here, e.g.:
          # resources :articles
        end
      END
    end
  end

  def create_navigation
    create_file File.join("app/views", admin_path, "shared/_navigation.html.erb")
  end
end
