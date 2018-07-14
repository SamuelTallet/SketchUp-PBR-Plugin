// Expose three.js renderer. That's all! :o)
AFRAME.registerComponent('expose-renderer', {

	init: function() {
		PBR.Viewport.renderer = this.el.renderer;
	}

});
