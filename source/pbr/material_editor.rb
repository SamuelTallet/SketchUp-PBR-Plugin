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
require 'pbr/web_server'

# PBR plugin namespace.
module PBR

  # Allows to edit SketchUp materials with advanced settings such as Roughness.
  class MaterialEditor

    # Material Editor is open?
    #
    # Blocks concurrent edits to prevent corruption of active model.
    SESSION[:mat_editor_is_open] = false

    # Shows Material Editor unless it's already open.
    #
    # @raise [RuntimeError]
    #
    # @return [void]
    def self.show

      return UI.messagebox(TRANSLATE['Wait, there is no material to edit :p'])\
        if Sketchup.active_model.materials.size.zero?

      return UI.messagebox(TRANSLATE['PBR Material Editor is already open.'])\
        if SESSION[:mat_editor_is_open]

      dialog = create_html_dialog

      raise 'HTML dialog not created.' unless dialog.is_a?(UI::HtmlDialog)

      configure_html_dialog(dialog)

      dialog.show

      # Material Editor is open.
      SESSION[:mat_editor_is_open] = true
    
    end

    # Creates SketchUp HTML dialog that powers PBR Material Editor.
    #
    # @return [UI::HtmlDialog]
    def self.create_html_dialog

      UI::HtmlDialog.new(
        dialog_title:    TRANSLATE['PBR Material Editor'],
        preferences_key: 'PBR',
        scrollable:      true,
        width:           455,
        # @todo Calc. height depending on material attributes count?
        height:          310,
        min_width:       455,
        min_height:      310
      )

    end

    # Configures HTML dialog.
    #
    # @param [UI::HtmlDialog] dialog HTML dialog to configure.
    #
    # @return [void]
    def self.configure_html_dialog(dialog)

      dialog.set_url(WebServer.url('/material-editor'))
      # See: PBR::WebServer.mount_erb_handlers to get real path.
      
      dialog.add_action_callback('pullMaterials') do
        dialog.execute_script('PBR.materials = ' + materials_to_edit.to_json)
      end

      dialog.add_action_callback('pushMaterials') do |_context, edited_mats|
        self.edited_materials = edited_mats
      end

      dialog.add_action_callback('closeDialog') { dialog.close }

      dialog.set_on_closed { SESSION[:mat_editor_is_open] = false }

      dialog.center

    end

    # Collects SketchUp materials attributes to edit in PBR Material Editor.
    #
    # @return [Array<Hash>] Materials to edit. Caution! Array index matters.
    def self.materials_to_edit

      materials_to_edit = []

      # For each SketchUp material in active model:
      Sketchup.active_model.materials.each_with_index do |material, mat_index|

        materials_to_edit[mat_index] = {

          # Get PBR plugin attributes to edit.
          metallicFactor:  material.get_attribute(:pbr, :metallicFactor, 0.0),
          roughnessFactor: material.get_attribute(:pbr, :roughnessFactor, 0.7),
          # @note To speed up stream, texture images are not transmitted here. 
          alphaMode:       material.get_attribute(:pbr, :alphaMode, 'OPAQUE')

        }
        
      end

      materials_to_edit

    end

    # Syncs SketchUp materials with attributes edited in PBR Material Editor.
    #
    # @param [Array<Hash>] edited_mats Edited materials.
    #
    # @return [void]
    def self.edited_materials=(edited_mats)

      # For each edited material...
      edited_mats.each_with_index do |mat_attributes, mat_index|

        material = Sketchup.active_model.materials[mat_index]

        # attribute:
        mat_attributes.each do |mat_attr_key, mat_attr_value|

          if mat_attr_value == 'DELETE_ATTRIBUTE'

            # Remove attribute from SketchUp material definition or...
            material.delete_attribute(:pbr, mat_attr_key)

          elsif !mat_attr_value.nil?

            # replace attribute value of SketchUp material.
            material.set_attribute(:pbr, mat_attr_key, mat_attr_value)

          end

        end

      end
      
    end

    private_class_method :create_html_dialog,
                         :configure_html_dialog,
                         :materials_to_edit,
                         :edited_materials=

  end

end
