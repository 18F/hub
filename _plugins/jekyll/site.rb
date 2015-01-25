require 'jekyll/site'

module Jekyll
  class Site
    # monkey-patch to make an after_render hook
    alias_method :orig_render, :render
    def render
      orig_render
      after_render
    end

    def after_render
      PagesApi.new(self).generate
    end
  end
end
