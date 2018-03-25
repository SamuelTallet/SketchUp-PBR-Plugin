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

      @menu = parent_menu.add_submenu(TRANSLATE['Physically-Based Rendering'])

      add_items

    end

    # Adds menu items.
    #
    # @return [void]
    private def add_items

      @menu.add_item(TRANSLATE['Edit Materials...']) { MaterialEditor.show }
      
      @menu.add_item('⚫ ' + TRANSLATE['Open Viewport']) do

        propose_nil_material_fix

        UI.openURL(WebServer.url('/viewport'))
        # See: PBR::WebServer.mount_erb_handlers to get real path.

      end

      @menu.add_item(TRANSLATE['Export As 3D Object...']) do

        propose_nil_material_fix

        UI.openURL(WebServer.url('/assets/sketchup-model.gltf?export'))
        # See: PBR::GlTFServlet as this path is completely virtual.

      end
      
    end

    # Proposes "nil material" fix to user.
    #
    # @return [void]
    private def propose_nil_material_fix

      user_answer = UI.messagebox(
        TRANSLATE['Propagate materials to whole model? (Recommended)'],
        MB_YESNO
      )

      return if user_answer == IDNO

      require 'pbr/nil_material_fix'

      NilMaterialFix.new(TRANSLATE['Propagate Materials to Whole Model'])

    end

  end

end
