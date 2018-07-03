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
 * An operations is in progress?
 *
 * @type {boolean}
 */
PBR.anOperationIsInProgress = false;

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
	document.getElementById('material-selector').value
];

/**
 * Selects value of all "basic" attributes of selected material.
 *
 * @param {object} _event - Unused argument.
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
 * Indicates status of all texture images of selected material.
 *
 * @param {object} _event - Unused argument.
 */
PBR.checkMaterialImagesStatus = _event => {

	PBR.queryAll('.material-image-status').forEach(materialImageStatus => {

		var materialImage = PBR.selectedMaterial()[materialImageStatus.dataset.key];

		// Check box if texture image is defined.
		materialImageStatus.checked = ( typeof materialImage === 'string' );

		if ( materialImageStatus.checked === true && materialImageStatus.dataset.factorControlKey ) {

			PBR.queryAll(
				'.material-factor-control[data-key="' + materialImageStatus.dataset.factorControlKey + '"]'
			).forEach(materialFactorControl => {

				// Force max. value of corresponding factor if texture image is defined.
				materialFactorControl.value = materialFactorControl.getAttribute('max');

			});

		}

	});

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

			// If image needs to be packed into a channel. e.g. Metallic map is packed in blue channel.
			if ( typeof materialImageUploader.dataset.channel === 'string' ) {

				new ImageChannelPacker(

					imageFile.result, // inputImageSource
					PBR.selectedMaterial()[materialImageUploader.dataset.key], // outputImageSource
					materialImageUploader.dataset.channel, // imageChannel
					function(outputImageSource) { // onComplete

						PBR.selectedMaterial()[materialImageUploader.dataset.key] = outputImageSource;
						PBR.checkMaterialImagesStatus(null);

						// XXX Asynchronous operation ended.
						PBR.anOperationIsInProgress = false;

					}

				);

				PBR.anOperationIsInProgress = true;

			} else {

				PBR.selectedMaterial()[materialImageUploader.dataset.key] =
					imageFile.result;

				PBR.checkMaterialImagesStatus(null);

			}

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

	PBR.selectedMaterial()[materialImageRemoveButton.dataset.key] = false;

	PBR.checkMaterialImagesStatus(null);

};

/**
 * Sends materials attributes to SketchUp.
 * Then closes PBR Material Editor dialog.
 *
 * @param {object} _event - Unused argument.
 *
 * @returns {void} if another operation is in progress.
 */
PBR.pushMaterialsThenClose = event => {

	if ( PBR.anOperationIsInProgress ) {

		window.alert(event.target.dataset.opInProgress);
		return;

	}

	sketchup.pushMaterials(PBR.materials, {

  		onCompleted: sketchup.closeDialog

	});

};

/**
 * Receives materials attributes from SketchUp.
 * Then adds events listeners to PBR Material Editor UI.
 */
PBR.pullMaterialsThenListen = () => {

	sketchup.pullMaterials({

		onCompleted: () => {
			
			document.getElementById('material-selector')
				.addEventListener('change', PBR.showMaterialBasicValues);

			document.getElementById('material-selector')
				.addEventListener('change', PBR.checkMaterialImagesStatus);

			// Display first material values.
			PBR.showMaterialBasicValues(null);

			// Check first material images status.
			PBR.checkMaterialImagesStatus(null);

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
 * Initializes PBR Material Editor UI as soon DOM is ready.
 */
document.addEventListener('DOMContentLoaded', _event => {

	if ( typeof sketchup === 'object' ) {

		PBR.pullMaterialsThenListen();
		new Tipfy('.tooltip');

	} else {

		window.alert('This script is intended to be run only in a SketchUp HTML dialog.');
		window.location.href = 'About:Blank';//a
		// See: http://streetfighter.wikia.com/wiki/Blanka :D :$ No more joke. Promised! ^^
		
	}

});
