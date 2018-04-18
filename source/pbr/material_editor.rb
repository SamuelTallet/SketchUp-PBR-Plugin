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
require 'pbr/html_dialogs'

# PBR plugin namespace.
module PBR

  # Allows to edit SketchUp materials with advanced settings such as Roughness.
  class MaterialEditor

    # Is it safe to open Material Editor right now?
    #
    # @return [Boolean]
    def self.safe_to_open?

      if Sketchup.active_model.materials.size.zero?
        UI.messagebox(TRANSLATE['Wait, there is no material to edit :p'])
        return false
      end

      if SESSION[:mat_editor_open?]
        UI.messagebox(TRANSLATE['PBR Material Editor is already open.'])
        return false
      end

      true

    end

    # Builds Material Editor.
    def initialize

      @dialog = create_dialog

      fill_dialog

      configure_dialog

    end

    # Shows Material Editor.
    #
    # @return [void]
    def show

      @dialog.show

      # Material Editor is open.
      SESSION[:mat_editor_open?] = true

    end

    # Creates SketchUp HTML dialog that powers PBR Material Editor.
    #
    # @return [UI::HtmlDialog] Dialog.
    private def create_dialog

      UI::HtmlDialog.new(
        dialog_title:    TRANSLATE['PBR Material Editor'],
        preferences_key: 'PBR',
        scrollable:      true,
        width:           455,
        # @todo Calc. height depending on material attributes count?
        height:          315,
        min_width:       455,
        min_height:      315
      )

    end

    # Fills HTML dialog.
    #
    # @return [void]
    private def fill_dialog

      @dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'material-editor.rhtml',
        scripts: ['lib/tipfy/tipfy.min.js', 'material-editor.js'],
        styles: ['lib/tipfy/tipfy.min.css', 'material-editor.css']

      ))

    end

    # Configures HTML dialog.
    #
    # @return [void]
    private def configure_dialog

      @dialog.add_action_callback('pullMaterials') do
        @dialog.execute_script('PBR.materials = ' + materials_to_edit.to_json)
      end

      @dialog.add_action_callback('pushMaterials') do |_context, edited_mats|
        self.edited_materials = edited_mats
      end

      @dialog.add_action_callback('closeDialog') { @dialog.close }

      @dialog.set_on_closed { SESSION[:mat_editor_open?] = false }

      @dialog.center

    end

    # Collects SketchUp materials attributes to edit in PBR Material Editor.
    #
    # @param [Hash] mats_to_edit Materials to edit. Default: Empty hash.
    #
    # @return [Hash<Hash>] Materials to edit.
    private def materials_to_edit(mats_to_edit = {})

      # For each SketchUp material in active model:
      Sketchup.active_model.materials.each do |mat|

        mats_to_edit[mat.object_id] = {

          # Get PBR plugin attributes to edit.
          
          metallicFactor:     mat.get_attribute(:pbr, :metallicFactor, 0.0),
          roughnessFactor:    mat.get_attribute(:pbr, :roughnessFactor, 0.7),

          # Get status of texture image, not its contents. To speed up stream.
          normalTextureURI:   normal_texture_uri_status(mat),
          normalTextureScale: mat.get_attribute(:pbr, :normalTextureScale, 1.0),

          alphaMode:          mat.get_attribute(:pbr, :alphaMode, 'OPAQUE')

        }
        
      end

      mats_to_edit

    end

    # Returns status of a normal texture image.
    #
    # @param [Sketchup::Material] mat Material.
    # @raise [ArgumentError]
    #
    # @return [String, nil] Empty string if texture image is defined, else nil.
    private def normal_texture_uri_status(mat)

      raise ArgumentError, 'Invalid SketchUp material.'\
       unless mat.is_a?(Sketchup::Material)

      normal_texture_uri = mat.get_attribute(:pbr, :normalTextureURI)

      normal_texture_uri.is_a?(String) ? '' : nil

    end

    # Syncs SketchUp materials with attributes edited in PBR Material Editor.
    #
    # @param [Hash<Hash>] edited_mats Edited materials.
    #
    # @return [void]
    private def edited_materials=(edited_mats)

      # For each edited material...
      edited_mats.each do |mat_object_id, mat_attributes|

        material = ObjectSpace._id2ref(mat_object_id.to_i)

        # attribute:
        mat_attributes.each do |mat_attr_key, mat_attr_value|

          if mat_attr_value == false

            material.delete_attribute(:pbr, mat_attr_key)

          elsif !mat_attr_value.to_s.empty?

            material.set_attribute(:pbr, mat_attr_key, mat_attr_value)

          end

        end

      end
      
    end

  end

end
