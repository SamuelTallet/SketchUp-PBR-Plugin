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
 * Translates Viewport app strings.
 *
 * @see assets/sketchup-locale.json
 */
PBR.Viewport.translateStrings = function() {

	document.title = sketchUpLocale.document_title;

	document.getElementById('toggleCloudsButton')
		.setAttribute('title', sketchUpLocale.toggle_clouds);

	var helpLink = document.getElementById('helpLink');

	helpLink.href = sketchUpLocale.help_link_href;
	helpLink.textContent = sketchUpLocale.help_link_text;

	document.getElementById('saveAsImageButton')
		.setAttribute('title', sketchUpLocale.save_as_image);

	document.querySelector('.a-enter-vr-button')
		.setAttribute('title', sketchUpLocale.enter_vr_mode);

};

/**
 * Makes environment sky fully spherical.
 */
PBR.Viewport.makeEnvSkyFullySpherical = function() {

	document.querySelector('#environment a-sky').setAttribute('theta-length', 360);

};

/**
 * Toggles environment sky visibility.
 *
 * XXX This function may reveal scene background (clouds in our case).
 */
PBR.Viewport.toggleEnvSkyVisibility = function() {

	var envSky = document.querySelector('#environment a-sky');

	envSky.setAttribute('visible', !envSky.getAttribute('visible'));

};

/**
 * Returns ambient lightness value according to sunlight position...
 *
 * @param {number} sunlightPositionY - Sunlight position Y.
 *
 * @returns {number} Ambient lightness.
 */
PBR.Viewport.guessAmbientLightnessBySunPosY = function(sunlightPositionY) {

	// XXX Arbitrary values.

	var ambientLightness = 0;

		switch (parseFloat(sunlightPositionY).toFixed(1)) {

			case '1.0':
				ambientLightness = 60;
				break;

			case '0.9':
				ambientLightness = 55;
				break;

			case '0.8':
				ambientLightness = 50;
				break;

			case '0.7':
				ambientLightness = 45;
				break;

			case '0.6':
				ambientLightness = 40;
				break;

			case '0.5':
				ambientLightness = 35;
				break;

			case '0.4':
				ambientLightness = 30;
				break;

			case '0.3':
				ambientLightness = 25;
				break;

			case '0.2':
				ambientLightness = 20;
				break;

			case '0.1':
				ambientLightness = 15;
				break;

			case '0.0':
				ambientLightness = 10;
				break;

			case '-0.1':
				ambientLightness = 5;
				break;

		}


	return ambientLightness;

};

/**
 * Defines ambient lightness.
 *
 * @param {number} lightness
 */
PBR.Viewport.setAmbientLightness = function(lightness) {

	var ambientLight = document.getElementById('ambientLight');

	// XXX Arbitrary values.

	var hue = 195;
	var saturation = 5;

	var hslColor = 'hsl(' 
		+ hue + ','
		+ saturation + '%,' 
	 	+ lightness + '%)';

	ambientLight.setAttribute('light', 'color: ' + hslColor);

};

/**
 * Defines environment light position.
 *
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
PBR.Viewport.setEnvLightPosition = function(x, y, z) {

	document.getElementById('environment')
		.setAttribute(
			'environment',
			'lightPosition: ' + x + ' ' + y + ' ' + z
		);

};

/**
 * Returns sunlight position.
 *
 * @returns {Array.<number>}
 */
PBR.Viewport.getSunlightPosition = function() {

	return document.getElementById('sunlight').getAttribute('position');

};

/**
 * Defines sunlight position.
 *
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
PBR.Viewport.setSunlightPosition = function(x, y, z) {

	document.getElementById('sunlight')
		.setAttribute('position', x + ' ' + y + ' ' + z);

};

/**
 * Defines sunlight position Y.
 *
 * @param {number} y
 */
PBR.Viewport.setSunlightPositionY = function(y) {

	var sunlight = document.getElementById('sunlight');

	var sunlightPosition = PBR.Viewport.getSunlightPosition();

	sunlight.setAttribute(
		'position',
		sunlightPosition.x + ' ' +
		y + ' ' +
		sunlightPosition.z
	);

};

/**
 * Switches lights on or off.
 *
 * @param {string} switchPosition
 */
PBR.Viewport.switchLights = function(switchPosition) {

	lightIsVisible = ( switchPosition === 'on' ) ? true : false;

	var lights = document.querySelectorAll('a-entity[light]');

	for (var lightIndex = 0; lightIndex < lights.length; lightIndex++) {

		lights[lightIndex].setAttribute('visible', lightIsVisible);

	}

};

/**
 * Synchronizes lights.
 */
PBR.Viewport.syncLights = function() {

	var sunlightPosition = PBR.Viewport.getSunlightPosition();

	// XXX Because A-Frame environment component draws a sun.
	PBR.Viewport.setEnvLightPosition(
		sunlightPosition.x,
		sunlightPosition.y,
		sunlightPosition.z
	);

	var ambientLightness = PBR.Viewport
		.guessAmbientLightnessBySunPosY(sunlightPosition.y);

	PBR.Viewport.setAmbientLightness(ambientLightness);

	// If sun is above horizon:
	if ( sunlightPosition.y > 0 ) {

		PBR.Viewport.switchLights('on');

	} else {

		PBR.Viewport.switchLights('off');

	}

};

/**
 * Takes a screenshot.
 */
PBR.Viewport.takeScreenshot = function() {

	document.querySelector('a-scene')
		.sceneEl.components.screenshot.capture('perspective');

};

/**
 * Adds event listeners.
 */
PBR.Viewport.addEventListeners = function() {

	document.getElementById('sunElevationSlider')
		.addEventListener('change', function(event) {

			PBR.Viewport.setSunlightPositionY(event.target.value);
			PBR.Viewport.syncLights();
		
	});

	document.getElementById('saveAsImageButton')
		.addEventListener('click', function(_event) {

			PBR.Viewport.takeScreenshot();
		
	});

	document.getElementById('toggleCloudsButton')
		.addEventListener('click', function(_event) {

			PBR.Viewport.toggleEnvSkyVisibility();
		
	});

};

// When document is ready:
document.addEventListener('DOMContentLoaded', function() {

	PBR.Viewport.addEventListeners();

	// TODO Find a more reliable way.
	setTimeout(function(){

		PBR.Viewport.translateStrings();
		PBR.Viewport.makeEnvSkyFullySpherical();

	}, 1000);

});
