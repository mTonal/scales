module Tonal
  module IO
    class Scale
      class << self
        def cent_regex
          #/\d+\.\d*/
          /[-]*(\d+\.\d*)/
        end

        def ratio_regex
          /\d+\/\d+/
        end

        protected
        def parse(input)
          Tonal::Scale.new.tap do |scale|
            scale.description = input.fetch("description")
            scale.name = input.fetch("name")
            input.fetch("pitches").each do |pitch|
              scale << Tonal::ReducedRatio.new(pitch.to_r)
            end
          end
        end
      end

      def initialize(file_name, name:, description:, pitches:, location: Tonal::IO.home_directory.join(self.class.root_directory))
        @file_name = Pathname.new(sanitized(file_name)).sub_ext(self.class.file_extension)
        @name = name
        @description = description
        @pitches = pitches
        @origination =  "#{Tonal::SCALES_PRODUCER} #{Tonal::SCALES_VERSION}"
        @location = Pathname.new(location)
      end

      protected
      def hashed_output
        {}.tap do |output|
          output["file"] = @file_name.to_s
          output["name"] = @name
          output["description"] = @description
          output["origination"] = "#{@origination}, #{Date.today.strftime('%b %d, %Y')}"
          output["pitches"] = @pitches
        end
      end

      # Taken from ActiveStorage::Filename#sanitized
      #
      def sanitized(filename)
        filename.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "�").strip.tr("\u{202E}%$|:;/\t\r\n\\", "-")
      end

      def write(output)
        FileUtils.mkdir_p(@location)
        File.write(@location.join(@file_name), output)
      end

      def identity_ratio
        @identity_ratio ||= Tonal::ReducedRatio::IDENTITY_RATIO.to_r.to_s
      end

      def has_identity_ratio?
        @has_identity_ratio ||= @pitches.any?{|p| p == identity_ratio}
      end
    end
  end
end

class Tonal::IO::Yaml < Tonal::IO::Scale
  def self.file_extension
    ".yml"
  end

  # @return [Tonal::Scale] scale parsed from YAML file
  # @param file_location file and location of YAML file
  #
  def self.read(file_location)
    parse(YAML.load(File.read(file_location)))
  end

  # @return [Integer] count of bytes written to YAML file
  #
  def write
    super(hashed_output.to_yaml(line_width: 200))
  end
end

class Tonal::IO::Json < Tonal::IO::Scale
  def self.file_extension
    ".json"
  end

  # @return [Tonal::Scale] scale parsed from JSON file
  # @param file_location file and location of JSON file
  #
  def self.read(file_location)
    parse(JSON.parse(File.read(file_location)))
  end

  # @return [Integer] count of bytes written to JSON file
  #
  def write
    super(JSON.pretty_generate(hashed_output))
  end
end

class Tonal::IO::Scl < Tonal::IO::Scale
  class << self
    private
    def parse_file(io, name: "")
      first_non_comment_found = false
      pitch_count_found = false
      pitch_count = 0

      Tonal::Scale.new(name: name).tap do |scale|
        io.each_line do |line|
          case line
          when /\A\s*!/                            # A comment
            next
          when /\A(?~\s*!)/                        # A non-comment
            if first_non_comment_found == false    # A description
              scale.description = line.chomp.strip.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') # Replace any unconvertable binary characters with '?'
              first_non_comment_found = true
            else                                   # A non-description
              unless pitch_count_found             # A pitch count
                pitch_count = line.chomp
                pitch_count_found = true
              else
                case line
                when cent_regex
                  scale << Tonal::Cents.new(cents: line[cent_regex].to_f % Tonal::Cents::CENT_SCALE).ratio
                when ratio_regex
                  scale << Tonal::ReducedRatio.new(line[ratio_regex].to_r)
                end
              end
            end
            next
          end
        end
      end
    end
  end

  def self.file_extension
    ".scl"
  end

  def self.root_directory
    Tonal::IO.scl_directory
  end

  def self.faves_directory
    Pathname.new("faves")
  end

  # @return [Tonal::Scale] scale parsed from IO input
  # @param [data] IO input
  #
  def self.read(data, name: "")
    parse_file(data, name: name)
  end

  # @return [Tonal::Scale] scale parsed from SCL file
  # @param [file_location] file and location of SCL file
  #
  def self.read_from_file(file_location, name: "")
    file_path = Pathname.new(file_location)
    #read(File.open(file_path), name: file_path.basename('.scl').to_s)

    # TODO Introduce seaching "My SCLs" with autocompletion of path to the file. Example from https://stackoverflow.com/questions/23888755/user-entry-path-autocompletion
    #
    # require 'readline'
    # 
    # Readline.completion_append_character = ""
    # Readline.completion_proc = Proc.new do |str|
    #   Dir[str + '*'].grep( /^#{Regexp.escape(str)}/ )
    # end
    # 
    # file = File.open(Readline.readline('File Name> ').strip!)

    unless file_location
      Readline.completion_append_character = nil  # Improves feedback output
      Readline.completion_case_fold = true        # Confirm if needed
      Readline.completer_quote_characters = "\"'" # Not helpful
      Readline.completion_proc = Proc.new do |str|
        Dir[Tonal::IO.scl_directory.join(str).join("*")].grep( /^#{Regexp.escape(str)}/ )
      end
      file = Readline.readline("> ", true) #.strip!
      if file
        file_path = Pathname.new(file)
      else
        return
      end
    else
      file_path = Pathname.new(file_location)
    end

    read(File.open(file_path), name: file_path.basename(".scl").to_s)
  end

  # @return [Integer] count of bytes written to SCL file
  #
  def write
    output = hashed_output

    # The .scl documentation says 1/1 is implicit and must not be included in
    # the file. However, some parsers, e.g. Pianoteq, expect 1/1 to be mapped
    # to 2/1. Hence, we use identity_ratio and has_identity_ratio? to appease
    # parsers that require 2/1 in the file.
    #
    pitches = output['pitches'].reject{|p| p == identity_ratio}

    template = <<~EOT
    ! <%= output["name"] %>
    !
    <%= output["description"] %>; Generated by <%= output['origination'] %>
    <%= output["pitches"].count %>
    !
    <% pitches.each do |pitch| -%>
    <%= pitch %>
    <% end -%>
    <%= "2/1" if has_identity_ratio? -%>
    
    EOT

    body = ERB.new(template, trim_mode: "-")
    super(body.result(binding))
  end
end
