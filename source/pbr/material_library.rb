# Physically-Based Rendering extension for SketchUp 2017 or newer.
# Copyright: © 2018 Samuel Tallet-Sabathé <samuel.tallet@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

raise 'The PBR plugin requires at least Ruby 2.2.0 or SketchUp 2017.'\
  unless RUBY_VERSION.to_f >= 2.2 # SketchUp 2017 includes Ruby 2.2.4.

require 'sketchup'
require 'fileutils'

# PBR plugin namespace.
module PBR

  # Manages SketchUp Materials library shipped with PBR plugin.
  module MaterialLibrary

    # Absolute path to "Material Library" directory. Source.
    SRC_DIR = File.join(__dir__, 'Material Library').freeze

    # Absolute path to "Materials" directory. Destination.
    DEST_DIR = File.join(Sketchup.find_support_file('Materials'), 'PBR').freeze

    # Installs materials library. Note: a soft restart is required to see them.
    def self.install

      FileUtils.mkdir_p(DEST_DIR)

      # Note: *.skm files are SketchUp Materials.
      skm_src_files = Dir[File.join(SRC_DIR, '*.skm')]

      skm_src_files.each do |skm_src_file|

        FileUtils.copy(skm_src_file, DEST_DIR)\
          unless File.exist?(File.join(DEST_DIR, File.basename(skm_src_file)))

      end

    end

  end

end
