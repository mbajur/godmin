require "goodmin/generators/base"

class Goodmin::InstallGenerator < Goodmin::Generators::Base
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
          mount Goodmin::Engine, at: "/admin"
        END
      end
    end
  end

  def create_navigation
    create_file "app/views/goodmin/shared/_navigation.html.erb"
  end

  def create_base_controller
    template "base_controller.rb", "app/controllers/goodmin/base_controller.rb"
  end

  def require_library_if_namespaced
    return unless namespaced?

    inject_into_file File.join("lib", namespaced_path) + ".rb", before: "require" do
      <<-END.strip_heredoc
        require "goodmin"
      END
    end
  end
end
