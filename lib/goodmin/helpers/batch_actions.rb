module Goodmin
  module Helpers
    module BatchActions
      def batch_action_button(name, options)
        return unless @resource_service.include_batch_action?(name)

        data = {
          batch_actions_target: "actionButton",
          confirm: options[:confirm] ? translate_scoped("batch_actions.confirm_message") : nil
        }.compact

        content_tag(
          :button,
          translate_scoped("batch_actions.labels.#{name}", default: name.to_s.titleize),
          type: :submit,
          name: :batch_action,
          value: name,
          class: "btn btn-default hidden",
          data: data
        )
      end
    end
  end
end
