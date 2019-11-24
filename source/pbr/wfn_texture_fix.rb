# Physically-Based Rendering extension for SketchUp 2017 or newer.
# Copyright: © 2019 Samuel Tallet <samuel.tallet arobase gmail.com>
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

  # A texture fix... for SketchUp.
  class WfnTextureFix

    # Fixes textures without filename or not supported by glTF (.bmp, .tif...).
    def initialize

      # XXX Works only on SketchUp >= 2018.
      return if Sketchup.version.to_i < 18

      Sketchup.active_model.materials.each { |mat|

        if mat.materialType == Sketchup::Material::MATERIAL_TEXTURED\
          or mat.materialType == Sketchup::Material::MATERIAL_COLORIZED_TEXTURED

          if mat.texture.filename.empty?\
          	or mat.texture.filename !~ /\.(jpg|png)$/

              fix_material_texture(mat)

          end

        end

      }

    end

    # Fixes texture without filename or not supported by glTF (.bmp, .tif...).
    #
    # @param [Sketchup::Material] mat SketchUp material texture to fix.
    #
    # @return [void]
    private def fix_material_texture(mat)

      texture_path = File.join(
        Sketchup.temp_dir, 'sketchup-tex-' + mat.object_id.to_s + '.png'
      )

      texture_width = mat.texture.width

      texture_height = mat.texture.height

      mat.texture.image_rep.save_file(texture_path)

      mat.texture = texture_path

      mat.texture.size = [texture_width, texture_height]

      File.delete(texture_path)

    end

  end

end
