module Tonal
  module IO
    class Scalarchive
      URL = "https://www.huygens-fokker.org/docs/scales.zip"
      ARCHIVE_PATH = Tonal::IO.mtonal_directory.join(".scalarchive")
      ZIP_PATH = ARCHIVE_PATH.join("archive.zip")
      TOC_PATH = ARCHIVE_PATH.join("toc").sub_ext(".yml")

      class << self
        private
        def cache_path
          ARCHIVE_PATH
        end

        def _toc
          @_toc ||= YAML.load(File.read(TOC_PATH))
        end

        def toc_keys
          @toc_keys ||= _toc.keys
        end

        def max_toc_key_length
          toc_keys.max_by(&:size).size
        end

        def generate_toc
          get
          toc_file = File.open(TOC_PATH, 'wb')
          toc_hash = {}

          Zip::File.open(ZIP_PATH) do |zip_file|
            zip_file.each do |entry|
              key = entry.name.scan(/^scl\/(.*)\.scl$/).flatten.first
              scale = Tonal::IO::Scl.read(entry.get_input_stream.read)
              # TODO Introduce additional scale stats
              toc_hash[key] = {
                file: entry.name,
                desc: scale.description,
                count: scale.count,
              }
            end
          end
          toc_file.write(toc_hash.to_yaml)
        end

        def get
          return if File.exist?(ZIP_PATH)

          FileUtils.mkdir_p(cache_path)

          downloaded_file = File.open(ZIP_PATH, 'wb')
          request = Typhoeus::Request.new(URL)

          request.on_headers do |response|
            if response.code != 200
              raise "Request failed"
            end
          end

          request.on_body do |chunk|
            downloaded_file.write(chunk)
          end

          request.on_complete do |response|
            downloaded_file.close
          end

          request.run
        end

        def normalize_scl_key(key)
          # Complete the name according to the archive's naming conventions
          key = "scl/#{key}" if key[/\Ascl\//].nil?
          key = "#{key}.scl" if key[/\.scl\Z/].nil?
        end
      end

      def self.scale(scale_name)
        # Cache the archive
        get

        unless File.exist?(TOC_PATH)
          generate_toc
        end

        key = toc_keys.grep(/\A#{scale_name}\z/).first
        return "Key not in archive" if key.nil?

        Zip::File.open(ZIP_PATH) do |zip_file|
          entry = zip_file.glob("scl/#{key}.scl").first
          content = entry.get_input_stream.read
          Tonal::IO::Scl.read(StringIO.new(content), name: scale_name)
        end
      end

      def self.search(*scl_search)
        unless File.exist?(TOC_PATH)
          generate_toc
        end

        search_keys = toc_keys.grep(Regexp.union(*scl_search)).sort
        (keys, max_key_length) = search_keys.empty? ? [[], 0] : [search_keys, search_keys.max_by(&:size).size] #[ toc_keys, max_toc_key_length ] : [ search_keys, search_keys.max_by(&:size).size ]

        keys.each do |key|
          PP.pp("#{key.ljust(max_key_length)} #{_toc[key][:desc]}", out=$>, width=200);nil
        end
        nil
      end

      def self.toc
        search("")
      end
    end
  end
end
