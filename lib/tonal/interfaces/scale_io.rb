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

class Tonal::IO::Kbm < Tonal::IO::Scale
  DEFAULT_MIDI_START = 0
  DEFAULT_MIDI_END = 127
  DEFAULT_MIDI_MIDDLE = 60
  DEFAULT_MIDI_REFERENCE = 69
  DEFAULT_REFERENCE_FREQUENCY = 440.0

  def self.file_extension
    ".kbm"
  end

  def self.root_directory
    Tonal::IO.kbm_directory
  end

  def self.faves_directory
    Pathname.new("faves")
  end

  # @return [Tonal::Scale] scale parsed from KBM file
  # @param [file_location] file and location of KBM file
  #
  def self.read_from_file(file_location, name: "")
    file_path = Pathname.new(file_location)
    read(File.open(file_path), name: file_path.basename(".kbm").to_s)
  end

  def write
    output = hashed_output
    # * Line 1: Size of the map (the number of keys in the repeating pattern, e.g., 12 for standard piano mapping).
    # * Line 2: The first MIDI note number to be retuned (usually (0)).
    # * Line 3: The last MIDI note number to be retuned (usually (127)).
    # * Line 4: Middle note (the MIDI note where the first entry of the mapping is placed, usually (60) for middle C or (69) for A4).
    # * Line 5: Reference note (the MIDI note for which the reference frequency is given, usually (69)).
    # * Line 6: Frequency (Hz) to tune the reference note to (usually (440.0)).
    # * Line 7: Scale degree to consider as the formal octave. This determines the pitch jump between adjacent mapping patterns (e.g., (7) for 7-tone, (12) for 12-tone).
    # * Line 8+: The Mapping Array. Each following line represents one key in the repeating octave pattern.
    # *  If a line is an integer, it maps the MIDI note to that specific degree of the .scl scale (e.g., (1) is the first scale tone, (2) is the second tone, etc.).
    # *  If it is (x) or (-1), the key is unmapped (silent). [1, 2, 3, 4]
    template = <<~EOT
    ! <%= output["name"] %>
    <%= output["pitches"].count %>
    <%= output["midi_start"] || DEFAULT_MIDI_START %>
    <%= output["midi_end"] || DEFAULT_MIDI_END %>
    <%= output["midi_middle"] || DEFAULT_MIDI_MIDDLE %>
    <%= output["midi_reference"] || DEFAULT_MIDI_REFERENCE %>
    <%= output["reference_frequency"] || DEFAULT_REFERENCE_FREQUENCY %>
    <%= output["pitches"].count %>
    <% output["pitches"].each_index do |index| -%>
    <%= index %>
    <% end -%>

    EOT

    body = ERB.new(template, trim_mode: "-")
    super(body.result(binding))
  end
end