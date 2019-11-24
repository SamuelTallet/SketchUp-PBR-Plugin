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

  # PBR plugin updates.
  module Updates

    # URL of PBR plugin homepage at SketchUcation website.
    SKETCHUCATION_URL = 'https://sketchucation.com/plugin/2101-pbr'.freeze

    # Returns PBR plugin last version number.
    #
    # @return [String] Last version number.
    def self.last_version

      sketchucation_html = URI.open(
        SKETCHUCATION_URL, :read_timeout => 5
      ).read

      last_version_arr = sketchucation_html.match(/v(\d+\.\d+.\d+)/).to_a

      last_version_arr[1]

    end

    # Alerts user if a new PBR plugin version is available.
    # 
    # @param [String] last_version_str Last version number.
    #
    # @return [void]
    def self.alert_user(last_version_str)

      if VERSION.gsub('.', '').to_i < last_version_str.gsub('.', '').to_i

        UI.messagebox(
          TRANSLATE['A newer version of the PBR plugin is available:']\
            + ' ' + last_version_str
        )

        UI.openURL(SKETCHUCATION_URL)

      end

      nil

    end

    # Checks for plugin updates.
    #
    # @return [void]
    def self.check

      begin

        alert_user(last_version)

      rescue StandardError => exception
        puts 'Impossible to check if a newer PBR plugin version exists'\
          + ' because: ' + exception.to_s
      end

    end

  end

end
