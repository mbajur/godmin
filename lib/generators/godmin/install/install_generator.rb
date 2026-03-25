require "godmin/generators/base"

class Godmin::InstallGenerator < Godmin::Generators::Base
  def create_routes
    if namespaced?
      inject_into_file "config/routes.rb", before: /^end/ do
        <<-END.strip_heredoc.indent(2)
          root to: "application#welcome"
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

  def modify_application_controller
    if namespaced?
      inject_into_file File.join("app/controllers", namespaced_path, "application_controller.rb"), after: "ActionController::Base\n" do
        <<-END.strip_heredoc.indent(4)
          include Godmin::ApplicationController
        END
      end
    else
      create_file "app/controllers/godmin/application_controller.rb" do
        <<-END.strip_heredoc
          module Godmin
            class ApplicationController < ActionController::Base
              include Godmin::ApplicationController
            end
          end
        END
      end
    end
  end

  def require_library_if_namespaced
    return unless namespaced?

    inject_into_file File.join("lib", namespaced_path) + ".rb", before: "require" do
      <<-END.strip_heredoc
        require "godmin"
      END
    end
  end

  def remove_layouts
    remove_dir "app/views/layouts"
  end
end
