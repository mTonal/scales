module Tonal
  module IO
    def self.mtonal_directory
      Pathname.new(Dir.home).join("mTonal")
    end

    def self.scl_directory
      mtonal_directory.join("My SCL files")
    end

    def self.kbm_directory
      mtonal_directory.join("My KBM files")
    end

    def self.work_directory
      mtonal_directory.join("tmp")
    end
  end
end
