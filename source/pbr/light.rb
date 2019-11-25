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
require 'pbr/shapes'
require 'pbr/entity_observer'

# PBR plugin namespace.
module PBR

  # Artificial light(s) added in SketchUp.
  class Light

    # Layer that "contains" light(s).
    LAYER_NAME = 'PBR Lights'.freeze

    # Makes a light.
    def initialize

      Sketchup.active_model.layers.add(LAYER_NAME)

      @light = Shapes.create_sphere('30cm', 10, 8, LAYER_NAME)

      SESSION[:lights_objects_ids].push(@light.object_id.to_i)

      @light.add_observer(EntityObserver.new)

    end

  end

end
