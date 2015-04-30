require 'jekyll/site'
require 'jekyll_pages_api'

module Jekyll
  class Site
    # This requires deep knowledge of jekyll_pages_api.
    alias_method :pages_api_after_render, :after_render

    def after_render
      pages_api_after_render
      index = Hub::SearchIndexBuilder.build_index(self)
      self.pages << index if index != nil
    end
  end
end
