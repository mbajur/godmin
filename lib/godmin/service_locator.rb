module Godmin
  module ServiceLocator
    # Find the service class for a given model class. Checks the namespace of
    # +context_service_class+ first (supporting namespaced admin setups such as
    # Admin::MuseumService), then falls back to a top-level constant.
    #
    # For example, if context_service_class is Admin::UserService and
    # klass is Museum, this tries Admin::MuseumService before MuseumService.
    def self.find_service_class_for(klass, context_service_class:)
      return nil unless klass

      klass_name = klass.is_a?(String) ? klass : klass.name
      return nil unless klass_name

      service_name = "#{klass_name}Service"
      namespace = context_service_class&.name&.deconstantize

      if namespace.present?
        "#{namespace}::#{service_name}".safe_constantize || service_name.safe_constantize
      else
        service_name.safe_constantize
      end
    end
  end
end
