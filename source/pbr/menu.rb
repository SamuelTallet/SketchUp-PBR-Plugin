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
require 'pbr/viewport'
require 'pbr/material_editor'
require 'pbr/light'
require 'pbr/gltf'

# PBR plugin namespace.
module PBR

  # Connects PBR plugin menu to SketchUp user interface.
  class Menu

    # Proposes help to SketchUp user.
    #
    # @param [String] message Help proposal message.
    #
    # @return [void]
    def self.propose_help(message)

      user_answer = UI.messagebox(message, MB_YESNO)

      # Escape if user refused that help.
      return if user_answer == IDNO

      require 'pbr/github'

      # Open help of PBR plugin in default Web browser.
      UI.openURL(GitHub.translated_help_url('SKETCHUP'))

    end

    # Adds PBR plugin menu (items included) in a SketchUp menu.
    #
    # @param [Sketchup::Menu] parent_menu Target parent menu.
    # @raise [ArgumentError]
    def initialize(parent_menu)

      raise ArgumentError, 'Parent menu must be a SketchUp::Menu.'\
        unless parent_menu.is_a?(Sketchup::Menu)

      @menu = parent_menu.add_submenu(NAME)

      add_change_hdr_bg_item

      add_edit_materials_item

      add_artificial_light_item

      add_reopen_viewport_item

      add_export_as_gltf_item

      add_donate_to_author_item

    end

    # Adds "Change HDR Background..." menu item.
    #
    # @return [nil]
    private def add_change_hdr_bg_item

      @menu.add_item(TRANSLATE['Change HDR Background...']) do

        Viewport.change_hdr_bg
        
      end

      nil

    end

    # Adds "Edit Materials..." menu item.
    #
    # @return [nil]
    private def add_edit_materials_item

      @menu.add_item('⬕ ' + TRANSLATE['Edit Materials...']) do

        MaterialEditor.safe_show
        
      end

      nil

    end

    # Adds "Add an Artificial Light" menu item.
    #
    # @return [nil]
    private def add_artificial_light_item

      @menu.add_item('💡 ' + TRANSLATE['Add an Artificial Light']) { Light.new }

      nil
      
    end

    # Adds "Reopen Viewport" menu item.
    #
    # @return [nil]
    private def add_reopen_viewport_item

      @menu.add_item(TRANSLATE['Reopen Viewport']) do

        return PBR.open_required_plugin_page unless PBR.required_plugin_exist?

        Viewport.reopen_if_model_updated

      end

      nil

    end

    # Adds "Export As 3D Object..." menu item.
    #
    # @return [void]
    private def add_export_as_gltf_item

      @menu.add_item(TRANSLATE['Export As 3D Object...']) do

        return PBR.open_required_plugin_page unless PBR.required_plugin_exist?

        GlTF.export

      end

    end

    # Adds "Donate to Plugin Author" menu item.
    #
    # @return [void]
    private def add_donate_to_author_item

      @menu.add_item('💌 ' + TRANSLATE['Donate to Plugin Author']) do

        UI.openURL('https://www.paypal.me/SamuelTS/')
        
      end

    end

  end

end
