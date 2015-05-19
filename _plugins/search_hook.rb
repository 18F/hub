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
      search_config = self.config['jekyll_pages_api_search']
      return if search_config == nil || search_config['skip_index']
      self.pages << Hub::SearchIndexBuilder.build_index(self)
    end
  end
end
