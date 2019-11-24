# Copyright 2014 Trimble Navigation Ltd.
# Copyright 2019 Samuel Tallet

# License: The MIT License (MIT)

# PBR plugin namespace.
module PBR

  # Helper module to create shapes.
  module Shapes

    # Create a mix-in module that can be used to extend Geom::PolygonMesh
    # instances. These methods used to previously modify the base classes
    # themselves.
    module PolygonMeshHelper

      # Revolve edges defined by an array of points about an axis
      # pts is an Array of points
      # axis is an Array with a point and a vector
      # numsegments is the number of segments in the rotaion direction
      def add_revolved_points(pts, axis, numsegments)

        # Make sure that there are enough points
        numpts = pts.length
        if( numpts < 2 )
          raise ArgumentError, "At least two points required", caller
        end

        #TODO: Determine if the points are all in the same plane as the axis
        planar = true

        # Create a transformation that will revolve the points
        angle = Math::PI * 2
        da = angle / numsegments
        t = Geom::Transformation.rotation(axis[0], axis[1], da)

        # Add the points to the mesh
        index_array = []
        for pt in pts do
          if( pt.on_line?(axis) )
            index_array.push( [self.add_point(pt)] )
          else
            indices = []
            for i in 0...numsegments do
              indices.push( self.add_point(pt) )
              #puts "add #{pt} at #{indices.last}"
              pt.transform!(t)
            end
            index_array.push indices
          end
        end

        # Now create polygons using the point indices
        i1 = index_array[0]
        for i in 1...numpts do
          i2 = index_array[i]
          n1 = i1.length
          n2 = i2.length
          nest if( n1 < numsegments && n2 < numsegments )

          for j in 0...numsegments do
            jp1 = (j + 1) % numsegments
            if( n1 < numsegments )
              self.add_polygon i1[0], i2[jp1], i2[j]
              #puts "add_poly #{i1[0]}, #{i2[jp1]}, #{i2[j]}"
            elsif( n2 < numsegments )
              self.add_polygon i1[j], i1[jp1], i2[0]
              #puts "add_poly #{i1[j]}, #{i1[jp1]}, #{i2[0]}"
            else
              if( planar )
                self.add_polygon i1[j], i1[jp1], i2[jp1], i2[j]
              else
                # Try adding two triangles instead
                self.add_polygon i1[j], i1[jp1], i2[jp1]
                self.add_polygon i1[j], i2[jp1], i2[j]
              end
              #puts "add_poly #{i1[j]}, #{i1[jp1]}, #{i2[jp1]}, #{i2[j]}"
            end
          end

          i1 = i2
        end

      end

      # Extrude points along an axis with a rotation
      def add_extruded_points(pts, center, dir, angle, numsegments)

        # Make sure that there are enough points
        numpts = pts.length
        if( numpts < 2 )
          raise ArgumentError, "At least two points required", caller
        end

        # compute the transformation
        vec = Geom::Vector3d.new dir
        distance = vec.length
        dz = distance / numsegments
        da = angle / numsegments
        vec.length = dz
        t = Geom::Transformation.translation vec
        r = Geom::Transformation.rotation center, dir, da
        tform = t * r

        # Add the points to the mesh
        index_array = []
        for i in 0...numsegments do
          indices = []
          for pt in pts do
            indices.push( self.add_point(pt) )
            pt.transform!(tform)
          end
          index_array.push indices
        end

        # Now create polygons using the point indices
        i1 = index_array[0]
        for i in 1...numsegments do
          i2 = index_array[i]

          for j in 0...numpts do
            k = (j+1) % numpts
            self.add_polygon -i1[j], i2[k], -i1[k]
            self.add_polygon i1[j], -i2[j], -i2[k]
          end

          i1 = i2
        end

      end

    end

    # Create a sphere. 
    #
    # @param [String] radius Radius. Example: '1m'.
    # @param [Integer] n90 Segments per 90 degrees. Default: 10.
    # @param [Integer] smooth Smooth parameter. Default: 12.
    # @param [Integer|String] layer_idx_or_name Layer index or name. Default: 0.
    #
    # @return [Sketchup::Group] Group that contains sphere.
    def self.create_sphere(radius, n90 = 10, smooth = 12, layer_idx_or_name = 0)

      group = Sketchup.active_model.entities.add_group

      # Convert radius.
      radius = radius.to_l

      # Compute a half circle.
      arcpts = []
      delta = 90.degrees/n90
      for i in -n90..n90 do
        angle = delta * i
        cosa = Math.cos(angle)
        sina = Math.sin(angle)
        arcpts.push(Geom::Point3d.new(radius*cosa, 0, radius*sina))
      end

      # Create a mesh and revolve the half circle.
      numpoly = n90*n90*4
      numpts = numpoly + 1
      mesh = Geom::PolygonMesh.new(numpts, numpoly)
      mesh.extend(PolygonMeshHelper)
      mesh.add_revolved_points(arcpts, [ORIGIN, Z_AXIS], n90*4)

      # Create faces from the mesh.
      group.entities.add_faces_from_mesh(mesh, smooth)

      # Assign group to layer.
      group.layer = Sketchup.active_model.layers[layer_idx_or_name]

      group

    end

  end

end
