module Goodmin
  module Fields
    # Shared permit-list logic included by NestedHasOne and NestedHasMany.
    #
    # Both nested-association field types expose an identical public API for
    # strong parameters:
    #
    # * +permitted_attributes+ — returns the outer permit entry (a single-item
    #   array containing the <tt>{ *_attributes: [...] }</tt> hash).
    # * +nested_permitted_attributes+ — returns the flat list of attribute
    #   names that go *inside* that hash.  Override this in a subclass and
    #   call +super+ to extend the default list.
    module NestedAssociation
      # Returns the strong-parameters permit entry for this nested field, e.g.:
      #   [{ profile_attributes: [:id, :_destroy, :bio, :website] }]
      #
      # Override +nested_permitted_attributes+ (calling +super+) to append
      # extra attributes without having to reconstruct the outer structure.
      def permitted_attributes
        [{ :"#{attribute}_attributes" => nested_permitted_attributes }]
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
