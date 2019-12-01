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

# PBR plugin namespace.
module PBR

  # Observes SketchUp sun events and reacts.
  class SunObserver < Sketchup::ShadowInfoObserver

    # rubocop: disable Naming/MethodName

    # When user changes shadow settings:
    def onShadowInfoChanged(_shadow_info, type)

      # Escape if it's not about "Time/Date sliders".
      return unless type.zero?

      if SESSION[:track_all_changes?]

        Viewport.update_sun_direction
      
        Viewport.update_data_version

      end

    end

    # rubocop: enable Naming/MethodName

  end

end
