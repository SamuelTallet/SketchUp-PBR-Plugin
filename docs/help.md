
SketchUp PBR plugin help
========================

In SketchUp
-----------

### Known issue and workaround

Issue | Workaround
:--- | :---
glTF export failed. | ① Retry but when PBR plugin asks: "Propagate materials to whole model?", say: "Yes". ② Be sure **all** texture images are in JPEG or PNG format. ③ Check if the required [glTF export plugin](https://extensions.sketchup.com/content/gltf-exporter) is installed and enabled.

### How to uninstall PBR plugin?

Open Extension Manager. Disable PBR plugin **before** uninstall it.

In PBR Viewport
---------------

### Known issues and workaround

Issue | Workaround
:--- | :---
Texture background is white instead of being transparent. | Open PBR Material Editor ("Extensions" > "Physically-Based Rendering" > "Edit Materials..."). Select material. Set "Alpha mode" to "Combined with background".
Texture is fully opaque whereas I set opacity to *n* %. | With your preferred photo editing software, set opacity **directly** to texture image. Use PNG as exchange format to preserve opacity. Reimport texture image in SketchUp.
Texture looks weird with perpendicular lines around. | With your preferred photo editing software, resize texture image to a [power of two](https://oeis.org/A000079/list) (e.g. *1024x2048*, *2048x2048*, *4096x4096*). Reimport texture image in SketchUp.
Orbit control doesn't obey. | Press <kbd>F11</kbd> to go fullscreen.

### How to control scene camera?

You can control scene camera with a mouse.

🖱 Pan with **middle click**. Orbit with **left drag**. Zoom with **wheel**.

### How to save render as image?

🖱 **Right click** then **left click** on "Save as image..." menu entry.
