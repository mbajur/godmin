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
        END
      end
    end
  end

  def create_navigation
    create_file "app/views/godmin/shared/_navigation.html.erb"
  end

  def modify_application_controller
    return if namespaced?

    gsub_file "app/controllers/application_controller.rb",
      /class ApplicationController < ActionController::Base/,
      "class ApplicationController < Godmin::ApplicationController"
  end

  def require_library_if_namespaced
    return unless namespaced?

    inject_into_file File.join("lib", namespaced_path) + ".rb", before: "require" do
      <<-END.strip_heredoc
        require "godmin"
      END
    end
  end
end
