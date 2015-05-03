require 'uglifier'

module Hub
  # Compresses Javascript files.
  class Compressor
    def self.compress(site)
      return if site.config['skip_compression']
      js_files = []
      site.static_files.delete_if do |sf|
        path = sf.path
        if path.end_with? '.js' and not path.end_with? '.min.js'
          js_files << sf
          true
        end
      end

      compressed_dir = File.join(site.source, '_compressed')
      FileUtils.mkdir_p(compressed_dir) unless File.exist? compressed_dir

      js_files.each do |f|
        path = f.path
        source_len = site.source.length + 1
        relative_dir = File.dirname(path)[source_len..-1]
        filename = File.basename(path)

        output_dir = File.join(compressed_dir, relative_dir)
        FileUtils.mkdir_p(output_dir) unless File.exist? output_dir
        output_path = File.join(output_dir, filename)

        unless (File.exist? output_path and
          File.stat(path).mtime <= File.stat(output_path).mtime)
          File.write(output_path, ::Uglifier.compile(File.read path))
        end
        site.static_files << ::Jekyll::StaticFile.new(
          site, compressed_dir, relative_dir, filename)
      end
    end
  end
end
