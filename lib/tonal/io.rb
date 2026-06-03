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

    def to_kbm(file_name=nil, fave: false, location: nil)
      fave_location = fave ? Tonal::IO::Kbm.faves_directory : ""
      location = location.nil? ? Tonal::IO::Kbm.root_directory.join(fave_location, count.to_s) : Pathname.new("").join(location, fave_location, count.to_s)
      Tonal::IO::Kbm.new(file_name || self.name,
        name: self.name,
        description: self.description,
        pitches: self.to_r.map(&:to_s),
        location: location
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
    end
  end
end
