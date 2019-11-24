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

  # A light fix... for SketchUp.
  class WcrLightFix

    # Applies fix.
    def initialize

      # Prepares default material.
      Sketchup.active_model.materials.add('Fallback').color = '#fff'\
        if Sketchup.active_model.materials['Fallback'].nil?

      find_all
      
      fix_all

    end

    # Finds lights without color.
    private def find_all

      groups = Sketchup.active_model.entities.grep(Sketchup::Group)

      @lights_groups = groups.find_all{|group|
        group.layer.name == Light::LAYER_NAME
      }

    end

    # Fixes lights without color.
    private def fix_all
  
      @lights_groups.each { |light_group|

        if !light_group.material.respond_to?(:color)

          # Fallback: light color will be white.
          light_group.material = Sketchup.active_model.materials['Fallback']

        end

      }

    end

  end

end
