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

	document.title = SketchUp.locale.document_title;

	var lightExposureControl = document.querySelector('.light-exposure-control');

	lightExposureControl.setAttribute('title', SketchUp.locale.change_exposure);

	var helpLink = document.querySelector('.help-link');

	helpLink.href = SketchUp.locale.help_link_href;
	helpLink.textContent = SketchUp.locale.help_link_text;

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
 * Loads camera position from IndexedDB.
 *
 * @param {function} successCallback
 */
PBR.Viewport.loadCameraPosition = function(successCallback) {

	localforage.getItem(

		'camera_position'

	).then(function(cameraPosition) {
	
		// XXX Default or current.
		cameraPosition = ( cameraPosition === null ) ? [1.5, 0, 0] : cameraPosition;
 
		successCallback(cameraPosition);

	});

};

/**
 * Saves camera position into IndexedDB.
 *
 * @param {Array<Number>} cameraPosition
 */
PBR.Viewport.saveCameraPosition = function(cameraPosition) {

	localforage.setItem('camera_position', cameraPosition);

};

/**
 * Loads light exposure from IndexedDB.
 *
 * @param {function} successCallback
 */
PBR.Viewport.loadLightExposure = function(successCallback) {

	localforage.getItem(

		'light_exposure'

	).then(function(lightExposure) {

		// XXX Default or current.
		lightExposure = ( lightExposure === null ) ? 1.00 : Number(parseFloat(lightExposure).toFixed(2));

		successCallback(lightExposure);

	});

};

/**
 * Saves light exposure into IndexedDB.
 *
 * @param {number|string} lightExposure
 * @param {function} successCallback
 */
PBR.Viewport.saveLightExposure = function(lightExposure, successCallback) {

	localforage.setItem(

		'light_exposure',
		Number(parseFloat(lightExposure).toFixed(2))

	).then(function(_lightExposure) {

		successCallback();

	});

};

/**
 * Shifts light exposure according to a cycle.
 */
PBR.Viewport.shiftLightExposure = function() {

	PBR.Viewport.loadLightExposure(function(lightExposure) {

		// XXX Maximum.
		if ( lightExposure === 1.40 ) {

			// XXX Minimum.
			lightExposure = 0.20;

		} else {

			// XXX Step.
			lightExposure += 0.20;

		}

		PBR.Viewport.saveLightExposure(

			lightExposure,
			PBR.Viewport.update

		);

	});

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
				self._advancedRenderer = new ClayAdvancedRenderer(

					app.renderer,
					app.scene,
					app.timeline,
					PBR.Viewport.cfg.advancedGraphics

				);

			}

			PBR.Viewport.loadCameraPosition(function(cameraPosition) {

				// Create a perspective camera.
				self._camera = app.createCamera(

					cameraPosition,
					[0, 0, 0] // Target.

				);

				PBR.Viewport.loadLightExposure(function(lightExposure) {

					// Create a sunlight with a directional light...
					self._sunlight = app.createDirectionalLight(

						// Direction. FIXME
						[
							SketchUp.sunDir.x * -1,
							SketchUp.sunDir.y,
							-0.9 + SketchUp.sunDir.z * -1
						],
						[lightExposure, lightExposure, lightExposure], // Color.
						lightExposure // Intensity.

					);

					self._sunlight.shadowResolution = 4096;

					// Set an orbit control.
					self._orbitControl = new clay.plugin.OrbitControl({

						// Scene node to control.
						target: self._camera,

						// DOM element to bind with mouse events.
						domElement: app.container,

						timeline: app.timeline

					});

					// Set a gamepad control.
					self._gamepadControl = new clay.plugin.GamepadControl({

						// Scene node to control.
						target: self._camera,

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

						self._orbitControl.on('update', function() {
							self._advancedRenderer.render();
						}, self);

						self._gamepadControl.on('update', function() {
							self._advancedRenderer.render();
						}, self);

					}

					// Create an ambient light from HDRi.
					return app.createAmbientCubemapLight(

						// Panorama environment image.
						'assets/environment-map.hdr',
						lightExposure,	// Intensity of specular light.
						lightExposure,	// Intensity of diffuse light.
						lightExposure 	// Exposure of HDR (pano) image. 

					).then(function(ambientLight) {

						// Wrap scene in a Skybox.
						var _skybox = new clay.plugin.Skybox({
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

				});

			});

		}

	});

};

/**
 * Initializes. XXX This is the start point.
 */
PBR.Viewport.initialize = function() {

	PBR.Viewport.translate();

	localforage.config({
		driver 		: localforage.INDEXEDDB,
		name 		: 'PBR Viewport',
		version 	: 1.0,
		storeName 	: 'pbr_viewport'
	});

	PBR.Viewport.app = PBR.Viewport.createApp();

	// Each time user clicks on light exposure control:
	document.querySelector('.light-exposure-control')
		.addEventListener('click', PBR.Viewport.shiftLightExposure);

	// Each time user resizes browser window:
	window.addEventListener('resize', function(_event) {

		PBR.Viewport.app.resize(window.innerWidth, window.innerHeight);

	});

	// Every 2 seconds:
	window.setInterval(function() {

		PBR.Viewport.saveCameraPosition(
			PBR.Viewport.app.scene.getMainCamera().position.array
		);

	}, 2000);

};

/**
 * Updates to apply last changes.
 */
PBR.Viewport.update = function() {

	// TODO: Find a soft way.
	window.location.reload();

};

// When document is ready:
document.addEventListener('DOMContentLoaded', PBR.Viewport.initialize);