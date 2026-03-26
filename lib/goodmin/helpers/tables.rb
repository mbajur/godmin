module Goodmin
  module Helpers
    module Tables
      def column_header(attribute)
        if @resource_service.orderable_column?(attribute.name.to_s)
          direction =
            if params[:order].present?
              if params[:order].match(/\A#{attribute.name.to_s}_(asc|desc)\z/)
                $1 == "desc" ? "asc" : "desc"
              elsif params[:order].match(/\A\w+_(asc|desc)\z/)
                $1
              else
                "desc"
              end
            else
              "desc"
            end
          link_to @resource_class.human_attribute_name(attribute.name.to_s), url_for(params.to_unsafe_h.merge(order: "#{attribute.name}_#{direction}"))
        else
          @resource_class.human_attribute_name(attribute.name.to_s)
        end
      end
    end
  end
end
