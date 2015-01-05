module Snippets
  class Publisher
    # @param headline [String] Markdown string used to markup each section
    #   title within a block of snippet text
    # @param public_mode [true, false, or nil] indicates whether or not the
    #   snippets are to be published publicly; private snippets and redacted
    #   spans of text will not be published when +public_mode+ is true
    # @param markdown_snippet_munger [Proc] the code block that will be called
    #   with a String of snippet text after redaction and before Markdown
    #   preparation, to modify the snippet text String in-place; will not be
    #   called if the snippet's version doesn't support Markdown syntax
    def initialize(headline:, public_mode:, markdown_snippet_munger:nil)
      @headline = headline
      @public_mode = public_mode
      @markdown_snippet_munger = markdown_snippet_munger
    end

    # Processes +snippets+ entries for publication. Any snippets that should
    # not appear when in +public_mode+ are removed from +snippets+
    def publish(snippets)
      result = {}
      snippets.each do |timestamp, snippet_batch|
        published = []
        snippet_batch.each do |snippet|
          unless @public_mode and !snippet['public']
            publish_snippet(snippet, published)
          end
        end
        result[timestamp] = published unless published.empty?
      end
      result
    end

    # Parses and publishes a snippet. Filters out snippets rendered empty
    # after redaction.
    # @param snippet [Hash<String,String>] snippet hash with two fields:
    #   +last-week+ and +this-week+
    # @param published [Array<Hash<String,String>>] array of published snippets
    def publish_snippet(snippet, published)
      ['last-week', 'this-week'].each do |field|
        text = snippet[field] || ''
        redact! text
        if snippet['markdown']
          @markdown_snippet_munger.yield text if @markdown_snippet_munger
          text = prepare_markdown text
        end
        snippet[field] = text.empty? ? nil : text
      end

      is_empty = (snippet['last-week'] || '').empty? && (
        snippet['this-week'] || '').empty?
      published << snippet unless is_empty
    end

    # Parses "{{" and "}}" redaction markers. For public snippets, will redact
    # everything between each set of markers. For internal snippets, will only
    # remove the markers.
    def redact!(text)
      if @public_mode
        text.gsub!(/\n?\{\{.*?\}\}/m,'')
      else
        text.gsub!(/(\{\{|\}\})/,'')
      end
    end

    # Processes snippet text in Markdown format to smooth out any anomalies
    # before rendering. Also translates arbitrary plaintext to Markdown.
    #
    # @param text [String] snippet text
    # @return [String]
    def prepare_markdown(text)
      parsed = []
      uses_item_markers = (text =~ /^[-*]/)

      text.each_line do |line|
        line.rstrip!
        # Convert headline markers.
        line.sub!(/^(#+)/, @headline)

        # Add item markers for those who used plaintext and didn't add them;
        # add headline markers for those who defined different sections and
        # didn't add them.
        if line =~ /^([A-Za-z0-9])/
          line = uses_item_markers ? "#{@headline} #{line}" : "- #{line}"
        end

        # Fixup item markers missing a space.
        line.sub!(/^[-*]([^ ])/, '- \1')
        parsed << line unless line.empty?
      end
      parsed.join("\n")
    end
  end
end
