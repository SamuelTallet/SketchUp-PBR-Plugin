
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
La texture semble bizarre avec des lignes perpendiculaires autour. | Avec votre logiciel de retouche photo préféré, redimensionnez l'image de la texture à une [puissance de deux](https://oeis.org/A000079/list) en *hauteur* et en *largeur* (par ex. *1024x2048*, *2048x2048*, *4096x4096*). Réimportez l'image de la texture dans SketchUp.
Le contrôle panoramique ne fonctionne pas. | Appuyez sur <kbd>F11</kbd> pour passer en mode plein écran.

### Comment contrôler la caméra de la scène ?

Contrôlez la caméra de la scène avec une souris ou une manette de jeu standard.

🖱 Déplacez-vous en panoramique avec le **bouton du milieu**. Orbitez en traînant le **bouton gauche**. Zoomez avec la **molette**.

🎮 Déplacez-vous avec le **stick/pad gauche**. Regardez autour de vous avec le **stick droit**.

### Comment enregistrer le rendu en tant qu'image ?

🖱 **Clic droit** puis **clic gauche** sur l'entrée de menu "Enregistrer l'image sous...".
