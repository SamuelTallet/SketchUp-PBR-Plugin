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

require 'fileutils'
require 'sketchup'
require 'pbr/material_editor'
require 'pbr/light'
require 'pbr/gltf'

# PBR plugin namespace.
module PBR

  # Toolbar of PBR plugin.
  class Toolbar

    # Absolute path to icons.
    ICONS_PATH = File.join(__dir__, 'Toolbar Icons').freeze

    private_constant :ICONS_PATH

    # Initializes instance.
    def initialize

      @toolbar = UI::Toolbar.new(TRANSLATE['PBR'])

    end

    # Returns extension of icons depending on platform...
    #
    # @return [String] Extension. PDF (Mac) or SVG (Win).
    private def icon_extension

      if Sketchup.platform == :platform_osx
        '.pdf'
      else
        '.svg'
      end

    end

    # Adds "Edit Materials..." command.
    #
    # @return [nil]
    private def add_edit_materials_command

      command = UI::Command.new('em') { MaterialEditor.safe_show }

      command.small_icon = File.join(ICONS_PATH, 'em'.concat(icon_extension))
      command.large_icon = File.join(ICONS_PATH, 'em'.concat(icon_extension))

      command.tooltip = TRANSLATE['Edit Materials...']
      command.status_bar_text =\
       TRANSLATE['Define if a material is rough, is a metal, etc.']

      @toolbar.add_item(command)

      nil

    end

    # Adds "Add an Artificial Light" command.
    #
    # @return [nil]
    private def add_artificial_light_command

      command = UI::Command.new('aal') { Light.new }

      command.small_icon = File.join(ICONS_PATH, 'aal'.concat(icon_extension))
      command.large_icon = File.join(ICONS_PATH, 'aal'.concat(icon_extension))

      command.tooltip = TRANSLATE['Add an Artificial Light']
      command.status_bar_text = TRANSLATE['Move it in space. Change its color.']

      @toolbar.add_item(command)

      nil

    end

    # Adds "Reopen Viewport" command.
    #
    # @return [nil]
    private def add_reopen_viewport_command

      command = UI::Command.new('rv') do

        return PBR.open_required_plugin_page unless PBR.required_plugin_exist?

        Viewport.reopen_if_model_updated

      end

      command.small_icon = File.join(ICONS_PATH, 'rv'.concat(icon_extension))
      command.large_icon = File.join(ICONS_PATH, 'rv'.concat(icon_extension))

      command.tooltip = TRANSLATE['Reopen Viewport']
      command.status_bar_text = TRANSLATE['Render scene in real-time.']

      @toolbar.add_item(command)

      nil

    end

    # Adds "Export As 3D Object..." command.
    #
    # @return [nil]
    private def add_export_as_gltf_command

      command = UI::Command.new('eag') do

        return PBR.open_required_plugin_page unless PBR.required_plugin_exist?
        
        GlTF.export

      end

      command.small_icon = File.join(ICONS_PATH, 'eag'.concat(icon_extension))
      command.large_icon = File.join(ICONS_PATH, 'eag'.concat(icon_extension))

      command.tooltip = TRANSLATE['Export As 3D Object...']
      command.status_bar_text = TRANSLATE['Save 3D model as .gltf.']

      @toolbar.add_item(command)

      nil

    end

    # Prepares.
    #
    # @return [UI::Toolbar] Toolbar instance.
    def prepare

      add_edit_materials_command

      add_artificial_light_command

      add_reopen_viewport_command

      add_export_as_gltf_command

      @toolbar

    end

  end

end
