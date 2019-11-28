/**
 * PBR Viewport.
 *
 * @package PBR extension for SketchUp
 *
 * @copyright © 2019 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * PBR plugin namespace.
 */
PBR = {};

/**
 * Render SketchUp active model in a 3D view.
 */
PBR.Viewport = {};

/**
 * Initialize Viewport storage solution.
 *
 * @see https://github.com/localForage/localForage
 */
localforage.config({ name: 'PBR Viewport' });

/**
 * Viewport 3D application.
 *
 * @type {object}
 */
PBR.Viewport.app = null;

/**
 * Viewport configuration.
 *
 * @type {object}
 */
PBR.Viewport.cfg = {};

/**
 * Viewport graphic configuration for basic rendering.
 *
 * @type {object}
 */
PBR.Viewport.cfg.basicGraphics = {

	shadow: true,
	tonemapping: true,
	linear: true
	
};

/**
 * Viewport graphic configuration for advanced rendering.
 *
 * @see https://github.com/pissang/claygl-advanced-renderer/blob/master/src/defaultGraphicConfig.js
 *
 * @type {object}
 */
PBR.Viewport.cfg.advancedGraphics = {
	
	temporalSuperSampling: {
		enable: false
	},

	postEffect: {

		bloom: {
			enable: false
		},

		FXAA: {
			enable: true
		}

	}

};

/**
 * Viewport camera.
 *
 * @type {object}
 */
PBR.Viewport.camera = null;

/**
 * Viewport natural lights.
 *
 * @type {object}
 */
PBR.Viewport.naturalLights = {};

/**
 * Viewport artificial lights.
 *
 * @type {object}
 */
PBR.Viewport.artificialLights = [];

/**
 * Viewport glTF model version.
 *
 * @type {number}
 */
PBR.Viewport.modelVersion = 0;

/**
 * Helper function to convert HTML colors.
 *
 * @see https://css-tricks.com/converting-color-spaces-in-javascript/
 */
PBR.Viewport.rgbToHex = function(r, g, b) {

	r = r.toString(16);
	g = g.toString(16);
	b = b.toString(16);

	if ( r.length == 1 )
		r = "0" + r;

	if ( g.length == 1 )
		g = "0" + g;

	if ( b.length == 1 )
		b = "0" + b;

	return "#" + r + g + b;

};

// Get saved Viewport camera position.
localforage.getItem('cameraPosition').then(function(cameraPosition) {

	// Fallback: the front of model.
	if ( cameraPosition === null ) {

		cameraPosition = [0, 2, -5];

	}

	/**
	 * Create a 3D application that will manage the app initialization and loop.
	 *
	 * @see http://claygl.xyz/
	 */
	PBR.Viewport.app = clay.application.create('#app', {

		// Enable advanced rendering, disable basic one.
		autoRender: false,

		init: function(app) {

			var self = this;

			// Instantiate an adv. renderer.
			this._advancedRenderer = new ClayAdvancedRenderer(
				app.renderer, app.scene, app.timeline, PBR.Viewport.cfg.advancedGraphics
			);

			// Create a perspective camera.
			PBR.Viewport.camera = app.createCamera(cameraPosition, [0, 0, 0]);

			// Plug & use an orbit control.
			this._orbitControl = new clay.plugin.OrbitControl({

				target: PBR.Viewport.camera,
				domElement: app.container,
				panMouseButton: 'left',
				rotateMouseButton: 'middle',
				invertZoomDirection: true,
				zoomSensitivity: 0.3

			});

			// Plug & use a gamepad control.
			this._gamepadControl = new clay.plugin.GamepadControl({
				target: PBR.Viewport.camera
			});

			// Sync controls with renderer.
			this._orbitControl.on('update', function() {
				self._advancedRenderer.render();
			}, self);

			this._gamepadControl.on('update', function() {
				self._advancedRenderer.render();
			}, self);

			// Create an cubemap ambient light and an spherical harmonic ambient
			// light for specular and diffuse lighting in PBR rendering.
			return app.createAmbientCubemapLight('assets/equirectangular.hdr', 0.8, 0.8)
				.then(function (ambientLight){

					PBR.Viewport.naturalLights.diffuse = ambientLight.diffuse;
					PBR.Viewport.naturalLights.specular = ambientLight.specular;

					// Create a directional light.
					PBR.Viewport.naturalLights.direct = app.createDirectionalLight([-1, -1, -1], '#fff', 0.8);
					PBR.Viewport.naturalLights.direct.shadowResolution = 4096;

					// Set HDR background image.
					new clay.plugin.Skybox({
						scene: app.scene,
						environmentMap: ambientLight.environmentMap
					});

					// Load a glTF format model.
					app.loadModel('assets/sketchup-model.gltf', {
						textureConvertToPOT: true
					}).then(function (model) {

						if ( model.json.extras && model.json.extras.lights ) {

							// Turn off natural lights.
							PBR.Viewport.naturalLights.direct.intensity = 0;
							PBR.Viewport.naturalLights.diffuse.intensity = 0;
							PBR.Viewport.naturalLights.specular.intensity = 0;
							document.querySelector('#sunlightIntensity .slider').value = 0;

							for (var lightIndex in model.json.extras.lights) {

								var light = model.json.extras.lights[lightIndex];
				
								// Add artificial light.
								PBR.Viewport.artificialLights.push(app.createPointLight(

									// XXX XYZ to XZ-Y
									new clay.Vector3(light.position.x, light.position.z, -light.position.y),
									100,
									PBR.Viewport.rgbToHex(light.color.r, light.color.g, light.color.b),
									1
									
								));

							}

						}

						for (var materialIndex = 0; materialIndex < model.materials.length; materialIndex++) {

							var clayMaterial = model.materials[materialIndex];
							var glTFMaterial = model.json.materials[materialIndex];

							// Enable alpha test.
							clayMaterial.define('fragment', 'ALPHA_TEST');
							clayMaterial.set('alphaCutoff', 0.6);

							// Set parallax maps.
							if ( glTFMaterial.extras && glTFMaterial.extras.parallaxOcclusionTextureURI ) {

								app.loadTexture(glTFMaterial.extras.parallaxOcclusionTextureURI, {
									convertToPOT: true,
									anisotropic: 16,
									flipY: false
								}).then(function (parallaxOcclusionTexture) {
									clayMaterial.set('parallaxOcclusionMap', parallaxOcclusionTexture);
									clayMaterial.set('parallaxOcclusionScale', 0.05);
									clayMaterial.set('parallaxMinLayers', 50);
									clayMaterial.set('parallaxMaxLayers', 50);
								});

							}

						}

						// Finally displays app canvas so loader animation disappears.
						document.querySelector('#app canvas').style.display = 'block';

				});

			});

		},

		loop: function(app) {

			this._orbitControl.update(app.frameTime);
			this._gamepadControl.update(app.frameTime);

			this._advancedRenderer.render();

		}

	});

});

/**
 * Translate Viewport app strings.
 *
 * @see assets/sketchup-locale.json
 */
PBR.Viewport.translateStrings = function() {

	document.title = sketchUpLocale.document_title;

	var sunlightIntensity = document.getElementById('sunlightIntensity');
	sunlightIntensity.title = sketchUpLocale.sunlight_intensity;

	var helpLink = document.getElementById('helpLink');

	helpLink.href = sketchUpLocale.help_link_href;
	helpLink.textContent = sketchUpLocale.help_link_text;

	var resetCameraPosition = document.getElementById('resetCameraPosition');
	resetCameraPosition.title = sketchUpLocale.reset_cam_position;

};

/**
 * Listen to sunlight intensity change in Viewport.
 */
PBR.Viewport.listenToSunlightChange = function() {

	document.querySelector('#sunlightIntensity .slider').addEventListener('change', function(event) {
		
		PBR.Viewport.naturalLights.direct.intensity = event.target.value;
		PBR.Viewport.naturalLights.diffuse.intensity = event.target.value;
		PBR.Viewport.naturalLights.specular.intensity = event.target.value;

	});

};

/**
 * Viewport "Save Camera Position" interval.
 *
 * @type {number}
 */
PBR.Viewport.scpInterval = 0;

/**
 * Save Viewport camera position.
 */
PBR.Viewport.saveCameraPosition = function() {

	if ( PBR.Viewport.camera === null ) {
		return;
	}

	localforage.setItem('cameraPosition', PBR.Viewport.camera.position.array);

};

/**
 * Set Viewport "Save Camera Position" interval.
 */
PBR.Viewport.setScpInterval = function() {

	PBR.Viewport.scpInterval = window.setInterval(
		PBR.Viewport.saveCameraPosition,
		500
	);

};

/**
 * Reset Viewport camera position.
 */
PBR.Viewport.resetCameraPosition = function() {

	window.clearInterval(PBR.Viewport.scpInterval);

	localforage.removeItem('cameraPosition').then(function(_value) {

		document.location.reload();

	});

};

/**
 * Listen to camera position reset in Viewport.
 */
PBR.Viewport.listenToCameraReset = function() {

	document.querySelector('#resetCameraPosition .emoji')
		.addEventListener('click', PBR.Viewport.resetCameraPosition);

};

/**
 * Set model version from URL parameter?
 */
PBR.Viewport.setModelVersion = function() {

	PBR.Viewport.modelVersion = parseInt(document.location.search.replace(/\D/g, ''));

	if ( isNaN(PBR.Viewport.modelVersion) ) {

		PBR.Viewport.modelVersion = parseInt(Date.now() / 1000);

	}

};

/**
 * Refresh Viewport if a newer version of model is available.
 */
PBR.Viewport.checkForModelUpdates = function() {

	var request = new XMLHttpRequest();

	var lastModelVersion = 0;

	request.addEventListener('load', function(event) {

		lastModelVersion = parseInt(event.target.response);

		if ( PBR.Viewport.modelVersion < lastModelVersion ) {

			// Refresh Viewport.
			document.location.search = 'model_ver=' + lastModelVersion;

		}

	});

	request.open('GET', 'assets/sketchup-model.ver');

	request.send();

};

/**
 * Set Viewport "Check Model Updates" interval.
 */
PBR.Viewport.setCmuInterval = function() {

	window.setInterval(
		PBR.Viewport.checkForModelUpdates,
		1000
	);

};

// When document is ready:
document.addEventListener('DOMContentLoaded', function() {

	PBR.Viewport.setModelVersion();

	PBR.Viewport.translateStrings();

	PBR.Viewport.listenToSunlightChange();

	PBR.Viewport.setScpInterval();

	PBR.Viewport.listenToCameraReset();

	PBR.Viewport.setCmuInterval();

});

// When window is resized:
window.onresize = function() {

	if ( PBR.Viewport.app === null ) {
		return;
	}

	PBR.Viewport.app.resize();

};