module Godmin
  module ServiceLocator
    # Find the resource class for a given model class. Checks the namespace of
    # +context_resource_class+ first (supporting namespaced admin setups such as
    # Admin::MuseumResource), then falls back to a top-level constant.
    #
    # For example, if context_resource_class is Admin::UserResource and
    # klass is Museum, this tries Admin::MuseumResource before MuseumResource.
    def self.find_service_class_for(klass, context_service_class:)
      return nil unless klass

      klass_name = klass.is_a?(String) ? klass : klass.name
      return nil unless klass_name

      resource_name = "#{klass_name}Resource"
      namespace = context_service_class&.name&.deconstantize

      if namespace.present?
        "#{namespace}::#{resource_name}".safe_constantize || resource_name.safe_constantize
      else
        resource_name.safe_constantize
      end
    end
  end
end
