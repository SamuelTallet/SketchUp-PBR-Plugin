
SketchUp PBR plugin help
========================

In SketchUp
-----------

### Known issue and workarounds

Issue | Workarounds
:--- | :---
glTF export failed. | ① Retry but when PBR plugin asks: "Propagate materials to whole model?", answer: "Yes". ② Be sure **all** texture images are in JPEG or PNG format. Else, convert them with a tool like [this](https://image.online-convert.com/convert-to-png) then reimport them in SketchUp.

### How to uninstall PBR plugin?

Open Extension Manager. Disable PBR plugin **before** uninstall it.

In PBR Viewport
---------------

### Known issues and workaround

Issue | Workaround
:--- | :---
Texture background is white instead of being transparent. | Open PBR Material Editor ("Extensions" > "Physically-Based Rendering" > "Edit Materials..."). Select material. Set "Alpha mode" to "Combined with background".
Texture is fully opaque whereas I set opacity to *n* %. | With your preferred photo editing software, set opacity **directly** to texture image. Use PNG as exchange format to preserve opacity. Reimport texture image in SketchUp.
Texture looks weird with perpendicular lines around. | With your preferred photo editing software, resize texture image to a [power of two](https://oeis.org/A000079/list) in *h* and *w* (e.g. *1024x2048*, *2048x2048*, *4096x4096*). Reimport texture image in SketchUp.
I don't see last changes done in SketchUp. | Reopen PBR Viewport from SketchUp "Extensions" menu. If problem persists, press <kbd>Ctrl</kbd> + <kbd>F5</kbd> in browser to force the reload.
Pan control doesn't work. | Press <kbd>F11</kbd> to go fullscreen.

### How to control scene camera?

Control scene camera with a mouse or a standard gamepad.

🖱 Pan with **middle click**. Orbit with **left drag**. Zoom with **wheel**.

🎮 Move with **left stick/pad**. Look around with **right stick**.

### How to save render as image?

🖱 **Right click** then **left click** on "Save as image..." menu entry.
