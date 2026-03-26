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

    # This function is for Rails 6 and up since the `find_templates` function
    # is deprecated. It does the same thing, just a little differently. It's
    # not being run by versions previous to Rails 6.
    def _find_all(name, prefix, partial, details, key, locals)
      templates = []

      template_paths(prefix).each do |template_path|
        break if templates.present?

        templates = super(name, template_path, partial, details, key, locals)
      end

      templates
    end

    # This is how we find templates in Rails 5 and below.
    def find_templates(name, prefix, *args)
      templates = []

      template_paths(prefix).each do |path|
        break if templates.present?

        templates = super(name, path, *args)
      end

      templates
    end
  end

  class EngineResolver < Resolver
    def initialize(controller_path)
      super(File.join(Rails.root, "app/views"), controller_path)
    end

    def template_paths(prefix)
      [
        resource_path_for_engine(prefix)
      ]
    end

    def resource_path_for_engine(prefix)
      sub_path = prefix.delete_prefix(@controller_path).delete_prefix("/")
      parts = @controller_path.split("/")
      resource_base = parts.length > 1 ? "#{parts.first(parts.length - 1).join("/")}/resource" : "resource"
      sub_path.present? ? "#{resource_base}/#{sub_path}" : resource_base
    end
  end

  class GodminResolver < Resolver
    def initialize(controller_path)
      super(File.join(Godmin::Engine.root, "app/views/godmin"), controller_path)
    end

    def template_paths(prefix)
      [
        default_path_for_godmin(prefix),
        resource_path_for_godmin(prefix)
      ]
    end

    def default_path_for_godmin(prefix)
      sub_path = prefix.delete_prefix(@controller_path).delete_prefix("/")
      base = File.basename(@controller_path)
      sub_path.present? ? "#{base}/#{sub_path}" : base
    end

    def resource_path_for_godmin(prefix)
      sub_path = prefix.delete_prefix(@controller_path).delete_prefix("/")
      sub_path.present? ? "resource/#{sub_path}" : "resource"
    end
  end
end
