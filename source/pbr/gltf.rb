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
require 'json'

# PBR plugin namespace.
module PBR

  # Helps to get a glTF asset representing the active model in SketchUp.
  #
  # @see https://www.khronos.org/gltf/ If you want to know what is glTF.
  class GlTF

    # Returns a filename for a glTF asset.
    #
    # @return [String] A filename ending with `.gltf`.
    def self.filename

      # The glTF filename is based on SketchUp active model filename.
      basename = if Sketchup.active_model.path.empty?
                   TRANSLATE['Untitled']
                 else
                   File.basename(Sketchup.active_model.path, '.skp')
                 end

      # Filter Win/Mac reserved characters & superfluous whitespace.
      basename = basename.gsub(%r{[\x00-\x1F<>:"/\\|?*]}u, '').strip

      basename.concat('.gltf')

    end

    # Generates a glTF asset including PBR plugin attributes: Normal map, etc.
    def initialize

      # The root object for a glTF asset.
      @gltf = {}

      # A flag to know if asset is valid.
      @valid = true

      begin

        generate

        complete

      rescue StandardError => _error

        @valid = false

      end

    end

    # Is this glTF asset valid?
    #
    # @return [Boolean]
    def valid?

      @valid

    end

    # Returns this glTF asset as JSON.
    #
    # Be sure to call `valid?` before.
    #
    # @return [String]
    def json

      JSON.fast_generate(@gltf)

    end

    # Generates almost all of glTF asset thanks to exporter made by Centaur.
    # @see https://extensions.sketchup.com/content/gltf-exporter
    #
    # @return [void] but store asset in `gltf` instance variable.
    private def generate

      gltfile = File.join(Sketchup.temp_dir, 'SketchUpModel.gltf')

      File.delete(gltfile) if File.exist?(gltfile)
      
      Centaur::GltfExporter::GltfExport.new.export(
        false, # is_binary
        false, # is_microsoft
        gltfile # destination
      )

      # Store asset as a Hash.
      @gltf = JSON.parse(File.read(gltfile))

    end

    # Completes this glTF asset with PBR plugin attributes: Normal map, etc.
    #
    # @return [void]
    private def complete

      # For each glTF material in asset:
      @gltf['materials'].each do |gltf_mat|

        # Get SketchUp material by its display name as it's unique per model.
        mat = skp_mat_by_display_name(gltf_mat['name'])

        # Get PBR plugin attributes of SketchUp material. Note: `metallicFactor`
        # and `roughnessFactor` have been processed by Centaur's glTF exporter.

        add_normal_tex(gltf_mat, mat.get_attribute(:pbr, :normalTextureURI))
        add_emissive_tex(gltf_mat, mat.get_attribute(:pbr, :emissiveTextureURI))

        update_alpha_mode(gltf_mat, mat.get_attribute(:pbr, :alphaMode))

      end

      # Tools that generated this glTF model. Useful for debugging.
      @gltf['asset']['generator'] += ', PBR extension for SketchUp'\
        if @gltf['asset'].key?('generator')

    end

    # Retrieves SketchUp material with its display name.
    # 
    # @param [String] display_name SketchUp material display name.
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Material, nil] SketchUp material or nil.
    private def skp_mat_by_display_name(display_name)

      raise ArgumentError, 'Display name must be a String.'\
       unless display_name.is_a?(String)

      material = nil

      Sketchup.active_model.materials.each do |mat|

        if mat.display_name == display_name
          material = mat
          break
        end

      end

      material

    end

    # Adds a normal texture to a glTF material
    # only if URI is provided.
    #
    # @param [Hash] gltf_mat glTF material to texture on.
    # @raise [ArgumentError]
    #
    # @param [String, nil] normal_tex_uri URI of normal texture or nil.
    #
    # @return [void]
    private def add_normal_tex(gltf_mat, normal_tex_uri)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if normal_tex_uri.nil?

      # The normal map texture.
      gltf_mat['normalTexture'] = {

        # The index of the texture.
        index: add_texture(normal_tex_uri),

        # The set index of texture's TEXCOORD
        # property used for coordinate mapping.
        texCoord: base_color_tex_coord(gltf_mat)

      }

    end

    # Adds an emissive texture to a glTF material
    # only if URI is provided.
    #
    # @param [Hash] gltf_mat glTF material to texture on.
    # @raise [ArgumentError]
    #
    # @param [String, nil] emissive_tex_uri URI of emissive texture or nil.
    #
    # @return [void]
    private def add_emissive_tex(gltf_mat, emissive_tex_uri)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if emissive_tex_uri.nil?

      # The emissive map texture.
      gltf_mat['emissiveTexture'] = {

        # The index of the texture.
        index: add_texture(emissive_tex_uri),

        # The set index of texture's TEXCOORD...
        texCoord: base_color_tex_coord(gltf_mat)

      }

      # The emissive factor of the material.
      # Required to display emissive texture.
      gltf_mat['emissiveFactor'] = [1.0, 1.0, 1.0]

    end

    # Adds any type of texture to this glTF asset.
    #
    # @param [String] uri URI of texture to add.
    # @raise [ArgumentError]
    #
    # @return [Integer] Index of texture added.
    private def add_texture(uri)

      raise ArgumentError, 'URI is not a String' unless uri.is_a?(String)

      # An array of images. An image defines data used to create a texture.
      @gltf['images'] = [] unless @gltf.key?('images')

      # The URI of the image [...] can also be a Data-URI. 
      # The image format must be JPEG (.jpg) or PNG (.png).
      @gltf['images'].push(uri: uri)

      image_index = -1 + @gltf['images'].size

      # An array of textures.
      @gltf['textures'] = [] unless @gltf.key?('textures')

      # The index of the image used by this texture.
      @gltf['textures'].push(source: image_index)

      texture_index = -1 + @gltf['textures'].size

      texture_index

    end

    # Grabs texture coordinates (TEXCOORD) index from base color texture.
    #
    # @param [Hash] gltf_mat glTF material that needs a TEXCOORD index.
    # @raise [ArgumentError]
    #
    # @return [Integer] Base color... TEXCOORD index or 0 if it's missing!
    private def base_color_tex_coord(gltf_mat)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      if gltf_mat.key?('pbrMetallicRoughness')\
        && gltf_mat['pbrMetallicRoughness'].key?('baseColorTexture')\
          && gltf_mat['pbrMetallicRoughness']['baseColorTexture'].key?('index')

        return gltf_mat['pbrMetallicRoughness']['baseColorTexture']['index']

      end

      0

    end

    # Updates alpha rendering mode of a glTF material
    # only if mode is provided and distinct to its default value.
    #
    # @param [Hash] gltf_mat glTF material to render...
    # @raise [ArgumentError]
    #
    # @param [String, nil] alpha_mode Alpha rendering mode or nil.
    #
    # @return [void]
    private def update_alpha_mode(gltf_mat, alpha_mode)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if alpha_mode.nil? || alpha_mode == 'OPAQUE'

      # The alpha rendering mode of the material.
      gltf_mat['alphaMode'] = alpha_mode

    end

  end

end
