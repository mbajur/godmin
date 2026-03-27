module Goodmin
  module Resources
    class ArticleResource
      include Goodmin::Resources::Resource

      def display_name(record)
        "Article: #{record.title}"
      end

      index do
        attribute :id
        attribute :title
        attribute :non_orderable_column
        attribute :admin_user
        attribute :published
        attribute :created_at
      end

      show do
        attribute :id
        attribute :title
        attribute :body
        attribute :admin_user
        attribute :published
      end

      form do
        attribute :title
        attribute :body
        attribute :admin_user
        attribute :published
        attribute :magazines
        attribute :comments
        attribute :profile
      end
      association_option_text :magazines, :name

      has_many :comments
      has_many :magazines

      def order_by_admin_user(resources, direction)
        resources.joins(:admin_users).order("admin_users.email #{direction}")
      end

      scope :all
      scope :unpublished
      scope :published
      scope :no_batch_actions

      def scope_all(articles)
        articles
      end

      def scope_unpublished(articles)
        articles.where(published: false)
      end

      def scope_published(articles)
        articles.where(published: true)
      end

      def scope_no_batch_actions(articles)
        articles
      end

      filter :title
      filter :status, as: :select, collection: -> { [["Published", :published], ["Unpublished", :unpublished]] }

      def filter_title(articles, value)
        articles.where(title: value)
      end

      def filter_status(articles, value)
        articles.where(published: value == "published")
      end

      batch_action :publish, except: [:published, :no_batch_actions]
      batch_action :unpublish, except: [:unpublished, :no_batch_actions]
      batch_action :destroy, except: [:no_batch_actions]

      def batch_action_destroy(articles)
        articles.destroy_all
      end

      def batch_action_publish(articles)
        articles.update_all(published: true)
      end

      def batch_action_unpublish(articles)
        articles.update_all(published: false)
      end
    end
  end
end
