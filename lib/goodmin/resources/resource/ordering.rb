module Goodmin
  module Resources
    module Resource
      module Ordering
        extend ActiveSupport::Concern

        def apply_order(order_param, resources)
          effective_order = order_param.presence || self.class.default_ordering
          if effective_order.present? && order_column_method?(order_column(effective_order))
            send("order_by_#{order_column(effective_order)}", resources, order_direction(effective_order))
          elsif effective_order.present? && order_column_column?(order_column(effective_order))
            resources.order("#{resource_class.table_name}.#{order_column(effective_order)} #{order_direction(effective_order)}")
          else
            resources
          end
        end

        def orderable_column?(column)
          order_column_method?(column) || order_column_column?(column)
        end

        module ClassMethods
          def default_order(column = nil, direction = :desc)
            @default_ordering = "#{column}_#{direction}" if column
          end

          def default_ordering
            @default_ordering
          end
        end

        protected

        def order_column_method?(column)
          respond_to?("order_by_#{column}")
        end

        def order_column_column?(column)
          resource_class.column_names.include?(column)
        end

        def order_column(order_param)
          order_param.rpartition("_").first
        end

        def order_direction(order_param)
          order_param.rpartition("_").last == "asc" ? "asc" : "desc"
        end
      end
    end
  end
end
