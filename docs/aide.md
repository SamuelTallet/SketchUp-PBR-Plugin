
Aide de l'extension SketchUp RBP
================================

Dans SketchUp
-------------

### Problème connu et solutions de contournement

Problème | Solutions de contournement
:--- | :---
L'export glTF a échoué. | ① Réessayez mais quand l'extension SketchUp RBP demande : "Propager les matériaux à l'ensemble du modèle ?", répondez : "Oui". ② Assurez-vous que **toutes** les images des textures sont au format JPEG ou PNG. Le cas échéant, convertissez-les avec un outil tel que [celui-ci](https://image.online-convert.com/fr/convertir-en-png) puis réimportez-les dans SketchUp.

### Comment ajouter une lumière au modèle ?

1. S'il n'existe pas déjà, créez un nouveau calque et nommez-le **exactement** `PBR Lights`.
2. Ajoutez n'importe quel objet. Ce sera votre lumière. Groupez-le puis affectez-le au calque `PBR Lights`.<br/>
Pour faciliter ce processus, je recommande [Shapes](https://extensions.sketchup.com/fr/content/shapes). Il crée des formes déjà groupées.
3. Rouvrez la fenêtre de visualisation RBP et voilà !

Vous pouvez peindre votre lumière/objet avec une couleur. Vous pouvez ajouter plusieurs lumières au modèle.

### Comment désinstaller l'extension RBP ?

Ouvrez le Gestionnaire d'extensions. Désactivez l'extension RBP **avant** de la désinstaller.

Dans la fenêtre de visualisation RBP
------------------------------------

### Problèmes connus et solution de contournement

Problème | Solution de contournement
:--- | :---
La texture est complètement opaque alors que j'ai réglé l'opacité sur *n* %. | Avec votre logiciel de retouche photo préféré, réglez l'opacité **directement** sur l'image de la texture. Utilisez le PNG comme format d'échange pour préserver l'opacité. Réimportez l'image de la texture dans SketchUp.
La texture est incorrecte. | Retournez la face (arrière) où la texture est appliquée. Peignez la texture sur la face (avant).

### Comment contrôler la caméra de la scène ?

Contrôlez la caméra de la scène avec une souris :

Orbitez en traînant le **bouton de gauche**. Déplacez-vous en panoramique en traînant le **bouton du milieu**. Zoomez avec la **molette**.

Il est également possible de contrôler la caméra avec une manette de jeu standard.

### Comment exporter le rendu vers une image ?

Faites un clic droit n'importe où puis cliquez sur "Enregistrer l'image sous...".
