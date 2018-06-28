
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
Texture looks weird with perpendicular lines around. | With your preferred photo editing software, resize texture image to a [power of 2](https://oeis.org/A000079/list) in *height* and *width* (e.g. *1024x2048*, *2048x2048*, *4096x4096*). Reimport texture image in SketchUp.
Texture is incorrect. | Reverse (back) face where texture is applied. Paint texture on (front) face.
I don't see last changes done in SketchUp. | Refresh Web browser page. If problem persists, clear Web browser cache.

### How to control scene camera?

Control scene camera with a mouse: Pan with **middle click**. Orbit with **left drag**. Zoom with **wheel**.
