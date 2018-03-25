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
 * Function to call once model loaded in Viewport.
 *
 * @param {object} _result - Unused argument.
 */
PBR.Viewport.onModelLoaded = function(_result) {

	// Remove loading animation.
	document.body.removeChild(
		document.querySelector('.loader')
	);

};

/**
 * PBR Viewport app created thanks to ClayGL library.
 * @see http://docs.claygl.xyz/api/
 *
 * @type {object}
 */
PBR.Viewport.app = clay.application.create('.container', {

	// Graphic configuration:
	graphic: {

		shadow: true,       // Shadows: ON.
		tonemapping: true,  // ACES tone mapping: ON.
		linear: true        // Linear color space: ON.
		
	},

	// Fullscreen: ON.
	width: window.innerWidth,
	height: window.innerHeight,
	devicePixelRatio: window.devicePixelRatio,

	// When initializing app:
	init: function(app) {

		// Create a perspective camera.
		this._camera = app.createCamera(

			[-3, 0, -2],  // Position.
			[0, 0, 0]     // Target.

		);

		// Create a directional light...
		app.createDirectionalLight(

			// from top right to left bottom, away from camera.
			[-1, -1, -1]

		);

		// Create an ambient light.
		app.createAmbientCubemapLight(

			'/assets/pisa.modded.hdr',  // Panorama environment image.
			1,                          // Intensity of specular light.
			1                           // Intensity of diffuse light.

		);

		// Plug-and-use an orbit control.
		this._control = new clay.plugin.OrbitControl({

			// Target of orbit control. Usually, it's a camera.
			target: this._camera,

			// HTMLElement where we need to addEventListener().
			domElement: app.container,

			/**
			 * TODO: Set zoom sensitivity according to units options?
			 * @see http://ruby.sketchup.com/Length.html
			 */
			zoomSensitivity: 0.8

		});

		/*
		 * Load SketchUp model. Return a load promise so
		 * the display will be started after model load...
		 */
		return app.loadModel('/assets/sketchup-model.gltf', {

			waitTextureLoaded: true // all textures included.

		}).then(PBR.Viewport.onModelLoaded);

	},

	// Each render frame:
	loop: function(app) {

		// Update status of orbit control.
		this._control.update(app.frameTime);

	}

});

/**
 * Resizes Viewport app container (canvas)...
 *
 * @param {object} _event - Unused argument.
 */
PBR.Viewport.resizeContainer = function(_event) {

	PBR.Viewport.app.resize(window.innerWidth, window.innerHeight);

};

// each time browser window is resized by user.
window.onresize = PBR.Viewport.resizeContainer;
