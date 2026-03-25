module Godmin
  module ApplicationHelper
    # Renders the provided partial with locals if it exists, otherwise
    # yields the given block. The lookup context call is cached for
    # each partial.
    # Returns the display name for a resource record by looking up its service
    # class via ServiceLocator and calling display_name on it. Falls back to
    # record.to_s if no service class is found.
    def resource_display_name(record)
      service_class = Godmin::ServiceLocator.find_service_class_for(
        record.class,
        context_service_class: @resource_service&.class
      )
      service = service_class&.new
      service ? service.display_name(record) : record.to_s
    rescue StandardError
      record.to_s
    end

    def partial_override(partial, locals = {}, &block)
      @_partial_override ||= {}

      unless @_partial_override.key?(partial)
        @_partial_override[partial] = lookup_context.exists?(partial, nil, true)
      end

      if @_partial_override[partial]
        render partial: partial, locals: locals
      else
        capture(&block)
      end
    end

    # Wraps the policy helper so that it is always accessible, even when
    # authorization is not enabled. When that is the case, it returns a
    # policy that always returns true.
    def policy(resource)
      if authorization_enabled?
        super(resource)
      else
        Authorization::Policy.new(nil, nil, default: true)
      end
    end
  end
end
