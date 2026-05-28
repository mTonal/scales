class Tonal::Scale
  module IO
    # @return [Integer] byte count of data written to SCL file
    # @example
    #   Tonal::Scale.edo(12).to_scl("12-edo") => 440
    #
    # @example
    #   Tonal::Scale.edo(12).to_scl("12-edo", fave: true) => 440
    #
    # @param file_name [String] SCL file name
    # @param location [String] to write file to.  If nil, will write to root directory of SCL folder.  If fave: true, will write to "faves" sub-folder of SCL folder.
    # @param fave [Boolean] whether to place in the "faves" sub-folder of the SCL folder.  If true, will write to "faves" sub-folder of SCL folder.  If false, will write to root directory of SCL folder.  Ignored if location is not nil.
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
    # TODO: Consider deleting the YAML format, since it's not a standard for musical scales and is easily confused with the SCL format.  If we keep it, consider changing the file extension to something other than .yml or .yaml to avoid confusion.
    # @deprecated
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
    # TODO: Consider deleting the JSON format, since it's not a standard for musical scales and is easily confused with the SCL format.  If we keep it, consider changing the file extension to something other than .json to avoid confusion.
    # @deprecated
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
      # @note The SCL format does not include a description field, so the description of the returned scale will be an empty string.
      # @note The SCL format does not include a name field, so the name of the returned scale will be the file name without the extension.
      # @note The SCL format does not include a count field, so the count of the returned scale will be the number of pitches in the file.
      # @note The SCL format does not include a period field, so the period of the returned scale will be 2.0 by default.
      #
      # @example
      #   Tonal::Scale.from_scl("<path to file>/12-edo.scl")
      #   => [1/1, 1.06, 1.12, 1.19, 1.26, 1.33, 1.41, 1.5, 1.59, 1.68, 1.78, 1.89]
      #
      # @param [String] the location and name of SCL file to read.  If nil, will read from root directory of SCL folder with file name equal to the name of the scale (with spaces replaced by hyphens) and extension .scl.  If fave: true, will read from "faves" sub-folder of SCL folder with file name equal to the name of the scale (with spaces replaced by hyphens) and extension .scl.
      #
      def from_scl(file_location=nil)
        Tonal::IO::Scl.read_from_file(file_location)
      end

      # @return [Tonal::Scale] from Scala archive
      # @note The Scala archive does not include a description field, so the description of the returned scale will be an empty string.
      # @note The Scala archive does not include a name field, so the name of the returned scale will be the name of the scale in the Scala archive.
      # @note The Scala archive does not include a count field, so the count of the returned scale will be the number of pitches in the scale.
      #
      # @example
      #   Tonal::Scale.from_scalarchive("wilson7")
      #   => [1/1, 28/27, 16/15, 10/9, 9/8, 7/6, 6/5, 5/4, 35/27, 4/3, 27/20, 45/32, 35/24, 3/2, 14/9, 8/5, 5/3, 27/16, 7/4, 9/5, 15/8, 35/18]
      #
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
      # TODO: Consider deleting the YAML format, since it's not a standard for musical scales and is easily confused with the SCL format.  If we keep it, consider changing the file extension to something other than .yml or .yaml to avoid confusion.
      # @deprecated
      def from_yaml(file_location)
        Tonal::IO::Yaml.read(file_location)
      end

      # @return [Tonal::Scale] parsed from JSON file
      # @example
      #
      # @param [String] name and location of JSON file
      #
      # TODO: Consider deleting the JSON format, since it's not a standard for musical scales and is easily confused with the SCL format.  If we keep it, consider changing the file extension to something other than .json to avoid confusion.
      # @deprecated
      def from_json(file_location)
        Tonal::IO::Json.read(file_location)
      end
    end
  end
end
