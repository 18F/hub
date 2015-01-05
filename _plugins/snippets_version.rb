module Snippets
  # Encapsulates the mapping from actual snippet data fields to a standardized
  # set of data fields for each version of snippets.
  #
  # Since 18F experimented with a handful of different snippet formats, with
  # slightly different field names and semantics, we needed a way to transform
  # each batch into a common format before generating Hub pages, to streamline
  # the logic and possibly allow for even more formats in the future without
  # requiring version-specific hacks.
  #
  # The common format fields are:
  # - username: identifies the snippet author
  # - last-week: summary of last week's activity
  # - this-week: summary of this week's anticipated activity
  # - timestamp: identifies when the snippet was reported; might not
  #   necessarily match the timestamp of the batch in which it appears
  # - public: true if the snippet may be published publicly
  # - markdown: true if the snippet version supports Markdown syntax
  #
  # When using Jekyll, snippet data should be stored in the _data directory
  # with versioned subdirectories containing timestamped Comma Separated Value
  # (CSV) files, e.g.:
  # - _data/snippets/v1/20141110.csv
  # - _data/snippets/v2/20141201.csv
  # - _data/snippets/v3/20141208.csv
  #
  # Jekyll imports this data into a Hash structure (site.data['snippets'])
  # resembling:
  # - version => { timestamp => [ snippets ] }
  #
  # Version.standardize_versions will convert this structure into a Hash
  # resembling:
  # - timestamp => [ snippets ]
  class Version
    # Set of field name values that the +field_map+ argument of +initialize+
    # must map to.
    FIELD_NAMES = ['username', 'last-week', 'this-week', 'timestamp']

    # Raised by +initialize+ when the initialization parameters are flawed.
    class InitError < ::Exception
    end

    attr_reader(:version_name, :field_map, :public_field, :public_value,
      :markdown_supported)

    # @param version_name [String] identifies the version, e.g. "v3"
    # @param field_map [Hash<String, String>] contains the mapping from the
    #   field name in the original data file to the standardized internal
    #   field name
    # @param public_field [String] if present, the field that indicates whether
    #   or not a snippet can be published in public mode; if not present, no
    #   snippets matching this version should be published publicly
    # @param public_value [String] if present, the value for +public_field+
    #   that indicates whether or not a snippet should be published in public
    #   mode
    # @param markdown_supported [true,false] indicates whether or not the
    #   snippet version supports Markdown syntax
    # @raise [InitError] if +field_map+ does not contain mappings for every
    #   element of FIELD_NAMES
    # @raise [InitError] if one of +public_field+ or +public_value+ is set, but
    #   not the other
    def initialize(version_name:, field_map:, public_field:nil,
      public_value:nil, markdown_supported: false)

      expected = FIELD_NAMES.sort
      actual = field_map.values.sort
      intersection = expected & actual

      unless intersection == expected
        raise InitError.new("Snippet version \"#{version_name}\" " +
          "missing mappings for fields: #{expected - intersection}")
      end

      unless (public_field == nil and public_value == nil) or (
        public_field != nil and public_value != nil)
        raise InitError.new("Snippet version \"#{version_name}\" has " +
          "public_field and public_value mismatched: " +
          "public_field == #{public_field ? "\"#{public_field}\"" : 'nil'}; " +
          "public_value == #{public_value ? "\"#{public_value}\"" : 'nil'}")
      end

      @version_name = version_name
      @field_map = field_map
      @public_field = public_field
      @public_value = public_value
      @markdown_supported = markdown_supported
    end

    # Raised by +standardize+ when a snippet contains fields not contained in
    # +field_map+.
    class UnknownFieldError < ::Exception
    end

    # Converts the field names within +snippet+ to standardized names using
    # +field_map+, and sets snippet[public] and snippet[markdown].
    #
    # @param snippet [Hash<String, String>] snippet data to evaluate
    # @return [Hash<String,String>] +snippet+
    # @raise [UnknownFieldError] if +snippet+ contains fields not contained in
    #   +field_map+
    def standardize(snippet)
      snippet.keys.each do |k|
        unless @field_map.member? k
          raise UnknownFieldError.new("Snippet field not recognized by " +
            "version \"#{@version_name}\": #{k}")
        end
        snippet[@field_map[k]] = snippet.delete k
      end
      snippet['public'] = (@public_field and
        snippet[@public_field] == @public_value) ? true : false
      snippet['markdown'] = @markdown_supported
      snippet
    end

    # Raised by +standardize_versions+ if a snippet version is unknown.
    class UnknownVersionError < ::Exception
    end

    # Transforms snippets of different versions into a standard format.
    #
    # The keys of +snippets_by_version+ should indicate the version of the
    # corresponding batch of snippets, and also match the keys of
    # +snippet_versions+. Each batch of snippets for each version should be a
    # Hash from a timestamp string (typically YYYYMMDD) to an Array of Hashes
    # representing individual snippet entries.
    #
    # The resulting Hash will map from timestamp string to an Array of
    # standardized snippet Hashes, eliminating the now unnecessary version
    # information.
    #
    # @param snippets_by_version [Hash<String, Hash<String, Array<Hash>>>]
    #   contains: version => { timestamp => [ snippets ] }
    # @param snippet_versions [Hash<String,Snippets::Version>] mapping from
    #   snippet version name to the corresponding Snippets::Version object
    # @return [Hash<String, Array<Hash>>] a mapping from a (weekly) timestamp
    #   to a corresponding set of standardized snippets
    #
    # @raise [UnknownVersionError] if any snippets correspond to versions not
    #   in +snippet_versions+
    def self.standardize_versions(snippets_by_version, snippet_versions)
      result = {}
      snippets_by_version.each do |version, batch|
        v = snippet_versions[version]
        unless v
          raise UnknownVersionError.new("Unknown snippet version: #{version}")
        end
        batch.each do |timestamp, snippets|
          result[timestamp] = snippets.each {|s| v.standardize s}
        end
      end
      result
    end
  end
end
