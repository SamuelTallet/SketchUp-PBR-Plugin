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
 * @returns {boolean} `true` on success, `false` otherwise.
 */
PBR.Viewport.translate = function() {

	// If browser doesn't support URL API:
	if (typeof URL === 'undefined') {

		alert('Please upgrade your browser to support URL API.');
		return false;

	}

	// Get translation from URL parameters.

	var url = new URL(document.location);

	document.title = url.searchParams.get('document_title');

	var helpLink = document.querySelector('.help-link');

	helpLink.href = url.searchParams.get('help_link_href');
	helpLink.textContent = url.searchParams.get('help_link_text');

	return true;

};

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
 * Function to call once a **standard** gamepad is ready to use.
 *
 * @see https://w3c.github.io/gamepad/#remapping about standard.
 *
 * @param {Gamepad} _gamepad
 */
PBR.Viewport.onStandardGamepadReady = function(_gamepad) {

	document.querySelector('.gamepad').classList.add('is-ready');
	
};

/**
 * Function to call once a gamepad is disconnected.
 *
 * @param {Gamepad} _gamepad
 */
PBR.Viewport.onGamepadDisconnected = function(_gamepad) {

	document.querySelector('.gamepad').classList.remove('is-ready');
	
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

			// Panorama environment image.
			'/assets/cayley_interior_2k.hdr',  
			1, // Intensity of specular light.
			1  // Intensity of diffuse light.

		);

		// Plug-and-use an orbit control.
		this._orbitControl = new clay.plugin.OrbitControl({

			// Scene node to control.
			target: this._camera,

			// DOM element to bind with mouse events.
			domElement: app.container

		});

		// Plug-and-use a gamepad control.
		this._gamepadControl = new clay.plugin.GamepadControl({

			// Scene node to control.
			target: this._camera,

			// Gamepad event handlers.

			onStandardGamepadReady: PBR.Viewport.onStandardGamepadReady,
			onGamepadDisconnected: PBR.Viewport.onGamepadDisconnected

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

		// Update status of controls.
		
		this._orbitControl.update(app.frameTime);
		this._gamepadControl.update(app.frameTime);

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

// When document is ready: translate Viewport.
document.addEventListener('DOMContentLoaded', PBR.Viewport.translate);
