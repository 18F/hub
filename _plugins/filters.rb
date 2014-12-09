module Hub

  # Contains Hub-specific Liquid filters.
  module Filter

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
  end
end

Liquid::Template.register_filter(Hub::Filter)
