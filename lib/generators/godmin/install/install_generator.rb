require "godmin/generators/base"

class Godmin::InstallGenerator < Godmin::Generators::Base
  class_option :routing, type: :string, default: "engine",
    desc: "Routing strategy: 'engine' (mount Godmin::Engine) or 'namespace' (namespace :godmin in host routes)"

  def create_routes
    if options[:routing] == "namespace"
      inject_into_file "config/routes.rb", before: /^end/ do
        <<-END.strip_heredoc.indent(2)
          namespace :godmin, path: :admin do
            # Add admin routes here, e.g.:
            # resources :articles
          end
        END
      end
    else
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
  end

  def create_navigation
    create_file File.join("app/views", admin_path, "shared/_navigation.html.erb")
  end
end
