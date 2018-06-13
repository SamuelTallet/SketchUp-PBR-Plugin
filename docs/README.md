<a href="https://github.com/SamuelTS/SketchUp-PBR-Plugin/blob/master/docs/LISEZMOI.md">Version française <img height="16" width="16" src="https://emojipedia-us.s3.amazonaws.com/thumbs/60/google/119/flag-for-france_1f1eb-1f1f7.png"></a>

PBR extension for SketchUp
==========================

💅 Add reflections and (normal) reliefs to your SketchUp models. 🏃‍♀️ Render in real-time. ✈️ Export to 2D or 3D.

Demos
-----

A SketchUp model rendered `without` PBR extension | Same SketchUp model rendered `with` PBR extension
:--- | :---
![A SketchUp model rendered without PBR extension](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/docs/demos/a-sketchup-model-rendered-without-pbr-extension.png) | ![Same SketchUp model rendered with PBR extension](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/docs/demos/same-sketchup-model-rendered-with-pbr-extension.png)

A virtual reef rendered `with` SketchUp PBR extension. Made with two faces, two materials and three textures.
--- |
![Reef](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/docs/demos/a-virtual-reef-rendered-with-sketchup-pbr-extension.jpg)

A futuristic shuttle rendered `with` SketchUp PBR extension. Photo credit: ESO/P. Horálek. Model credit: 3DHaupt.
--- |
![Futuristic shuttle](https://github.com/SamuelTS/SketchUp-PBR-Plugin/raw/master/docs/demos/a-futuristic-shuttle-rendered-with-sketchup-pbr-extension.jpg)

Installation
------------

1. Be sure to have SketchUp 2017 or newer version installed.
2. Download required plugin: [glTF Export](https://extensions.sketchup.com/content/gltf-exporter).
3. Download latest PBR plugin in .RBZ format from [Releases](https://github.com/SamuelTS/SketchUp-PBR-Plugin/releases/).
4. Install both plugins following this [guide](https://help.sketchup.com/article/3000263).
5. Restart SketchUp.

Now, you should have a "Physically-Based Rendering" menu in SketchUp "Extensions" menu. 👍
From this new menu, you can: "Edit Materials", "Change Env. Map", "Reopen Viewport"  and "Export As 3D Object".

Additionally, you should have a new "PBR" materials collection in "Materials" tray. Enjoy! 😊

Workflow
--------

PBR Viewport updates **automatically** when:

- You open or create an empty SketchUp model,
- You apply changes in PBR Material Editor,
- You change environment map from PBR menu.

But you may want update **manually** PBR Viewport. To do so, I recommend you to [map a keyboard shortcut](https://help.sketchup.com/article/3000232) to menu entry: "Extensions" > "Physically-Based Rendering" > "Reopen Viewport".

Documentation
-------------

A [help document](https://github.com/SamuelTS/SketchUp-PBR-Plugin/blob/master/docs/help.md) is available.

Thanks
------

PBR plugin project would not have succeeded without: [SketchUp](https://www.sketchup.com), [glTF](https://www.khronos.org/gltf/), [glTF Exporter](https://extensions.sketchup.com/content/gltf-exporter), [Chromium](https://www.chromium.org/), [ClayGL](http://claygl.xyz) et [localForage](https://localforage.github.io/localForage/).

Copyright
---------

© 2018 Samuel Tallet-Sabathé
