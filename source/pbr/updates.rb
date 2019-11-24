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

require 'open-uri'
require 'sketchup'

# PBR plugin namespace.
module PBR

  # Plugin updates.
  module Updates

    # URL of plugin homepage at SketchUcation site.
    SKETCHUCATION_URL = 'https://sketchucation.com/plugin/2101-pbr'.freeze

    # Check for plugin updates.
    #
    # @return [void]
    def self.check

      begin

        sketchucation_html = open(SKETCHUCATION_URL, { read_timeout: 5 }).read

        last_version_array = sketchucation_html.match(/v(\d+\.\d+.\d+)/).to_a

        last_version_int = last_version_array[1].gsub('.', '').to_i

        if VERSION.gsub('.', '').to_i < last_version_int

          UI.messagebox(
            TRANSLATE['A newer version of the PBR plugin is available:']\
              + ' ' + last_version_array[1]
          )

          puts last_version_array[1]

          UI.openURL(SKETCHUCATION_URL)

        end

      rescue StandardError => error
        puts 'Impossible to check if a newer PBR plugin version exists'\
          + ' because: ' + error.to_s
      end

    end

  end

end
