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
require 'extensions'

# PBR plugin namespace.
module PBR

  VERSION = '1.3.6'.freeze

  # Load translation if it's available for current locale.
  TRANSLATE = LanguageHandler.new('pbr.strings')
  # See: "pbr/Resources/#{Sketchup.get_locale}/pbr.strings"

  # Remember extension name. See: PBR::Observer, PBR::Menu.
  NAME = TRANSLATE['Physically-Based Rendering']

  # Initialize session storage of PBR plugin.
  SESSION = nil.to_h
  # Session storage is cleared when SketchUp process ends.

  # Register extension.

  extension = SketchupExtension.new(NAME, 'pbr/load.rb')

  extension.version     = VERSION
  extension.creator     = 'Samuel Tallet-Sabathé'
  extension.copyright   = "© 2018 #{extension.creator}"

  features = [
    TRANSLATE['Add reflects and reliefs to your SketchUp models.'],
    TRANSLATE['Get a realistic render in real-time.'],
    TRANSLATE['Export result to image or 3D object.']
  ]

  extension.description = features.join(' ')

  Sketchup.register_extension(
    extension,
    true # load_at_start
  )

end
