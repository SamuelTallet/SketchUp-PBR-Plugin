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

require 'webrick'

# PBR plugin namespace.
module PBR

  # A local Web server to bring closer
  # {https://ruby.sketchup.com/ SketchUp Ruby API} with Web platform.
  class WebServer

    # Starts Web server.
    #
    # @raise [RuntimeError]
    #
    # @return [void]
    def self.start

      server = create_http_server

      raise 'HTTP server not created.' unless server.is_a?(WEBrick::HTTPServer)

      mount_erb_handlers(server)
      mount_gltf_handler(server)

      server.start

    end

    # Returns Web server URL.
    # 
    # @param [String] path An existing path.
    # @raise [ArgumentError]
    #
    # @return [String] Full Web server URL.
    def self.url(path = '/')

      raise ArgumentError, 'Path must be a String.' unless path.is_a?(String)

      "http://127.0.0.1:#{PORT}".concat(path)

    end

    # Port number of Web server.
    PORT = 16_218

    # Document root of Web server.
    DOC_ROOT = File.join(__dir__, 'Web Server Root').freeze

    private_constant :PORT, :DOC_ROOT

    # Creates a WEBrick HTTP server.
    # Web server of PBR plugin relies on this brick.
    #
    # @return [WEBrick::HTTPServer]
    def self.create_http_server

      # For security reasons:

      WEBrick::HTTPServer.new(
        # listen only to local host,
        BindAddress:    '127.0.0.1',

        # do not expose much details,
        ServerSoftware: 'WEBrick',

        Port:            PORT,
        DocumentRoot:    DOC_ROOT,
        DocumentRootOptions: {

          # forbid directory listing.
          FancyIndexing: false

        }
      )

    end

    # Mounts on Web server: path to each HTML doc with embedded Ruby (ERB).
    #
    # @param [WEBrick::HTTPServer] server HTTP server.
    #
    # @return [void]
    def self.mount_erb_handlers(server)

      server.mount(
        '/material-editor',
        WEBrick::HTTPServlet::ERBHandler,
        File.join(DOC_ROOT, 'material-editor.html.erb') # Real path.
      )

      server.mount(
        '/viewport',
        WEBrick::HTTPServlet::ERBHandler,
        File.join(DOC_ROOT, 'viewport.html.erb') # Real path.
      )

    end

    # Mounts on Web server: path to glTF asset handled by glTF servlet.
    # @see PBR::GlTFServlet
    #
    # @param [WEBrick::HTTPServer] server HTTP server.
    #
    # @return [void]
    def self.mount_gltf_handler(server)

      server.mount(
        '/assets/sketchup-model.gltf',
        GlTFServlet,
        DOC_ROOT
      )

    end

    private_class_method :create_http_server,
                         :mount_erb_handlers,
                         :mount_gltf_handler

  end

  # Servlet that delivers glTF asset.
  class GlTFServlet < WEBrick::HTTPServlet::FileHandler

    # rubocop: disable MethodName

    # Handles GET request of glTF asset.
    def do_GET(request, response)

      # rubocop: enable MethodName

      require 'pbr/gltf'

      # Note: Since glTF asset is never cached, it always reflects active model.
      response['Cache-Control'] = 'no-store'

      # Generate glTF asset... That may be long! Depending on model complexity.
      gltf = GlTF.new

      response['Content-Type'] = 'model/gltf+json'
      response['Content-Type'] += '; charset=utf-8'

      # If user requested an export:
      if request.query.key?('export')

        # Name glTF asset with name of active model and force its downloading.
        response['Content-Disposition'] = 'attachment'
        response['Content-Disposition'] += '; filename="' + gltf.filename + '"'
        
      end

      # Send glTF asset contents.
      response.body = gltf.json

    end

  end

end
