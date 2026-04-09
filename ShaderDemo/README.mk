# Mini Portfolio – Shaders Godot

Voici deux shaders que j'ai codés pour tester des graphismes "cartoon" et des effets visuels inspirés du manga dans Godot.

## 1. PostProcess Shader
- **Objectif** : Appliquer un contour (outline) noir autour de tous les modèles de la scène.
- **Fonctionnement** : Utilise la **depth map** fournie par Godot pour détecter les silhouettes.
- **Effets techniques** :  
  - Outline automatique pour tous les modèles  
  - S’applique à toute l’image (post-process)

## 2. Texture Shader
- **Objectif** : Créer un éclairage cel-shading avec textures animées pour un style manga.  
- **Fonctionnalités** :  
  - Utilisation de **normal maps personnalisées** pour ajouter des détails sans modifier la géométrie  
  - **Rim light** pour accentuer les contours  
  - Tremblement des bords de la silhouette pour un **outline animé**  
  - Textures de hatching légèrement animées sur les zones d’ombre  
  - Répartition des couleurs basée sur une palette de 3 pixels sur 6, avec trois tons d’éclairage par couche  
  - Superposition des couches via des **textures-masks** dessinées

## Résumé
- Programmation shaders GLSL-like dans Godot  
- Techniques de cel-shading et post-processing  
- Gestion de textures et effets animés  
- Stylisation visuelle et rendu cartoon/manga  

## Usage
- Ouvrir dans Godot et assigner textureShader aux modèles (avec toutes les textures qui conviennent et une simple texture blanche pour les couches de couleur vides) et créer un quad collé à la caméra avec postProcess dessus
- Les deux shaders sont indépendants
