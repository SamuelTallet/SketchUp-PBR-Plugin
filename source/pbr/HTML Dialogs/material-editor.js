/**
 * PBR Material Editor.
 *
 * @package PBR extension for SketchUp
 *
 * @copyright © 2018 Samuel Tallet-Sabathé
 *
 * @licence GNU General Public License 3.0
 */

/* jshint browser: true, esversion: 6 */

/**
 * PBR plugin namespace.
 */
PBR = {};

/**
 * Finds elements matching a selector.
 * 
 * XXX Generic. Used as a shorthand.
 * 
 * @param {string} selector - CSS selector.
 *
 * @returns {Array.<object>} HTML elements.
 */
PBR.queryAll = selector => Array.from(document.querySelectorAll(selector));

/**
 * Materials attributes.
 *
 * @type {Array.<object>}
 */
PBR.materials = [];

/**
 * Attributes of selected material.
 *
 * @returns {object}
 */
PBR.selectedMaterial = () => PBR.materials[
	document.getElementById('material-selector').selectedIndex
];

/**
 * Selects value of all "basic" attributes of selected material.
 *
 * @param {object} _event - Unused arg.
 * @param {string} whereKey - Restrict to one attribute (e.g. metallicFactor).
 */
PBR.showMaterialBasicValues = (_event, whereKey = '') => {

	var materialBasicControlsQuery = '.material-basic-control';

	if ( whereKey !== '' ) {
		materialBasicControlsQuery += '[data-key="' + whereKey + '"]';
	}

	var materialBasicControls = PBR.queryAll(materialBasicControlsQuery);

	for (var materialBasicControl of materialBasicControls) {

		materialBasicControl.value =
			PBR.selectedMaterial()[materialBasicControl.dataset.key];

	}

};

/**
 * Updates value of one "basic" attribute of selected material if value is valid.
 *
 * For now, it's internal... Be aware that SketchUp model will be affected later.
 * @see PBR.pushMaterialsThenClose()
 *
 * @param {object} event
 */
PBR.holdMaterialBasicValue = event => {

	var materialBasicControl = event.target;

	if ( (new RegExp(materialBasicControl.dataset.pattern, 'g')).test(materialBasicControl.value) ) {

		PBR.selectedMaterial()[materialBasicControl.dataset.key] =
			materialBasicControl.value;

	}

	// Enforce last-known valid value and synchronize mirrored controls.
	PBR.showMaterialBasicValues(null, materialBasicControl.dataset.key);

};

/**
 * Updates image of material if image type is valid.
 *
 * For now, it's internal... Be aware that SketchUp model will be affected later.
 * @see PBR.pushMaterialsThenClose()
 *
 * @param {object} event
 */
PBR.uploadMaterialImage = event => {

	var materialImageUploader = event.target;

	// Exit now if image upload was canceled by user.
	if ( 0 === materialImageUploader.files.length ) {
		return null;
	}

	var imageFile = new FileReader();

	// XXX Image data will be saved as URI in base64.
	imageFile.readAsDataURL(materialImageUploader.files[0]);

	imageFile.onload = _event => {

		if ( (new RegExp(materialImageUploader.dataset.pattern, 'g')).test(imageFile.result) ) {

			PBR.selectedMaterial()[materialImageUploader.dataset.key] =
				imageFile.result;
			
		} else {
			window.alert(materialImageUploader.dataset.patternMismatch);
		}

	};

};

/**
 * Deletes image of material.
 *
 * For now, it's internal... Be aware that SketchUp model will be affected later.
 * @see PBR.pushMaterialsThenClose()
 *
 * @param {object} event
 */
PBR.removeMaterialImage = event => {

	var materialImageRemoveButton = event.target;

	PBR.selectedMaterial()[materialImageRemoveButton.dataset.key] = 'DELETE_ATTRIBUTE';

	var materialImageUploaderSelector = '.material-image-uploader[data-key="';
	materialImageUploaderSelector += materialImageRemoveButton.dataset.key + '"]';

	// Reset related `input [type=file]` value to visually confirm image was deleted.
	document.querySelector(materialImageUploaderSelector).value = '';

};

/**
 * Sends materials attributes to SketchUp.
 * Then closes PBR Material Editor dialog.
 *
 * @param {object} _event - Unused arg.
 */
PBR.pushMaterialsThenClose = _event => {

	sketchup.pushMaterials(PBR.materials, {

  		onCompleted: sketchup.closeDialog

	});

};

/**
 * Receives materials attributes from SketchUp.
 * Then adds events listeners to UI components.
 */
PBR.pullMaterialsThenListen = () => {

	sketchup.pullMaterials({

		onCompleted: () => {
			
			document.getElementById('material-selector')
				.addEventListener('change', PBR.showMaterialBasicValues);

			// Display first material values.
			PBR.showMaterialBasicValues(null);

			PBR.queryAll('.material-basic-control').forEach(materialBasicControl => {
				materialBasicControl.addEventListener('change', PBR.holdMaterialBasicValue);
			});

			PBR.queryAll('.material-image-uploader').forEach(materialImageUploader => {
				materialImageUploader.addEventListener('change', PBR.uploadMaterialImage);
			});

			PBR.queryAll('.material-image-remove-btn').forEach(materialImageRemoveButton => {
				materialImageRemoveButton.addEventListener('click', PBR.removeMaterialImage);
			});

			document.getElementById('material-apply-button')
				.addEventListener('click', PBR.pushMaterialsThenClose);

		}

	});

};

/**
 * Initializes PBR Material Editor as soon DOM is ready.
 */
document.addEventListener('DOMContentLoaded', _event => {

	if ( typeof sketchup === 'object' ) {

		PBR.pullMaterialsThenListen(); // "Main" UI.
		new Tipfy('[data-tipfy]'); // Tooltips.

	} else {

		window.alert('This script is intended to be run only in a SketchUp HTML dialog.');
		window.location.href = 'About:Blank';//a
		// See: http://streetfighter.wikia.com/wiki/Blanka :D :$ No more joke. Promised! ^^
		
	}

});
