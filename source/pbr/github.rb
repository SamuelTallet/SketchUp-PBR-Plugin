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

# PBR plugin namespace.
module PBR

  # Things related to GitHub. Thanks to GitHub for their hosting ;)
  module GitHub

    # Homepage URL w/o trailing slash.
    URL = 'https://github.com/SamuelTS/SketchUp-PBR-Plugin'.freeze

    # Gives Help URL, maybe translated.
    #
    # @param [String] context Context.
    # @raise [ArgumentError]
    #
    # @return [String]
    def self.translated_help_url(context)

      raise ArgumentError, 'Invalid context.' unless context.is_a?(String)\
        && context =~ /^(PBR_VIEWPORT|SKETCHUP)$/

      help_url = URL + '/blob/master/docs/'

      if context == 'PBR_VIEWPORT'

        help_url += TRANSLATE['help.md#in-pbr-viewport']

      elsif context == 'SKETCHUP'

        help_url += TRANSLATE['help.md#in-sketchup']

      end
      
      help_url

    end

  end

end
