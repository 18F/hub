require 'jekyll/site'
require 'jekyll_pages_api'

# This Jekyl::Site override creates a hook for generating the search index
# after the jekyll_pages_api plugin has produced the api/v1/pages.json corpus.
# In the very near term, we should probably create a proper hook in the
# jekyll_pages_api plugin itself.
module Jekyll
  class Site
    alias_method :pages_api_after_render, :after_render

    def after_render
      pages_api_after_render
      return if self.config['skip_index']
      index, url_to_doc = Hub::SearchIndexBuilder.build_index(self)
      self.pages << index if index != nil
      self.pages << url_to_doc if url_to_doc != nil
    end
  end
end
