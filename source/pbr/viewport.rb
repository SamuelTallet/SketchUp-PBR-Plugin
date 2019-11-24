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
require 'pbr/gltf'
require 'pbr/github'
require 'pbr/chromium'
require 'pbr/menu'

# PBR plugin namespace.
module PBR

  # Display SketchUp model in Web browser.
  module Viewport

    # Absolute path to application root.
    ROOT = File.join(__dir__, 'Viewport App').freeze

    # Absolute path to assets directory.
    ASSETS_DIR = File.join(ROOT, 'assets').freeze

    # Changes HDR Background.
    #
    # @return [nil]
    def self.change_hdr_bg

      user_path = UI.openpanel TRANSLATE['Select New Background'], nil,\
        TRANSLATE['HDR Image'] + '|*.hdr||'

      # Escape if user cancelled operation.
      return if user_path.nil?

      FileUtils.cp(user_path, File.join(ASSETS_DIR, 'equirectangular.hdr'))

      reopen

      nil

    end

    # Updates Viewport glTF model asset.
    #
    # TODO: Incremential update.
    #
    # @return [Boolean] true on success...
    def self.update_model

      gltf_path = File.join(ASSETS_DIR, 'sketchup-model.gltf')

      gltf = GlTF.new

      # Overwrite glTF model. So, Viewport will display an up-to-date model.
      File.write(gltf_path, gltf.json) if gltf.valid?

      gltf.valid?

    end

    # Translates Viewport strings.
    #
    # @return [nil]
    def self.translate

      locale_path = File.join(ASSETS_DIR, 'sketchup-locale.json')

      localization = {
        document_title: TRANSLATE['SketchUp PBR Viewport'],
        sunlight_intensity: TRANSLATE['Sunlight intensity'],
        help_link_href: GitHub.translated_help_url('PBR_VIEWPORT'),
        help_link_text: TRANSLATE['Help'],
        reset_cam_position: TRANSLATE['Reset camera position']
      }

      File.write(locale_path, 'sketchUpLocale = ' + localization.to_json + ';')

      nil

    end

    # Opens Viewport Chromium window.
    #
    # @return [Numeric] Viewport process ID.
    def self.open

      Chromium.make_exec

      SESSION[:viewport_pid] = Process.spawn(

        Chromium.executable,

        File.join(ROOT, 'viewport.html'),

        # See: https://peter.sh/experiments/chromium-command-line-switches/
        '--allow-file-access-from-files',
        '--disable-infobars'

      )

      rescue StandardError => _exception
        UI.messagebox("Unable to find: \"#{Chromium.executable}\". Get latest.")

    end

    # Closes Viewport Chromium window.
    #
    # @return [Boolean] true on success...
    def self.close

      Process.kill('KILL', SESSION[:viewport_pid])
      Chromium.simulate_normal_exit
      true
      
      rescue StandardError => _exception
        false

    end

    # Reopens Viewport Chromium window.
    #
    # @return [Numeric] Viewport process ID.
    def self.reopen

      close
      
      open

    end

    # Reopens Viewport if model updated.
    #
    # @return [nil]
    def self.reopen_if_model_updated

      return Menu.propose_help(
        TRANSLATE['glTF export failed. Do you want help?']
      ) unless update_model

      reopen

    end

  end

end
