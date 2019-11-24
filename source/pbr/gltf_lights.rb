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
require 'pbr/light'

# PBR plugin namespace.
module PBR

  # Extra lights added to glTF model.
  class GlTFLights

  	 # Initializes instance.
    def initialize

      find_lights

      @lights = {}

    end

    # Returns all lights.
    #
    # @return [Hash] Lights.
    def lights

      @lights_groups.each { |light_group|

        @lights[light_group.object_id] = {}

        @lights[light_group.object_id]['position'] = {

          # Converting inches to meters (* 0.0254).
          'x' => light_group.transformation.origin.x.to_f * 0.0254,
          'y' => light_group.transformation.origin.y.to_f * 0.0254,
          'z' => light_group.transformation.origin.z.to_f * 0.0254

        }

        if light_group.material.respond_to?(:color)

          @lights[light_group.object_id]['color'] = {

            'r' => light_group.material.color.red,
            'g' => light_group.material.color.green,
            'b' => light_group.material.color.blue

          }

        else
          
          # Fallback: light color will be white.
          @lights[light_group.object_id]['color'] = {

            'r' => 255, 'g' => 255, 'b' => 255

          }

        end

      }

      @lights

    end

    # Find all lights.
    #
    # @return [nil]
    private def find_lights

      groups = Sketchup.active_model.entities.grep(Sketchup::Group)

      @lights_groups = groups.find_all{ |group|
        group.layer.name == Light::LAYER_NAME
      }

      nil

    end

  end

end
