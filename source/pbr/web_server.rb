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

require 'fileutils'

# PBR plugin namespace.
module PBR

  # A local Web server powered by NGINX.
  # @see https://nginx.org/
  module WebServer

    # Absolute path to document root.
    DOC_ROOT = File.join(__dir__, 'Web Server', 'html').freeze

    # Absolute path to assets dir.
    ASSETS_DIR = File.join(DOC_ROOT, 'assets').freeze

    # URL w/o trailing slash.
    URL = 'http://127.0.0.1:16218'.freeze

    # Starts process.
    #
    # @todo Support macOS?
    #
    # @return [Integer]
    def self.start

      # Start PBR Web server process in parallel to avoid SketchUp blocking.
      Process.spawn('"' + File.join(__dir__, 'web_server.cmd') + '" start')

    end

    # Gives Viewport URL.
    #
    # @return [String]
    def self.viewport_url

      viewport_url = URL + '/viewport.html'

      require 'pbr/github'

      # Viewport translation will be forwarded via URL parameters.
      viewport_url_params = {

        document_title: TRANSLATE['SketchUp PBR Viewport'],
        help_link_href: GitHub.translated_help_url('PBR_VIEWPORT'),
        help_link_text: TRANSLATE['Help']

      }

      require 'uri'

      viewport_url + '?' + URI.encode_www_form(viewport_url_params)

    end

    # Stops process.
    #
    # @todo Support macOS?
    #
    # @return [Boolean]
    def self.stop

      system('"' + File.join(__dir__, 'web_server.cmd') + '" stop')

    end

  end

end
