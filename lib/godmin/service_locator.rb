module Godmin
  module ServiceLocator
    # Find the resource class for a given model class. Uses only the simple class
    # name (the last segment after "::") to build the resource class name, then
    # checks the namespace of +context_service_class+ first (e.g.
    # Godmin::Resources::MuseumResource when context is
    # Godmin::Resources::UserResource), then falls back to Godmin::Resources.
    def self.find_service_class_for(klass, context_service_class:)
      return nil unless klass

      klass_name = klass.is_a?(String) ? klass : klass.name
      return nil unless klass_name

      simple_name = klass_name.split("::").last
      resource_name = "#{simple_name}Resource"
      namespace = context_service_class&.name&.deconstantize

      if namespace.present?
        "#{namespace}::#{resource_name}".safe_constantize || "Godmin::Resources::#{resource_name}".safe_constantize
      else
        "Godmin::Resources::#{resource_name}".safe_constantize
      end
    end
  end
end
