PBR extension for SketchUp
==========================

💅 Add reflections and (normal) reliefs to your SketchUp models. 🏃‍♀️ Render in real-time. ✈️ Export to 2D or 3D.

Demo
----

A SketchUp model rendered `without` PBR extension | Same SketchUp model rendered `with` PBR extension
:--- | :---
![A SketchUp model rendered without PBR extension](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/demos/a-sketchup-model-rendered-without-pbr-extension.png) | ![Same SketchUp model rendered with PBR extension](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/demos/same-sketchup-model-rendered-with-pbr-extension.png)

Installation
------------

1. Download required plugin: [glTF Export](https://extensions.sketchup.com/content/gltf-exporter).
2. Download latest PBR plugin in .RBZ format from [Releases](https://github.com/SamuelTS/SketchUp-PBR-Plugin/releases/).
3. Install both plugins following this [guide](https://help.sketchup.com/article/3000263).

Usage
-----

PBR plugin adds a menu "Physically-Based Rendering" in SketchUp "Extensions" menu. From this new menu, you can:

- **Edit materials**

  - Mouse over question mark icon if you need help.

- **Open viewport**

  - Control camera with middle click and left drag.
  - Save render as image with right then left click.

- **Export as 3D object**

Known issues and workaround
---------------------------

Issue | Workaround
:--- | :---
In PBR Viewport, loading never ends. | Reopen PBR Viewport, accept to "Propagate Materials to Whole Model".
In PBR Viewport, texture looks weird with perpendicular lines all around. | Resize texture image to a [power of two](https://oeis.org/A000079/list) (e.g. *512x512*, *1024x1024*, *2048x2048*, *4096x4096*). Reimport texture image in SketchUp. Reopen PBR Viewport.
In PBR Viewport, model disappears. | Press <kbd>F11</kbd> to go fullscreen. If you want to quit fullscreen, press <kbd>F11</kbd> again.
