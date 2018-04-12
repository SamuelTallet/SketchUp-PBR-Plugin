PBR extension for SketchUp
==========================

💅 Add reflections and (normal) reliefs to your SketchUp models. 🏃‍♀️ Render in real-time. ✈️ Export to 2D or 3D.

Demos
-----

A SketchUp model rendered `without` PBR extension | Same SketchUp model rendered `with` PBR extension
:--- | :---
![A SketchUp model rendered without PBR extension](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/demos/a-sketchup-model-rendered-without-pbr-extension.png) | ![Same SketchUp model rendered with PBR extension](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/demos/same-sketchup-model-rendered-with-pbr-extension.png)

A virtual reef rendered `with` SketchUp PBR extension. Made with two faces, two materials and three textures.
--- |
![Reef](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/demos/a-virtual-reef-rendered-with-sketchup-pbr-extension.jpg)

A virtual bark rendered `with` SketchUp PBR extension. Made with two cylinders, two materials and three textures.
--- |
![Bark](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/demos/a-virtual-bark-rendered-with-sketchup-pbr-extension.png)

OS support
----------

Windows is supported. macOS is not supported.

Installation
------------

1. Be sure to have SketchUp 2017 or newer version installed.
2. Download required plugin: [glTF Export](https://extensions.sketchup.com/content/gltf-exporter).
3. Download latest PBR plugin in .RBZ format from [Releases](https://github.com/SamuelTS/SketchUp-PBR-Plugin/releases/).
4. Install both plugins following this [guide](https://help.sketchup.com/article/3000263).

Uninstallation
--------------

Remember to disable PBR plugin before uninstall it.

Usage
-----

PBR plugin adds a menu "Physically-Based Rendering" in SketchUp "Extensions" menu. From this new menu, you can:

- **Edit materials**

  - Mouse over question mark ❔ if you need help.

- **Open viewport**

  - Control camera with middle click and left drag.
  - Save render as image with right then left click...

- **Export as 3D object**

Known issues and workaround
---------------------------

Issue in PBR Viewport | Workaround
:--- | :---
Texture background is white instead of being transparent. | Open PBR Material Editor ("Extensions" > "Physically-Based Rendering" > "Edit Materials..."). Select material. Set "Alpha mode" to "Combined with background".
Texture is fully opaque whereas I set opacity to *n* %. | With your preferred photo editing software, set opacity **directly** to texture image. Use PNG as exchange format to preserve opacity. Reimport texture image in SketchUp.
Texture looks weird with perpendicular lines around. | With your preferred photo editing software, resize texture image to a [power of two](https://oeis.org/A000079/list) (e.g. *1024x1024*, *1024x2048*, *2048x2048*, *4096x4096*). Reimport texture image in SketchUp.
Orbit control doesn't obey. | Press <kbd>F11</kbd> to go fullscreen.

Thanks
------

PBR plugin project would not have succeeded without: [SketchUp](https://www.sketchup.com), [glTF](https://www.khronos.org/gltf/), [glTF Export plugin](https://extensions.sketchup.com/content/gltf-exporter), [nginx](https://nginx.org) and [ClayGL library](http://claygl.xyz).

Copyright
---------

© 2018 Samuel Tallet-Sabathé
