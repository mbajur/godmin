require "action_view"
require "action_view/template/resolver"

module Godmin
  class Resolver < ::ActionView::FileSystemResolver
    def self.resolvers(controller_path)
      engine_root = engine_root_for(controller_path)
      [
        EngineResolver.new(controller_path, engine_root),
        GodminResolver.new(controller_path)
      ]
    end

    def self.engine_root_for(controller_path)
      parts = controller_path.split("/")
      return Rails.application.root if parts.length < 2

      namespace_path = parts.first(parts.length - 1).join("/")

      engine = Rails::Engine.subclasses.find do |e|
        next unless e.railtie_namespace
        e.railtie_namespace.name.underscore.gsub("::", "/") == namespace_path
      rescue NameError, NoMethodError
        nil
      end

      engine&.root || Rails.application.root
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
    def initialize(controller_path, engine_root = Rails.application.root)
      super(File.join(engine_root, "app/views"), controller_path)
    end

    def template_paths(prefix)
      application_path = application_path_for_engine
      resource_path = resource_path_for_engine(prefix)
      shared_path = shared_path_for_engine(prefix)
      # Always include the base resource and shared paths (without any prefix sub-path).
      # This ensures app/views/godmin/resource and app/views/godmin/shared overrides are found
      # even when Rails invokes the resolver with a non-controller prefix (e.g. "layouts/godmin"
      # from the layout file), where the prefix-specific paths won't match. base_resource_path
      # is placed before base_shared_path so that a more specific resource override always wins
      # over a shared override (main_app resource > main_app shared > application).
      base_resource_path = resource_path_for_engine(@controller_path)
      base_shared_path = shared_path_for_engine(@controller_path)

      paths = [resource_path, base_resource_path, shared_path, base_shared_path, application_path].uniq
      return paths if @controller_path.split("/").length > 1

      [
        "godmin/#{resource_path}",
        "godmin/#{base_resource_path}",
        "godmin/#{shared_path}",
        "godmin/#{base_shared_path}",
        "godmin/#{application_path}"
      ].uniq + paths
    end

    def application_path_for_engine
      parts = @controller_path.split("/")
      parts.length > 1 ? "#{parts.first(parts.length - 1).join("/")}/application" : "application"
    end

    def resource_path_for_engine(prefix)
      sub_path = prefix.delete_prefix(@controller_path).delete_prefix("/")
      parts = @controller_path.split("/")
      resource_base = parts.length > 1 ? "#{parts.first(parts.length - 1).join("/")}/resource" : "resource"
      sub_path.present? ? "#{resource_base}/#{sub_path}" : resource_base
    end

    def shared_path_for_engine(prefix)
      sub_path = prefix.delete_prefix(@controller_path).delete_prefix("/")
      parts = @controller_path.split("/")
      shared_base = parts.length > 1 ? "#{parts.first(parts.length - 1).join("/")}/shared" : "shared"
      sub_path.present? ? "#{shared_base}/#{sub_path}" : shared_base
    end
  end

  class GodminResolver < Resolver
    def initialize(controller_path)
      super(File.join(Godmin::Engine.root, "app/views/godmin"), controller_path)
    end

    def template_paths(prefix)
      [
        default_path_for_godmin(prefix),
        resource_path_for_godmin(prefix),
        shared_path_for_godmin(prefix)
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

    def shared_path_for_godmin(prefix)
      sub_path = prefix.delete_prefix(@controller_path).delete_prefix("/")
      sub_path.present? ? "shared/#{sub_path}" : "shared"
    end
  end
end
