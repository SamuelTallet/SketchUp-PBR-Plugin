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
require 'pbr/menu'
require 'json'
require 'pbr/wfn_texture_fix'
require 'pbr/wcr_light_fix'
require 'pbr/light'
require 'pbr/nil_material_fix'
require 'pbr/gltf_lights'

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

      # BTW, filter Win/Mac reserved characters & superfluous whitespace.
      basename.gsub(%r{[\x00-\x1F<>:"/\\|?*]}u, '').strip.concat('.gltf')

    end

    # Exports as 3D object.
    #
    # @return [nil]
    def self.export

      user_path = UI.savepanel(TRANSLATE['Export as glTF'], nil, filename)

      # Escape if user cancelled operation.
      return if user_path.nil?

      gltf = self.new

      if gltf.valid?

        File.write(user_path, gltf.json)
        UI.messagebox(TRANSLATE['Model well exported here:'] + "\n#{user_path}")

      else
        
        Menu.propose_help(TRANSLATE['glTF export failed. Do you want help?'])

      end

      nil

    end

    # Generates a glTF asset including PBR plugin attributes: Normal map, etc.
    def initialize

      # The root object for a glTF asset.
      @gltf = {}

      # A flag to know if asset is valid.
      @valid = true

      begin

        SESSION[:export_in_progress?] = true

        Sketchup.active_model.start_operation(
          TRANSLATE['Export geometry and textures to glTF format'],
          true # disable_ui
        )

        Sketchup.status_text = TRANSLATE[
          'PBR: Exporting geometry and textures... Please wait.'
        ]

        generate

        complete

        Sketchup.active_model.commit_operation

        SESSION[:export_in_progress?] = false

        Sketchup.status_text = nil

      rescue StandardError => _exception

        @valid = false

        Sketchup.active_model.abort_operation

        SESSION[:export_in_progress?] = false

        Sketchup.status_text = nil

        puts 'glTF export failed because: ' + _exception.to_s

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

    # Applies various fixes.
    #
    # @return [nil]
    private def apply_various_fixes

      WfnTextureFix.new

      WcrLightFix.new
      Sketchup.active_model.layers.add(Light::LAYER_NAME)

      NilMaterialFix.new

      nil

    end

    # Generates almost all of glTF asset thanks to exporter made by Centaur.
    # @see https://extensions.sketchup.com/content/gltf-exporter
    #
    # @return [nil] but store asset in `gltf` instance variable.
    private def generate

      gltfile = File.join(Sketchup.temp_dir, 'SketchUpModel.gltf')

      File.delete(gltfile) if File.exist?(gltfile)

      apply_various_fixes

      # XXX We hide PBR Lights layer to avoid glTF model "pollution".
      Sketchup.active_model.layers[Light::LAYER_NAME].visible = false
      
      Centaur::GltfExporter::GltfExport.new.export(
        false, # is_binary
        false, # is_microsoft
        gltfile # destination
      )

      Sketchup.active_model.layers[Light::LAYER_NAME].visible = true

      # Store asset as a Hash.
      @gltf = JSON.parse(File.read(gltfile))

      nil

    end

    # Completes this glTF asset with PBR plugin attributes: Normal map, etc.
    #
    # @return [nil]
    private def complete

      # For each glTF material in asset:
      @gltf['materials'].each do |gltf_mat|

        # Get SketchUp material by its display name as it's unique per model.
        mat = skp_mat_by_display_name(gltf_mat['name'])

        # Get PBR plugin attributes of SketchUp material. Note: `metallicFactor`
        # and `roughnessFactor` have been processed by Centaur's glTF exporter.

        add_mr_tex(gltf_mat, mat.get_attribute(:pbr, :metalRoughTextureURI))

        add_normal_tex(gltf_mat,
          mat.get_attribute(:pbr, :normalTextureURI),
          mat.get_attribute(:pbr, :normalTextureScale)
        )

        add_ao_tex(gltf_mat,
          mat.get_attribute(:pbr, :ambientOcclusionTextureURI)
        )

        update_alpha_mode(gltf_mat, mat.get_attribute(:pbr, :alphaMode))

        add_extra_po_tex(gltf_mat,
          mat.get_attribute(:pbr, :parallaxOcclusionTextureURI)
        )

      end

      add_extra_lights

      # Tools that generated this glTF model. Useful for debugging.
      @gltf['asset']['generator'] += ", SketchUp PBR plugin v#{VERSION}"

      nil

    end

    # Retrieves SketchUp material with its display name.
    # 
    # @param [String] dp_name SketchUp material display name.
    # @raise [ArgumentError]
    #
    # @return [Sketchup::Material, nil] SketchUp material or nil.
    private def skp_mat_by_display_name(dp_name)

      raise ArgumentError, 'Name must be a String.' unless dp_name.is_a?(String)

      material = nil

      Sketchup.active_model.materials.each do |mat|

        if mat.display_name == dp_name
          material = mat
          break
        end

      end

      material

    end

    # Adds a metallic-roughness texture to a glTF material
    # only if URI is provided.
    #
    # @param [Hash] gltf_mat glTF material to texture on.
    # @raise [ArgumentError]
    #
    # @param [String, nil] metal_rough_tex_uri Metal-Rough texture URI or nil.
    #
    # @return [nil]
    private def add_mr_tex(gltf_mat, metal_rough_tex_uri)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if metal_rough_tex_uri.nil?

      gltf_mat['pbrMetallicRoughness'] = {}\
       unless gltf_mat.key?('pbrMetallicRoughness')

      # The metallic-roughness texture.
      gltf_mat['pbrMetallicRoughness']['metallicRoughnessTexture'] = {

        # The index of the texture.
        index: add_texture(metal_rough_tex_uri),

        # The set index of texture's TEXCOORD
        # property used for coordinate mapping.
        texCoord: base_color_tex_coord(gltf_mat)

      }

      nil

    end

    # Adds a normal texture to a glTF material
    # only if URI is provided.
    #
    # @param [Hash] gltf_mat glTF material to texture on.
    # @raise [ArgumentError]
    #
    # @param [String, nil] normal_tex_uri Normal texture URI or nil.
    # @param [String, Float, nil] normal_tex_scale Normal texture scale or nil.
    #
    # @return [nil]
    private def add_normal_tex(gltf_mat, normal_tex_uri, normal_tex_scale)

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

      # The scalar multiplier applied to each
      # normal vector of the normal texture.
      gltf_mat['normalTexture']['scale'] = normal_tex_scale.to_f\
       unless normal_tex_scale.nil? || normal_tex_scale.to_f == 1.0

      nil

    end

    # Adds an [ambient] occlusion texture to a glTF material
    # only if URI is provided.
    #
    # @param [Hash] gltf_mat glTF material to texture on.
    # @raise [ArgumentError]
    #
    # @param [String, nil] ao_tex_uri Ambient occlusion texture URI or nil.
    #
    # @return [nil]
    private def add_ao_tex(gltf_mat, ao_tex_uri)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if ao_tex_uri.nil?

      # The [ambient] occlusion map texture.
      gltf_mat['occlusionTexture'] = {

        # The index of the texture.
        index: add_texture(ao_tex_uri),

        # The set index of texture's TEXCOORD
        # property used for coordinate mapping.
        texCoord: base_color_tex_coord(gltf_mat),

        # A scalar multiplier controlling
        # the amount of occlusion applied.
        strength: 0.7

      }

      nil

    end

    # Adds any type of texture to this glTF asset.
    #
    # @param [String] uri URI of texture to add.
    # @raise [ArgumentError]
    #
    # @return [Integer] Index of texture added.
    private def add_texture(uri)

      raise ArgumentError, 'URI is not a String.' unless uri.is_a?(String)

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
    # @return [nil]
    private def update_alpha_mode(gltf_mat, alpha_mode)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if alpha_mode.nil? || alpha_mode == 'OPAQUE'

      # The alpha rendering mode of the material.
      gltf_mat['alphaMode'] = alpha_mode

      nil

    end

    # Adds a parallax occlusion texture to a glTF material
    # only if URI is provided. XXX This isn't in the spec.
    #
    # @param [Hash] gltf_mat glTF material to texture on.
    # @raise [ArgumentError]
    #
    # @param [String, nil] par_occ_tex_uri Parallax occlusion tex. URI or nil.
    #
    # @return [nil]
    private def add_extra_po_tex(gltf_mat, par_occ_tex_uri)

      raise ArgumentError, 'Invalid glTF material.' unless gltf_mat.is_a?(Hash)

      return if par_occ_tex_uri.nil?

      gltf_mat['extras'] = {} unless gltf_mat.key?('extras')

      # The parallax occlusion texture.
      gltf_mat['extras']['parallaxOcclusionTextureURI'] = par_occ_tex_uri

      nil

    end

    # Adds extra lights. XXX This isn't in the spec.
    #
    # @return [nil]
    private def add_extra_lights

      lights = GlTFLights.new.lights

      return if lights.empty?

      @gltf['extras'] = {} unless @gltf.key?('extras')

      @gltf['extras']['lights'] = lights

      nil

    end

  end

end
