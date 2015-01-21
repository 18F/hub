module Hub

  # Contains Hub-specific Liquid filters.
  module Filters

    # Breaks a YYYYMMDD timestamp into a hyphenated version: YYYY-MM-DD
    # +timestamp+:: timestamp in the form YYYYMMDD
    def hyphenate_yyyymmdd(timestamp)
      Canonicalizer.hyphenate_yyyymmdd timestamp
    end

    # Returns a canonicalized, URL-friendly substitute for an arbitrary string.
    # +s+:: string to canonicalize
    def canonicalize(s)
      Canonicalizer.canonicalize s
    end

    # Slight tweak of
    # https://github.com/Shopify/liquid/blob/v2.6.1/lib/liquid/standardfilters.rb#L71-L74
    # to replace newlines with spaces.
    def condense(input)
      input.to_s.gsub(/\r?\n/, ' '.freeze).strip
    end
  end
end

Liquid::Template.register_filter(Hub::Filters)
