module Goodmin
  module Fields
    # Abstract base class for nested-association field types.
    #
    # Subclasses (NestedHasOne, NestedHasMany) inherit the shared
    # strong-parameters logic defined here.  This class must not be
    # instantiated directly.
    class Nested < Base
      def initialize(...)
        raise NotImplementedError, "#{self.class} is abstract and cannot be instantiated directly" if instance_of?(Nested)

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
      # Subclasses override this and call +super+ to decorate the list:
      #
      #   class MyProfileField < Goodmin::Fields::NestedHasOne
      #     def nested_permitted_attributes
      #       super + [:avatar_cache, :remove_avatar]
      #     end
      #   end
      def nested_permitted_attributes
        attrs = associated_service&.attrs_for_form || []
        [:id, :_destroy] + attrs.map(&:name) + Array(options[:permitted_attributes])
      end
    end
  end
end
