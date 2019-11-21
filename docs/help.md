
SketchUp PBR plugin help
========================

In SketchUp
-----------

### Known issue and workarounds

Issue | Workarounds
:--- | :---
glTF export failed. | ① Retry but when PBR plugin asks: "Propagate materials to whole model?", answer: "Yes". ② Be sure **all** texture images are in JPEG or PNG format. Else, convert them with a tool like [this](https://image.online-convert.com/convert-to-png) then reimport them in SketchUp.

### How to add a light to model?

1. If it's not already exists, create a new layer and name it **exactly** `PBR Lights`.
2. Add any object. It will be your light. Group it then assign it to layer `PBR Lights`.<br/>
To ease this process, I recommand [Shapes](https://extensions.sketchup.com/content/shapes). It creates already grouped shapes. 
3. Reopen PBR Viewport and voilà!

You can paint your light/object with a color. You can add many lights to model.

### How to uninstall PBR plugin?

Open Extension Manager. Disable PBR plugin **before** uninstall it.

In PBR Viewport
---------------

### Known issues and workaround

Issue | Workaround
:--- | :---
Texture is fully opaque whereas I set opacity to *n* %. | With your preferred photo editing software, set opacity **directly** to texture image. Use PNG as exchange format to preserve opacity. Reimport texture image in SketchUp.
Texture is incorrect. | Reverse (back) face where texture is applied. Paint texture on (front) face.

### How to control scene camera?

Control scene camera with a mouse:

Orbit with **left drag**. Pan with **middle drag**. Zoom with **wheel**.

It's also possible to control camera with a standard gamepad.

### How to export render to an image?

Do a right click anywhere then click on "Save image as ...".
