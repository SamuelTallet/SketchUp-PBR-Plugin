
Aide de l'extension SketchUp RBP
================================

Dans SketchUp
-------------

### Problème connu et solutions de contournement

Problème | Solutions de contournement
:--- | :---
L'export glTF a échoué. | ① Réessayez mais quand l'extension SketchUp RBP demande : "Propager les matériaux à l'ensemble du modèle ?", répondez : "Oui". ② Assurez-vous que **toutes** les images des textures sont au format JPEG ou PNG. Le cas échéant, convertissez-les avec un outil tel que [celui-ci](https://image.online-convert.com/fr/convertir-en-png) puis réimportez-les dans SketchUp.

### Comment désinstaller l'extension RBP ?

Ouvrez le Gestionnaire d'extensions. Désactivez l'extension RBP **avant** de la désinstaller.

Dans la fenêtre de visualisation RBP
------------------------------------

### Problèmes connus et solution de contournement

Problème | Solution de contournement
:--- | :---
L'arrière-plan de la texture est blanc au lieu d'être transparent. | Ouvrez l'interface de modification des matériaux RBP ("Extensions" > "Rendu basé sur la physique" > "Modifier les matériaux..."). Sélectionnez le matériau. Réglez "Mode alpha" sur "Combiné avec l'arrière-plan".
La texture est complètement opaque alors que j'ai réglé l'opacité sur *n* %. | Avec votre logiciel de retouche photo préféré, réglez l'opacité **directement** sur l'image de la texture. Utilisez le PNG comme format d'échange pour préserver l'opacité. Réimportez l'image de la texture dans SketchUp.
La texture est incorrecte. | Retournez la face (arrière) où la texture est appliquée. Peignez la texture sur la face (avant).

### Comment contrôler la caméra de la scène ?

Contrôlez la caméra de la scène avec une souris :

Orbitez en traînant le **bouton de gauche**. Déplacez-vous en panoramique en traînant le **bouton de droite**. Zoomez avec la **molette**. Zoomez plus rapidement en maintenant le **bouton du milieu**.
