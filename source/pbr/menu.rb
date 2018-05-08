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
require 'pbr/material_editor'
require 'fileutils'
require 'pbr/gltf'
require 'pbr/web_server'

# PBR plugin namespace.
module PBR

  # Connects PBR plugin menu to SketchUp user interface.
  class Menu

    # Adds PBR plugin menu (items included) in a SketchUp menu.
    #
    # @param [Sketchup::Menu] parent_menu Target parent menu.
    # @raise [ArgumentError]
    def initialize(parent_menu)

      raise ArgumentError, 'Parent menu must be a SketchUp::Menu.'\
        unless parent_menu.is_a?(Sketchup::Menu)

      @menu = parent_menu.add_submenu(NAME)

      add_features_items

      @menu.add_separator

      add_author_items

    end

    # Adds menu items related to features.
    #
    # @return [void]
    private def add_features_items

      @menu.add_item(TRANSLATE['Edit Materials...']) { edit_materials }

      @menu.add_item(TRANSLATE['Change Environment Map...']) { change_env_map }
      
      @menu.add_item('⚫ ' + TRANSLATE['Open Viewport']) do

        propose_nil_material_fix

        open_viewport

      end

      @menu.add_item(TRANSLATE['Export As 3D Object...']) do

        propose_nil_material_fix

        export_as_gltf

      end

    end

    # Runs "Edit Materials..." menu command.
    #
    # @return [void]
    private def edit_materials

      # Show Material Editor if all good conditions are met.
      MaterialEditor.new.show if MaterialEditor.safe_to_open?

    end

    # Runs "Change Environment Map..." menu command.
    #
    # @return [void]
    private def change_env_map

      user_path = UI.openpanel(
        TRANSLATE['Select New Environment Map'],
        nil, TRANSLATE['HDR Image'] + '|*.hdr||'
      )

      # Escape if user cancelled env. map change.
      return if user_path.nil?
      
      FileUtils.copy(
        user_path,
        File.join(WebServer::ASSETS_DIR, 'environment-map.hdr')
      )

      UI.messagebox(TRANSLATE['Environment map successfully changed.'])

    end

    # Runs "Open Viewport" menu command.
    #
    # @return [void]
    private def open_viewport

      gltf = GlTF.new

      if gltf.valid?

        # Overwrite glTF model. So, Viewport will display an up-to-date model.
        File.write(
          File.join(WebServer::ASSETS_DIR, 'sketchup-model.gltf'), gltf.json
        )

        # Open PBR Viewport in default Web browser.
        UI.openURL(WebServer.viewport_url)

      else

        propose_help(TRANSLATE['glTF export failed. Do you want help?'])

      end

    end

    # Runs "Export As 3D Object..." menu command.
    #
    # @return [void]
    private def export_as_gltf

      user_path = UI.savepanel(TRANSLATE['Export As glTF'], nil, GlTF.filename)

      # Escape if user cancelled export operation.
      return if user_path.nil?

      gltf = GlTF.new

      if gltf.valid?

        File.write(user_path, gltf.json)
        UI.messagebox(TRANSLATE['Model well exported here:'] + "\n#{user_path}")

      else
        
        propose_help(TRANSLATE['glTF export failed. Do you want help?'])

      end

    end

    # Proposes "nil material" fix to SketchUp user.
    #
    # @return [void]
    private def propose_nil_material_fix

      user_answer = UI.messagebox(
        TRANSLATE['Propagate materials to whole model? (Recommended)'],
        MB_YESNO
      )

      # Escape if user refused that fix.
      return if user_answer == IDNO

      require 'pbr/nil_material_fix'

      # Apply "nil material" fix.
      NilMaterialFix.new(TRANSLATE['Propagate Materials to Whole Model'])

    end

    # Proposes help to SketchUp user.
    #
    # @param [String] message Help proposal message.
    #
    # @return [void]
    private def propose_help(message)

      user_answer = UI.messagebox(message, MB_YESNO)

      # Escape if user refused that help.
      return if user_answer == IDNO

      require 'pbr/github'

      # Open help of PBR plugin in default Web browser.
      UI.openURL(GitHub.translated_help_url('SKETCHUP'))

    end

    # Adds menu items related to author.
    #
    # @return [void]
    private def add_author_items

      @menu.add_item('💌 ' + TRANSLATE['Donate to Plugin Author']) do

        UI.openURL('https://www.paypal.me/SamuelTS/')
        
      end

    end

  end

end
