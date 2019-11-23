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
require 'fileutils'
require 'json'

# PBR plugin namespace.
module PBR

  # A simple wrapper for the Chromium Web browser.
  module Chromium

    # Absolute path to Chromium browsers folder.
    DIR = File.join(__dir__, 'Chromium').freeze

    # Returns absolute path to Chromium executable.
    #
    # @return [String]
    def self.executable

      if Sketchup.platform == :platform_osx
        File.join(DIR, 'Mac', 'Chromium.app', 'Contents', 'MacOS', 'Chromium')
      else
        File.join(DIR, 'Win', 'chrome.exe')
      end

    end

    # Makes Chromium executable.
    #
    # Note: Only useful on Mac.
    def self.make_exec

      FileUtils.chmod('+x', executable) if Sketchup.platform == :platform_osx
      
    end

    # Returns absolute path to Chromium Preferences file.
    #
    # @return [String]
    def self.preferences

      if Sketchup.platform == :platform_osx
        File.join('~', 'Library', 'Application Support', 'Chromium', 'Default', 'Preferences')
      else
        File.join(ENV['LOCALAPPDATA'], 'Chromium', 'User Data', 'Default', 'Preferences')
      end

    end

    # Simulate a normal exit to prevent display of this error message:
    # Chrome was not shut down properly.
    # 
    # @return [void]
    def self.simulate_normal_exit

      return unless File.exist?(preferences)

      prefs_json = JSON.parse(File.read(preferences))

      prefs_json['profile']['exit_type'] = 'Normal'
      prefs_json['profile']['exited_cleanly'] = true

      File.write(preferences, JSON.fast_generate(prefs_json))

      nil

    end

  end

end
