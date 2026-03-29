module Goodmin
  module Fields
    # Abstract base class for nested-association field types.
    #
    # Subclasses (NestedHasOne, NestedHasMany) inherit the shared
    # strong-parameters logic defined here.  This class must not be
    # instantiated directly.
    class BaseNested < Base
      def initialize(...)
        raise NotImplementedError, "#{self.class} is abstract and cannot be instantiated directly" if instance_of?(BaseNested)

        super
      end

      # Returns the single strong-parameters permit entry for this nested field, e.g.:
      #   { profile_attributes: [:id, :_destroy, :bio, :website] }
      #
      # Override +nested_permitted_attributes+ (calling +super+) to append
      # extra attributes without having to reconstruct the outer structure.
      def permitted_attribute
        { :"#{attribute}_attributes" => nested_permitted_attributes }
      end

      # The default nested permit list: +:id+, +:_destroy+, every form
      # attribute defined on the associated resource, and any extras declared
      # via the <tt>permitted_attributes:</tt> DSL option.
      #
      # Each attribute's own +permitted_attribute+ is called (not just the
      # bare name), so nested or custom fields can return richer structures
      # such as <tt>{ properties: [:foo] }</tt>.
      #
      # Subclasses override this and call +super+ to decorate the list:
      #
      #   class MyProfileField < Goodmin::Fields::NestedHasOne
      #     def nested_permitted_attributes
      #       super + [:avatar_cache, :remove_avatar]
      #     end
      #   end
      def nested_permitted_attributes
        attrs = associated_service&.attrs_for_form || []
        rec   = nested_record_instance
        permitted = if rec
          attrs.map { |attr| attr.to_field(record: rec, resource_service: associated_service).permitted_attribute }
        else
          attrs.map(&:name)
        end
        [:id, :_destroy] + permitted + Array(options[:permitted_attributes])
      end

      protected

      # Returns an instance of the associated model class used for attribute
      # type resolution inside +nested_permitted_attributes+. Subclasses must
      # implement this.
      def nested_record_instance
        raise NotImplementedError, "#{self.class} must implement #nested_record_instance"
      end
    end
  end
end
