require "action_view"
require "action_view/template/resolver"

module Godmin
  class Resolver < ::ActionView::FileSystemResolver
    def self.resolvers(controller_path)
      [
        EngineResolver.new(controller_path),
        GodminResolver.new(controller_path)
      ]
    end

    def initialize(path, controller_path)
      super(path)
      @controller_path = controller_path
    end

    def _find_all(name, prefix, partial, details, key, locals)
      templates = []

      template_paths(prefix).each do |template_path|
        break if templates.present?

        templates = super(name, template_path, partial, details, key, locals)
      end

      templates
    end
  end

  # Looks in the host application's app/views for user-defined resource-level
  # template overrides. Controllers are always under the "godmin/" prefix so:
  #
  # { name: index, prefix: godmin/articles } => app/views/godmin/resource/index
  # { name: form,  prefix: godmin/articles } => app/views/godmin/resource/_form
  # { name: title, prefix: godmin/articles/columns } => app/views/godmin/resource/columns/_title
  class EngineResolver < Resolver
    NAMESPACE = "godmin"

    def initialize(controller_path)
      super(Rails.application.root.join("app/views").to_s, controller_path)
    end

    def template_paths(prefix)
      # Replace the controller path prefix with "godmin/resource" to enable
      # resource-level fallback templates in the host app.
      # e.g. "godmin/articles" => "godmin/resource", "godmin/articles/columns" => "godmin/resource/columns"
      [prefix.sub(/\A#{Regexp.escape(@controller_path)}/, "#{NAMESPACE}/resource").sub(/\A\//, "")]
    end
  end

  # Looks in the Godmin gem's app/views/godmin/ for built-in templates:
  #
  # { name: index, prefix: godmin/articles }      => godmin/app/views/godmin/resource/index
  # { name: form,  prefix: godmin/articles }       => godmin/app/views/godmin/resource/_form
  # { name: welcome, prefix: godmin/application } => godmin/app/views/godmin/application/welcome
  # { name: navigation, prefix: godmin/shared }   => godmin/app/views/godmin/shared/navigation
  class GodminResolver < Resolver
    NAMESPACE = "godmin"

    def initialize(controller_path)
      super(Godmin::Engine.root.join("app/views/godmin").to_s, controller_path)
    end

    def template_paths(prefix)
      [
        # Strip the "godmin/" namespace prefix so the resolver looks directly
        # at the path inside the gem's app/views/godmin/ root.
        # e.g. "godmin/articles" => "articles", "godmin/shared" => "shared"
        prefix.sub(/\A#{Regexp.escape(NAMESPACE)}\//, "").sub(/\A\//, ""),
        # Also look in "resource/" as a generic fallback.
        # e.g. "godmin/articles" => "resource", "godmin/articles/columns" => "resource/columns"
        prefix.sub(/\A#{Regexp.escape(@controller_path)}/, "resource").sub(/\A\//, "")
      ]
    end
  end
end
