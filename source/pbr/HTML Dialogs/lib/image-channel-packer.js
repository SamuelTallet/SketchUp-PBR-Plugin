/**
 * Image Channel Packer.
 *
 * @copyright © 2018 Samuel Tallet-Sabathé
 *
 * @licence GNU General Public License 3.0
 */

/* jshint browser: true, esversion: 6 */

class ImageChannelPacker {

	/**
	 * Builds an Image Channel Packer.
	 *
	 * @param {string} inputImageSource - Input image source.
	 * @param {?string} outputImageSource - Output image source.
	 * @param {string} imageChannel - Image channel ('red', 'green', 'blue').
	 * @param {function} onComplete - Use this callback to get updated output image source.
	 */
	constructor(inputImageSource, outputImageSource, imageChannel, onComplete) {

		if ( typeof inputImageSource !== 'string' ) {
			throw new TypeError('`inputImageSource` must be a `string`.');
		}

		if ( typeof outputImageSource === 'string' && outputImageSource.length > 0 ) {

			this.outputImageSourceIsAvailable = true;
			
		} else {

			this.outputImageSourceIsAvailable = false;

			// XXX Force image loading with a dummy...
			outputImageSource = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==';

		}

		if ( typeof imageChannel !== 'string' ) {
			throw new TypeError('`imageChannel` must be a `string`.');
		}

		if ( typeof onComplete !== 'function' ) {
			throw new TypeError('`onComplete` must be a `function`.');
		}

		this.inputImage = new Image();

		this.inputImage.onload = _event => {

			this.inputCanvas = document.createElement('canvas');
			this.inputCanvas.width = this.inputImage.width;
			this.inputCanvas.height = this.inputImage.height;

			this.inputCanvasContext = this.inputCanvas.getContext('2d');

			this.inputCanvasContext.drawImage(this.inputImage, 0, 0);

			this.inputImageData = this.inputCanvasContext.getImageData(
				0,
				0,
				this.inputImage.width,
				this.inputImage.height
			);

			this.outputImage = new Image();

			this.outputImage.onload = _event => {

				this.outputCanvas = document.createElement('canvas');
				this.outputCanvas.width = this.inputImage.width;
				this.outputCanvas.height = this.inputImage.height;

				this.outputCanvasContext = this.outputCanvas.getContext('2d');

				if ( this.outputImageSourceIsAvailable ) {

					this.outputCanvasContext.drawImage(this.outputImage, 0, 0);

				}

				this.outputImageData = this.outputCanvasContext.getImageData(
					0,
					0,
					this.inputImage.width,
					this.inputImage.height
				);

				this.imageChannel = imageChannel;

				this.combine_image_data();

				onComplete(this.outputCanvas.toDataURL());

			};

			this.outputImage.src = outputImageSource;

		};

		this.inputImage.src = inputImageSource;

	}

	/**
	 * Combines image data.
	 *
	 * XXX This function updates canvas of output image.
	 */
	combine_image_data() {

		var imageChannelIndex;

		switch (this.imageChannel) {

			case 'red':
				imageChannelIndex = 0;
				break;

			case 'green':
				imageChannelIndex = 1;
				break;

			case 'blue':
				imageChannelIndex = 2;
				break;

		}

		for (var pixelIndex = 0; pixelIndex < this.outputImageData.data.length; pixelIndex += 4) {

			this.outputImageData.data[pixelIndex + imageChannelIndex] =
				this.inputImageData.data[pixelIndex + imageChannelIndex];

			// XXX Force pixel visibility on alpha channel.
			this.outputImageData.data[pixelIndex + 3] = 255;

		}

		this.outputCanvasContext.putImageData(this.outputImageData, 0, 0);

	}

}
