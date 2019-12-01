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

# PBR plugin namespace.
module PBR

  # A "nil material" fix for SketchUp.
  class NilMaterialFix

      # Traverses active model tree to fix faces having "nil material" issue.
      def initialize

        create_fallback_material

        # Starts model tree traversal...
        traverse(Sketchup.active_model)

      end

      # Creates a fallback material unless it already exists.
      #
      # @note Don't confuse fallback material with default material.
      # Fallback material is not nil, while default material is nil.
      #
      # @return [nil]
      private def create_fallback_material

      	@model = Sketchup.active_model

        @material_name = 'Fallback'

        @model.materials.add(@material_name).color = '#fff'\
          if @model.materials[@material_name].nil?

        nil

      end

      # Fixes faces materials at same time model is traversed, recursively...
      #
      # @param [Sketchup::Entity] entity
      #
      # @return [nil]
      private def traverse(entity)

        fix_face_material(entity)

        # Takes another model branch depending on entity type. Thanks Aerilius.
        # See: https://github.com/Aerilius If you want to know who is Aerilius.

        if entity.is_a?(Sketchup::Group)\
         || entity.is_a?(Sketchup::ComponentInstance)

          entity.definition.entities.each { |sub_entity| traverse(sub_entity) }

        elsif entity.is_a?(Sketchup::Model)

          entity.entities.each { |sub_entity| traverse(sub_entity) }

        end

        nil
      
      end

      # Fixes face material in two steps.
      #
      # @param [Sketchup::Entity] entity
      #
      # @return [void]
      private def fix_face_material(entity)

        # Escape if entity cannot have a material.
        return unless entity.respond_to?(:material=)

        # If entity has no material at its level and is a face:
        if (entity.material.nil? || !entity.respond_to?(:back_material))\
          && entity.is_a?(Sketchup::Face)

          # 2. Apply directly to face last encountered reference material!
          
          if entity.material.nil?
          	entity.material = @model.materials[@material_name]
          end

          if !entity.respond_to?(:back_material)
          	entity.back_material = @model.materials[@material_name]
          end

          # By the way, copies material from front face to back face.

          if entity.material != entity.back_material
            entity.back_material = entity.material
          end

        # Else, if entity has a material at its level:
        elsif entity.material.is_a?(Sketchup::Material)

          # 1. Memorize new reference material.
          @material_name = entity.material.name

        end

      end

  end

end
