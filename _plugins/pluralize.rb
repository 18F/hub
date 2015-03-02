# courtesy of <https://github.com/bdesham/pluralize>
# (Public Domain license)
module Jekyll
  module Pluralize

    def pluralize(number, singular, plural=nil)
      if number == 1
        "#{number} #{singular}"
      elsif plural == nil
        "#{number} #{singular}s"
      else
        "#{number} #{plural}"
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::Pluralize)
