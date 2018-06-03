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
require 'pbr/observer'
require 'pbr/material_library'
require 'pbr/web_server'
require 'pbr/menu'

# PBR plugin namespace.
module PBR

  # Attach PBR observer to SketchUp.
  Sketchup.add_observer(Observer.new)

  # Install (skm) materials library.
  MaterialLibrary.install

  # Stop PBR Web server in case last SketchUp exit was "hard" (e.g. a crash).
  WebServer.stop

  # Start Web server. For security reasons: server listens to localhost only.
  WebServer.start
  # PBR Web server is stopped as soon as SketchUp is exited by SketchUp user.

  # Material Editor is not open yet.
  SESSION[:mat_editor_open?] = false

  # Plug PBR menu into SketchUp UI.
  Menu.new(
    UI.menu('Plugins') # parent_menu
  )

  # Load complete.

end
