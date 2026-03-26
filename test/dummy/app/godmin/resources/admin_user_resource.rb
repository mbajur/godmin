module Godmin
  module Resources
    class AdminUserResource
      include Godmin::Resources::Resource

      def display_name(record)
        record.email
      end
    end
  end
end
