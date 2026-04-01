module Goodmin
  module Helpers
    module BatchActions
      def batch_action_button(name, options)
        return unless @resource_service.include_batch_action?(name)

        data = {}
        data[:confirm] = translate_scoped("batch_actions.confirm_message") if options[:confirm]

        content_tag(
          :button,
          translate_scoped("batch_actions.labels.#{name}", default: name.to_s.titleize),
          type: :submit,
          name: :batch_action,
          value: name,
          class: "btn btn-default",
          data: data
        )
      end
    end
  end
end
