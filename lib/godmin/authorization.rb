require "pundit"
require "godmin/authorization/policy"

module Godmin
  module Authorization
    extend ActiveSupport::Concern

    include Pundit::Authorization

    included do
      rescue_from Pundit::NotAuthorizedError do
        render plain: "You are not authorized to do this", status: 403, layout: "godmin/login"
      end
    end

    def policy(record)
      policies[record] ||= Pundit.policy!(pundit_user, namespaced_record(record))
    end

    def pundit_user
      admin_user
    end

    def namespaced_record(record)
      return record if controller_namespace_path.empty?

      class_name = find_class_name(record)
      if already_namespaced?(class_name)
        record
      else
        controller_namespace_path.map(&:to_sym) << record
      end
    end

    private

    # Borrowed from Pundit::PolicyFinder
    def find_class_name(subject)
      if subject.respond_to?(:model_name)
        subject.model_name
      elsif subject.class.respond_to?(:model_name)
        subject.class.model_name
      elsif subject.is_a?(Class)
        subject
      elsif subject.is_a?(Symbol)
        subject.to_s.camelize
      else
        subject.class
      end
    end

    def already_namespaced?(subject)
      return false if controller_namespace_name.blank?

      subject.to_s.start_with?("#{controller_namespace_name}::")
    end

    def controller_namespace_path
      @_controller_namespace_path ||= begin
        parts = controller_path.split("/")
        parts.length > 1 ? parts.first(parts.length - 1) : []
      end
    end

    def controller_namespace_name
      @_controller_namespace_name ||= controller_namespace_path.map(&:camelize).join("::")
    end
  end
end
