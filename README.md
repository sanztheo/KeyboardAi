<div align="center">

<img src="img/banner.png" alt="KeyboardAi banner" width="100%" />

# KeyboardAi - Clavier iOS qui améliore votre écriture avec l’IA

Améliorez grammaire, style et clarté en un tap - directement depuis un clavier iOS. Propulsé par OpenAI `gpt-4o-mini`, streaming en temps réel et respect de la confidentialité.

<br/>

</div>

---

## Sommaire

- Présentation
- Fonctionnalités
- Sécurité & Confidentialité
- Prérequis
- Installation rapide
- Activer le clavier
- Utilisation
- Architecture
- Détails techniques
- Dépannage (FAQ)
- Roadmap
- Licence & Crédits

---

## Présentation

KeyboardAi est un clavier iOS qui corrige et reformule votre texte pour le rendre plus clair, correct et naturel - sans quitter votre app. L’extension lit le texte accessible autour du curseur, envoie la demande à l’API OpenAI et affiche un aperçu que vous pouvez insérer ou remplacer.

> Recommandé: iOS 15+ (streaming). iOS < 15 pris en charge en mode non‑streaming.

## Fonctionnalités

- Amélioration en un tap: bouton « ✨ Improve Writing »
- Aperçu en direct: affichage du texte amélioré, mise à jour en streaming
- Actions rapides: Replace, Insert, Copy, Refresh, Back
- Lecture « best‑effort » du contexte via `textDocumentProxy`
- Design clair, indicateurs d’état, retours haptiques

## Sécurité & Confidentialité

- Clé API stockée en toute sécurité dans le Keychain iOS
- Partage sécurisé via App Groups (app + keyboard) `group.tye.KeyboardAi`
- Pas de clé API en clair dans le repo
- Appels chiffrés (HTTPS) uniquement vers l’API OpenAI
- Aucun suivi analytics intégré; seul le texte envoyé lors d’une action utilisateur est transmis à l’API

## Prérequis

1) Compte OpenAI et clé API (crédits requis)

2) Capacités Xcode pour le partage app/extension:
- App Groups: `group.tye.KeyboardAi` sur les cibles `KeyboardAi` et `KeyboardExtension`
- Keychain Sharing: même identifiant de groupe sur les deux cibles

## Installation rapide

```bash
open KeyboardAi.xcodeproj  # ouvre le projet dans Xcode
```

Dans l’app `KeyboardAi`:
- Saisissez votre clé API (`sk-…`)
- « 💾 Save API Key », puis « 🧪 Test API Key »

## Activer le clavier

1. Réglages iOS → Général → Clavier → Claviers → Ajouter un clavier…
2. Choisissez « KeyboardExtension »
3. Activez « Autoriser l’accès complet » (indispensable pour le réseau)

## Utilisation

1. Placez le curseur dans n’importe quelle app (Notes, Mail, Messages…)
2. Passez au clavier « KeyboardExtension » (globe 🌐)
3. Tapez votre texte puis appuyez sur « ✨ Improve Writing »
4. Prévisualisez le résultat et choisissez Replace, Insert ou Copy

Exemple:

```
Entrée  : i want go to store today maybe buy some thing
Sortie  : I want to go to the store today to maybe buy something.
```

## Architecture

### Vues et style (nouveau découpage)

```
KeyboardExtension/
 ├─ Views/
 │  ├─ KBColor.swift                 # Palette centralisée (tileBG, midGreyText…)
 │  ├─ KeyboardHomeStyling.swift     # Style de l'accueil (Improve + barre du bas)
 │  ├─ KeyboardControlsView.swift    # Conteneur accueil (Improve + status + BottomActionBar)
 │  ├─ BottomActionBarView.swift     # Barre [space | delete | return] (layout fill)
 │  └─ ImproveWritingView.swift      # Panneau d'aperçu IA (stream + Insert/Replace/Reload/Back)
 ├─ KeyboardViewController.swift     # Orchestration + câblage des actions
 ├─ TextProxyBestEffort.swift        # Lecture complète via proxy (balayage + probes)
 └─ OpenAIService.swift              # Streaming SSE (iOS 15+) + fallback
```

Conseil Xcode: si vous voyez des fichiers grisés après ce déplacement, glissez‑déposez le dossier `Views/` dans la cible `KeyboardExtension` pour mettre à jour les références.

```
KeyboardAi/
├─ KeyboardAi/                     # Application hôte (clé API, test, guides)
│  ├─ ViewController.swift         # UI de configuration + test API
│  ├─ KeychainHelper.swift         # Stockage sécurisé (Keychain + App Group)
│  └─ OpenAIService.swift          # App: requêtes non‑streaming
│
└─ KeyboardExtension/              # Extension de clavier
   ├─ KeyboardViewController.swift # Orchestration UI + logique
   ├─ Views/…                      # Vues et style extraits (voir ci‑dessus)
   ├─ TextProxyBestEffort.swift    # Lecture « tout le texte accessible »
   └─ OpenAIService.swift          # Extension: requêtes streaming (iOS 15+)
```

## Détails techniques

- Modèle OpenAI: `gpt-4o-mini` (rapide/économique), `temperature = 0.3`
- Streaming SSE côté extension (fallback non‑streaming pour iOS < 15)
- Budget large d’entrée (≈ 10 000 tokens, ≈ 40 000 caractères)
- « Best‑effort select all » pour lire tout le contexte accessible sans modifier le texte
- Insertion remplaçant ou ajoutant le texte amélioré via `textDocumentProxy`

### Limitations iOS à connaître

- Les claviers ne peuvent pas sélectionner officiellement du texte: lecture via contexte avant/après
- L’accès réseau nécessite « Autoriser l’accès complet »
- Le texte après le curseur peut ne pas être accessible selon l’app hôte

## Dépannage (FAQ)

- « API key not configured » → Enregistrez la clé dans l’app, vérifiez App Group + Keychain Sharing
- « No text to improve » → Tapez du texte et assurez‑vous que le curseur suit le texte
- « Network request failed » → Activez l’accès complet, vérifiez la connexion et la clé

Astuce debug:

```swift
// Dans l’extension
print("[KeyboardAI] captured=\(capturedText.count)")
print("[KeyboardAI] improved=\(improvedText.count)")
```

## Roadmap

- Styles d’écriture (formel, concis, amical…)
- Suggestions multiples et choix utilisateur
- Raccourcis clavier et personnalisation UI
- Historique local + copie rapide
- Streaming avec indicateurs progressifs

## Licence & Crédits

Projet d’exemple éducatif. Utilisez‑le librement pour apprendre et construire vos idées. Créé par Sanz (31/10/2025).

Note: Respectez les politiques d’OpenAI et ne partagez jamais de clé API en public.
