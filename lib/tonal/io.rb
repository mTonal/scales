class Tonal::Scale
  module IO
    # @return [Integer] byte count of data written to SCL file
    # @example
    #   Tonal::Scale.edo(12).to_scl("12-edo") => 448
    #
    # @example
    #   Tonal::Scale.edo(12).to_scl("12-edo", fave: true) => 448
    #
    # @param file_name [String] SCL file name
    # @param location [String] to write file
    # @param fave [Boolean] whether to place in the "faves" sub-folder
    #
    def to_scl(file_name=nil, fave: false, location: nil)
      fave_location = fave ? Tonal::IO::Scl.faves_directory : ""
      location = location.nil? ? Tonal::IO::Scl.root_directory.join(fave_location, count.to_s) : Pathname.new("").join(location, fave_location, count.to_s)
      Tonal::IO::Scl.new(file_name || self.name,
        name: self.name,
        description: self.description,
        pitches: self.to_r.map(&:to_s),
        location: location
      ).write
    end
    alias :write :to_scl

    # @return [Integer] byte count of data written to YAML file
    # @example
    #   Tonal::Scale.edo(12).to_yaml("12-edo") => 511
    # @param [String] name and location of YAML file
    #
    def to_yaml(file_name)
      Tonal::IO::Yaml.new(file_name,
        name: self.name,
        description: self.description,
        pitches: self.to_r.map(&:to_s)
      ).write
    end
    alias :to_yml :to_yaml

    # @return [Integer] byte count of data written to JSON file
    # @example
    #  Tonal::Scale.edo(12).to_json("12-edo") => 608
    # @param [String] name and location of JSON file
    #
    def to_json(file_name)
      Tonal::IO::Json.new(file_name,
        name: self.name,
        description: self.description,
        pitches: self.to_r.map(&:to_s)
      ).write
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # @return [Tonal::Scale] scale parsed from SCL file
      # @example
      #   Tonal::Scale.from_scl("<path to file>/12-edo.scl")
      #   => [(1/1), (4771397596969315/4503599627370496), (78986244726619/70368744177664), (5355712719992597/4503599627370496), (5674179970822795/4503599627370496), (3005792134919727/2251799813685248), (6369051672525773/4503599627370496), (421735949569275/281474976710656), (1787254696532879/1125899906842624), (7574121564787629/4503599627370496), (8024502270083369/4503599627370496), (8501664005755715/4503599627370496)]
      # @param [String] the location and name of SCL file
      #
      def from_scl(file_location=nil)
        Tonal::IO::Scl.read_from_file(file_location)
      end

      # @return [Tonal::Scale] from Scala archive
      # @example
      #   Tonal::Scale.from_scalarchive("wilson7")
      #   => [[1, 1], [28, 27], [16, 15], [10, 9], [9, 8], [7, 6], [6, 5], [5, 4], [35, 27], [4, 3], [27, 20], [45, 32], [35, 24], [3, 2], [14, 9], [8, 5], [5, 3], [27, 16], [7, 4], [9, 5], [15, 8], [35, 18]]
      # @param [String] a scale name from the Scala archive.  See ScalaArchive.toc, ScalaArchive.search
      #
      def from_scalarchive(scale_name)
        Tonal::IO::Scalarchive.scale(scale_name)
      end

      # @return [Tonal::Scale] scale parsed from YAML file
      # @example
      #   Tonal::Scale.from_yaml("12-edo.yml") => [[1, 1], [4771397596969315, 4503599627370496], [78986244726619, 70368744177664], [5355712719992597, 4503599627370496], [5674179970822795, 4503599627370496], [3005792134919727, 2251799813685248], [6369051672525773, 4503599627370496], [421735949569275, 281474976710656], [1787254696532879, 1125899906842624], [7574121564787629, 4503599627370496], [8024502270083369, 4503599627370496], [8501664005755715, 4503599627370496]]
      # @param [String] file name
      #
      def from_yaml(file_location)
        Tonal::IO::Yaml.read(file_location)
      end

      # @return [Tonal::Scale] parsed from JSON file
      # @example
      #
      # @param [String] name and location of JSON file
      #
      def from_json(file_location)
        Tonal::IO::Json.read(file_location)
      end
    end
  end
end
