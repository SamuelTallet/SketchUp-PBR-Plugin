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
 * Create a 3D application that will manage the app initialization and loop.
 *
 * @see http://claygl.xyz/
 */
PBR.Viewport.app = clay.application.create('#app', {

	// Enable advanced rendering, disable basic one.
	autoRender: false,

	init: function (app) {

		var self = this;

		// Instantiate an adv. renderer.
		this._advancedRenderer = new ClayAdvancedRenderer(
			app.renderer, app.scene, app.timeline, PBR.Viewport.cfg.advancedGraphics
		);

		// Create a perspective camera.
		this._camera = app.createCamera([0, 2, -5], [0, 0, 0]);

		// Plug & use an orbit control.
		this._orbitControl = new clay.plugin.OrbitControl({
			target: this._camera,
			domElement: app.container
		});

		// Plug & use a gamepad control.
		this._gamepadControl = new clay.plugin.GamepadControl({
			target: this._camera
      	});

      	// Sync controls with renderer.
		this._orbitControl.on('update', function() {
			self._advancedRenderer.render();
		}, self);

		this._gamepadControl.on('update', function() {
			self._advancedRenderer.render();
		}, self);

        // Create an cubemap ambient light and an spherical harmonic ambient light for specular and diffuse
        // lighting in PBR rendering.
		return app.createAmbientCubemapLight('assets/equirectangular.hdr', 0.8, 0.8)
			.then(function (ambientLight){

				PBR.Viewport.naturalLights.diffuse = ambientLight.diffuse;
				PBR.Viewport.naturalLights.specular = ambientLight.specular;

				// Create a directional light.
		        PBR.Viewport.naturalLights.direct = app.createDirectionalLight([-1, -1, -1], '#fff', 0.8);
		        PBR.Viewport.naturalLights.direct.shadowResolution = 4096;

				// Set HDR background image.
				var skybox = new clay.plugin.Skybox({
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
		                clayMaterial.set('alphaCutoff', 0.8);

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


				});

			});

	},

	loop: function (app) {

		this._orbitControl.update(app.frameTime);
		this._gamepadControl.update(app.frameTime);
		this._advancedRenderer.render();

	}

});

/**
 * Translate Viewport app strings.
 *
 * @see assets/sketchup-locale.json
 */
PBR.Viewport.translateStrings = function() {

	document.title = sketchUpLocale.document_title;

	var helpLink = document.getElementById('helpLink');

	helpLink.href = sketchUpLocale.help_link_href;
	helpLink.textContent = sketchUpLocale.help_link_text;

};

// When document is ready:
document.addEventListener('DOMContentLoaded', function() {

	PBR.Viewport.translateStrings();

});

// When window is resized:
window.onresize = function() {

	PBR.Viewport.app.resize();

};