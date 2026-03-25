module Godmin
  class ArticlesController < ApplicationController
    include Godmin::Resources::ResourceController

    private

    def redirect_after_batch_action_publish
      godmin.articles_path(scope: :published)
    end

    def redirect_after_batch_action_unpublish
      godmin.articles_path(scope: :unpublished)
    end
  end
end
