# KeyboardAi - Clavier Personnalisé iOS

Un clavier personnalisé iOS avec un bouton configurable.

## Fonctionnalités

- Bouton personnalisé qui insère du texte configurable (par défaut: "Bonjour")
- Interface de configuration dans l'application principale
- Partage de données entre l'app et l'extension via App Groups
- Support du mode sombre

## Configuration Requise

### IMPORTANT: Configuration de l'App Group dans Xcode

Pour que l'application et l'extension de clavier puissent partager des données, vous devez configurer un **App Group** dans Xcode:

#### 1. Pour la cible principale (KeyboardAi):
1. Sélectionnez le projet `KeyboardAi` dans le navigateur de projet
2. Sélectionnez la cible `KeyboardAi`
3. Allez dans l'onglet "Signing & Capabilities"
4. Cliquez sur "+ Capability"
5. Ajoutez "App Groups"
6. Cochez ou créez le groupe: `group.tye.KeyboardAi`

#### 2. Pour l'extension (KeyboardExtension):
1. Sélectionnez la cible `KeyboardExtension`
2. Allez dans l'onglet "Signing & Capabilities"
3. Cliquez sur "+ Capability"
4. Ajoutez "App Groups"
5. Cochez le même groupe: `group.tye.KeyboardAi`

**Note**: L'identifiant du groupe doit correspondre exactement à celui utilisé dans le code (`group.tye.KeyboardAi`).

## Structure du Projet

```
KeyboardAi/
├── KeyboardAi/                    # Application principale
│   ├── ViewController.swift       # Interface de configuration
│   ├── KeyboardSettings.swift     # Gestion des paramètres partagés
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
└── KeyboardExtension/             # Extension de clavier
    ├── KeyboardViewController.swift  # UI du clavier
    └── Info.plist
```

## Utilisation

### 1. Lancer l'application
L'application affiche une interface pour configurer le texte du bouton.

### 2. Activer l'extension de clavier
1. Allez dans **Réglages** > **Général** > **Clavier** > **Claviers**
2. Appuyez sur **"Ajouter un clavier..."**
3. Sélectionnez **"KeyboardExtension"**

### 3. Utiliser le clavier
1. Ouvrez n'importe quelle application avec un champ de texte
2. Appuyez sur l'icône du globe 🌐 pour changer de clavier
3. Sélectionnez votre clavier personnalisé
4. Cliquez sur le bouton bleu au centre pour insérer le texte configuré

### 4. Modifier le texte du bouton
1. Ouvrez l'application KeyboardAi
2. Entrez le nouveau texte dans le champ
3. Appuyez sur "Enregistrer"
4. Le bouton du clavier sera mis à jour automatiquement

## Architecture Technique

### Communication App ↔ Extension
- Utilise **UserDefaults** avec un **App Group** pour partager les données
- L'application enregistre le texte configuré dans le groupe partagé
- L'extension lit ce texte au démarrage et lors de l'apparition du clavier

### Composants Clés

#### KeyboardSettings.swift
Classe singleton qui gère les paramètres partagés via UserDefaults avec App Group.

#### KeyboardViewController.swift
- Gère l'interface du clavier personnalisé
- Crée un bouton bleu au centre qui insère le texte configuré
- Bouton globe 🌐 pour changer de clavier
- Lit le texte configuré depuis le UserDefaults partagé

#### ViewController.swift
- Interface de configuration de l'app principale
- Champ de texte pour saisir le texte personnalisé
- Aperçu en temps réel
- Bouton d'enregistrement avec animation

## Développement

### Compilation
```bash
xcodebuild -scheme KeyboardAi -configuration Debug
```

### Déboguer l'extension
1. Dans Xcode, sélectionnez le schéma "KeyboardExtension"
2. Lancez l'extension (cela ouvrira l'app Paramètres)
3. Activez le clavier dans les paramètres
4. Utilisez le clavier dans une autre app
5. Les points d'arrêt dans KeyboardViewController fonctionneront

## Limitations

- L'extension de clavier ne peut pas accéder à internet par défaut (sauf si "Autoriser l'accès complet" est activé)
- Les changements de configuration nécessitent de changer de clavier pour être visibles
- L'extension fonctionne dans un sandbox séparé de l'application principale

## Améliorations Futures

- [ ] Ajouter plusieurs boutons configurables
- [ ] Support des emojis et caractères spéciaux
- [ ] Thèmes de couleur personnalisables
- [ ] Suggestions de texte prédictives
- [ ] Support multilingue
- [ ] Layout de clavier complet (AZERTY/QWERTY)

## Auteur

Créé par Sanz - 30/10/2025
