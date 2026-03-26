module Goodmin
  module Resources
    class AdminUserResource
      include Goodmin::Resources::Resource

      def display_name(record)
        record.email
      end
    end
  end
end
