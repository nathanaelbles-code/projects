# State Machine – Plateformer 2D Godot

Cette state machine gère les déplacements d’un personnage dans un jeu de plateforme 2D réalisé avec Godot.

## Objectif
Permettre la gestion claire et modulaire des différents états du personnage (ex: idle, run, jump, fall), et faciliter les transitions entre eux.

## Fonctionnement
- La classe **StateMachine** est attachée à un Node principal.  
- Chaque état possible du personnage est représenté par un **enfant** du Node, dérivé de la classe **StateClass**.  
- La StateMachine exécute automatiquement des fonctions inhérentes à chaque état, par exemple :
  - **transitions()** : vérifie les conditions de changement d’état  
    - Retourne `null` si aucune transition n’est nécessaire  
    - Retourne l’état suivant si les conditions sont réunies  

## Avantages
- Programmation orientée objet dans Godot (GDScript)  
- Architecture modulaire et réutilisable pour les comportements de personnages  
- Gestion des transitions logiques et événements  
- Mise en place d’une base solide pour ajouter facilement de nouveaux états  

## Usage
- Attacher la StateMachine au Node principal du personnage.  
- Créer des enfants pour chaque état, dérivés de **StateClass**.  
- Configurer les transitions dans la fonction **transitions()** de chaque état.
