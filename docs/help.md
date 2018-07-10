
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
Texture is incorrect. | Reverse (back) face where texture is applied. Paint texture on (front) face.

### How to control scene camera?

Control scene camera with a mouse:

Orbit with **left drag**. Pan with **right drag**. Zoom with **wheel**. Zoom more quickly by **holding middle** button.
