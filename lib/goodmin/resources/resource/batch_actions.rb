module Goodmin
  module Resources
    module Resource
      module BatchActions
        extend ActiveSupport::Concern

        delegate :batch_action_map, to: "self.class"

        def batch_action(action, records)
          if batch_action?(action)
            send("batch_action_#{action}", records)
            true
          else
            false
          end
        end

        def batch_action?(action)
          batch_action_map.key?(action.to_sym)
        end

        def include_batch_action?(action)
          return false unless batch_action_map.key?(action.to_sym)

          options = batch_action_map[action.to_sym]

          if options[:only].present?
            options[:only].include?(@scope.to_sym)
          elsif options[:except].present?
            !options[:except].include?(@scope.to_sym)
          else
            true
          end
        end

        def include_batch_actions?
          batch_action_map.any? { |action, _options| include_batch_action?(action) }
        end

        module ClassMethods
          def batch_action_map
            @batch_action_map ||= {}
          end

          def batch_action(attr, options = {})
            batch_action_map[attr] = {
              confirm: false,
              only: nil,
              except: nil
            }.merge(options)
          end
        end
      end
    end
  end
end
