/**
 * PBR Viewport.
 *
 * @package PBR extension for SketchUp
 *
 * @copyright © 2018 Samuel Tallet-Sabathé
 *
 * @licence GNU General Public License 3.0
 */

/* jshint browser: true, esversion: 5 */

/**
 * PBR plugin namespace.
 */
PBR = {};

/**
 * Renders SketchUp active model in a 3D view.
 */
PBR.Viewport = {};

/**
 * Translates Viewport strings.
 *
 * @see locale.json
 */
PBR.Viewport.translate = function() {

	document.title = viewport_locale.document_title;

	var helpLink = document.querySelector('.help-link');

	helpLink.href = viewport_locale.help_link_href;
	helpLink.textContent = viewport_locale.help_link_text;

	viewport_locale = undefined;

};

/**
 * Viewport configuration.
 */
PBR.Viewport.cfg = {};

/**
 * Graphic configuration for basic rendering.
 *
 * @type {object}
 */
PBR.Viewport.cfg.basicGraphics = {

	shadow: true,
	tonemapping: true,
	linear: true
	
};

/**
 * Graphic configuration for advanced rendering.
 *
 * @type {object}
 */
PBR.Viewport.cfg.advancedGraphics = {
	
	temporalSuperSampling: {
		enable: false // FIXME
	},

	postEffect: {

		bloom: {
			enable: false
		},

		screenSpaceAmbientOcclusion: {
			enable: true // FIXME
		},

		FXAA: {
			enable: false // FIXME
		}

	}

};

/**
 * Configuration: Use advanced renderer?
 * 
 * @type {boolean}
 */
PBR.Viewport.cfg.useAdvancedRenderer = false;

/**
 * Viewport pseudo sunlight.
 *
 * @type {object}
 */
PBR.Viewport.pseudoSunlight = null;

/**
 * Viewport ambient light.
 *
 * @type {object}
 */
PBR.Viewport.ambientLight = null;

/**
 * Viewport unified light color.
 *
 * @type {Array}
 */
PBR.Viewport.lightColor = [1.0, 1.0, 1.0];

/**
 * Shifts unified light color of Viewport
 * in order to change light exposure. :-p
 */
PBR.Viewport.shiftLightColor = function() {

	if ( parseInt(PBR.Viewport.lightColor[0]) == 2 ) {

		PBR.Viewport.lightColor = [
			0.1,
			0.1,
			0.1
		]

	} else {

		PBR.Viewport.lightColor = [
			PBR.Viewport.lightColor[0] += 0.1,
			PBR.Viewport.lightColor[1] += 0.1,
			PBR.Viewport.lightColor[2] += 0.1
		]

	}

	// Update all lights.

	PBR.Viewport.pseudoSunlight.color = PBR.Viewport.lightColor;

	PBR.Viewport.ambientLight.diffuse.color = PBR.Viewport.lightColor;
	PBR.Viewport.ambientLight.specular.color = PBR.Viewport.lightColor;
	PBR.Viewport.ambientLight.environmentMap.exposure = PBR.Viewport.lightColor[0]; // FIXME

};

/**
 * Viewport app.
 *
 * @type {object}
 */
PBR.Viewport.app = null;

/**
 * Creates Viewport app thanks to ClayGL library.
 * @see http://docs.claygl.xyz/api/
 *
 * @returns {object}
 */
PBR.Viewport.createApp = function() {

	return clay.application.create('.container', {

		// Set fullscreen.
		width: window.innerWidth,
		height: window.innerHeight,

		devicePixelRatio: window.devicePixelRatio,

		graphic: PBR.Viewport.cfg.basicGraphics,

		// Use basic (auto) renderer instead of advanced renderer?
		autoRender: !PBR.Viewport.cfg.useAdvancedRenderer,

		// When initializing app:
		init: function(app) {

			var self = this;

			if (PBR.Viewport.cfg.useAdvancedRenderer) {

				// Instantiate an advanced renderer.
				this._advancedRenderer = new ClayAdvancedRenderer(

					app.renderer,
					app.scene,
					app.timeline,
					PBR.Viewport.cfg.advancedGraphics

				);

			}

			// Create a perspective camera.
			this._camera = app.createCamera(

				[5, 0, 0],	// Position.
				[0, 0, 0]	// Target.

			);

			// Create a directional light...
			this._light = app.createDirectionalLight(

				// from top right to left bottom, away from camera.
				[-1, -1, -1]

			);

			this._light.shadowResolution = 2048;

			PBR.Viewport.pseudoSunlight = this._light;

			// Set an orbit control.
			this._orbitControl = new clay.plugin.OrbitControl({

				// Scene node to control.
				target: this._camera,

				// DOM element to bind with mouse events.
				domElement: app.container,

				timeline: app.timeline

			});

			// Set a gamepad control.
			this._gamepadControl = new clay.plugin.GamepadControl({

				// Scene node to control.
				target: this._camera,

				timeline: app.timeline,

				// Gamepad event handlers.

				onStandardGamepadReady: function(_gamepad) {
					document.querySelector('.gamepad')
						.classList.add('is-ready');
				},

				onGamepadDisconnected: function(_gamepad) {
					document.querySelector('.gamepad')
						.classList.remove('is-ready');
				}

			});

			if (PBR.Viewport.cfg.useAdvancedRenderer) {

				// Sync controls with advanced rendering.

				this._orbitControl.on('update', function() {
					self._advancedRenderer.render();
				}, this);

				this._gamepadControl.on('update', function() {
					self._advancedRenderer.render();
				}, this);

			}

			// Create an ambient light.
			return app.createAmbientCubemapLight(

				// Panorama environment image.
				'assets/environment-map.hdr',  
				1,	// Intensity of specular light.
				1,	// Intensity of diffuse light.
				0.8	// Exposure of HDR image.

			).then(function(ambientLight) {

				PBR.Viewport.ambientLight = ambientLight;

				// Wrap scene in a Skybox.
				var skybox = new clay.plugin.Skybox({
					scene: app.scene,
					environmentMap: ambientLight.environmentMap
				});

				// Load SketchUp model.
				app.loadModel('assets/sketchup-model.gltf', {

					waitTextureLoaded: true

				}).then(function(_model) {

					// Remove loading animation.
					document.body.removeChild(
						document.querySelector('.loader')
					);

					if (PBR.Viewport.cfg.useAdvancedRenderer) {

						// Render with advanced graphics.
						self._advancedRenderer.render();

					}

				});

			});

		}

	});

};

// When document is ready:
document.addEventListener('DOMContentLoaded', function() {

	PBR.Viewport.translate();

	PBR.Viewport.app = PBR.Viewport.createApp();

	// On exposure control click:
	document.querySelector('.exposure-control')
		.addEventListener('click', PBR.Viewport.shiftLightColor);

	// Each time browser window is resized by user:
	window.addEventListener('resize', function(_event) {

		PBR.Viewport.app.resize(window.innerWidth, window.innerHeight);

	});

});
