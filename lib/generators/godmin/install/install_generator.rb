require "godmin/generators/base"

class Godmin::InstallGenerator < Godmin::Generators::Base
  def create_routes
    inject_into_file "config/routes.rb", before: /^end/ do
      <<-END.strip_heredoc.indent(2)
        root to: "application#welcome"
      END
    end
  end

  def create_navigation
    create_file File.join("app/views", namespaced_path, "shared/_navigation.html.erb")
  end

  def modify_application_controller
    inject_into_file File.join("app/controllers", namespaced_path, "application_controller.rb"), after: "ActionController::Base\n" do
      <<-END.strip_heredoc.indent(namespace ? 4 : 2)
        include Godmin::ApplicationController
      END
    end
  end

  def modify_application_js
    application_js = File.join("app/assets/javascripts", namespaced_path, "application.js")
    application_js_full = File.join(destination_root, application_js)

    # Rails 8 with Propshaft does not create app/assets/javascripts/application.js;
    # skip this step when the file doesn't exist.
    return unless File.exist?(application_js_full)

    inject_into_file application_js, before: "//= require_tree ." do
      <<-END.strip_heredoc
        //= require moment
        //= require moment/en-gb
        //= require godmin
      END
    end

    gsub_file application_js, /\/\/= require turbolinks\n/, ""
  end

  def modify_application_css
    application_css = File.join("app/assets/stylesheets", namespaced_path, "application.css")
    application_css_full = File.join(destination_root, application_css)

    # Rails 8 with Propshaft uses plain CSS without Sprockets directives;
    # skip this step when the file doesn't exist.
    return unless File.exist?(application_css_full)

    inject_into_file application_css, before: " *= require_tree ." do
      " *= require godmin\n"
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
