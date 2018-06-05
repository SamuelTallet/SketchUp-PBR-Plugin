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
require 'pbr/model_observer'
require 'pbr/viewport'

# PBR plugin namespace.
module PBR

  # Observes SketchUp events and reacts.
  class AppObserver < Sketchup::AppObserver

    # rubocop: disable MethodName

    # When SketchUp user creates a new, empty model.
    def onNewModel(model)

      model.add_observer(ModelObserver.new)

      # Update and refresh PBR Viewport model.
      Viewport.reopen if Viewport.update_model

    end

    # When SketchUp user opens an existing model:
    def onOpenModel(model)

      model.add_observer(ModelObserver.new)

      # Update and refresh PBR Viewport model.
      Viewport.reopen if Viewport.update_model

    end

    # As soon SketchUp process ends:
    def onQuit

      # Close PBR Viewport.
      Viewport.close

    end

    # rubocop: enable MethodName

  end

end
