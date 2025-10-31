# KeyboardAi - AI-Powered Writing Improvement Keyboard

Un clavier iOS intelligent qui améliore votre écriture en temps réel grâce à l'IA OpenAI GPT-4.

## ✨ Fonctionnalités

- **Amélioration automatique** : Corrige la grammaire, l'orthographe et le style
- **Intégration OpenAI** : Utilise GPT-4o-mini pour des suggestions intelligentes
- **Sécurité maximale** : Clé API stockée dans le Keychain iOS
- **Interface simple** : Un seul bouton "Improve Writing"
- **Preview avant remplacement** : Voyez les suggestions avant de les appliquer

## 🔒 Sécurité

- ✅ Clé API OpenAI stockée de manière sécurisée dans le iOS Keychain
- ✅ Partage sécurisé via App Groups entre l'app et l'extension
- ✅ Aucune clé en clair dans le code
- ✅ Communication HTTPS avec OpenAI
- ✅ Accès restreint au Keychain via kSecAttrAccessGroup

## 📋 Prérequis

### 1. Clé API OpenAI

1. Créez un compte sur [platform.openai.com](https://platform.openai.com)
2. Générez une clé API dans la section "API Keys"
3. Ajoutez des crédits à votre compte OpenAI

### 2. Configuration Xcode - App Groups

**IMPORTANT** : Vous devez configurer un App Group pour permettre le partage de données entre l'app et l'extension.

#### Pour la cible principale (KeyboardAi):
1. Sélectionnez le projet `KeyboardAi` dans le navigateur
2. Sélectionnez la cible `KeyboardAi`
3. Onglet "Signing & Capabilities"
4. "+ Capability" → "App Groups"
5. Cochez/créez `group.tye.KeyboardAi`

#### Pour l'extension (KeyboardExtension):
1. Sélectionnez la cible `KeyboardExtension`
2. Onglet "Signing & Capabilities"
3. "+ Capability" → "App Groups"
4. Cochez le même groupe : `group.tye.KeyboardAi`

#### Pour le Keychain Sharing:
1. Pour **les deux cibles** (KeyboardAi et KeyboardExtension)
2. "+ Capability" → "Keychain Sharing"
3. Ajoutez `group.tye.KeyboardAi`

## 🚀 Installation

### 1. Compiler et installer l'app
```bash
# Ouvrir le projet
open KeyboardAi.xcodeproj

# Build depuis Xcode (Cmd+B)
# Run sur simulateur/appareil (Cmd+R)
```

### 2. Configurer la clé API
1. Lancez l'application KeyboardAi
2. Entrez votre clé API OpenAI (commence par `sk-...`)
3. Cliquez sur "💾 Save API Key"
4. Testez avec "🧪 Test API Key"

### 3. Activer l'extension de clavier
1. **Réglages** → **Général** → **Clavier** → **Claviers**
2. **"Ajouter un clavier..."**
3. Sélectionnez **"KeyboardExtension"**
4. ⚠️ **IMPORTANT** : Activez **"Autoriser l'accès complet"** pour permettre les appels API

## 💡 Utilisation

### Dans n'importe quelle app:

1. Ouvrez un champ de texte (Notes, Messages, Mail, etc.)
2. Écrivez votre texte :
   ```
   i want go to store today maybe buy some thing
   ```
3. Appuyez sur l'icône du globe 🌐 pour changer de clavier
4. Sélectionnez votre clavier **KeyboardExtension**
5. Cliquez sur **"✨ Improve Writing"**
6. Attendez la suggestion de l'IA
7. Cliquez sur **"Replace"** pour appliquer ou **"Cancel"** pour ignorer

### Résultat:
```
I want to go to the store today to maybe buy something.
```

## 🏗️ Architecture

```
KeyboardAi/
├── KeyboardAi/                           # Application principale
│   ├── ViewController.swift              # Configuration API key
│   ├── KeyboardSettings.swift            # Settings partagés (obsolète)
│   ├── KeychainHelper.swift              # Stockage sécurisé Keychain
│   ├── OpenAIService.swift               # Service API OpenAI
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
└── KeyboardExtension/                    # Extension clavier
    ├── KeyboardViewController.swift      # UI du clavier + logique IA
    └── Info.plist                        # Configuration extension
```

## 🔧 Composants Techniques

### KeychainHelper.swift
Gère le stockage sécurisé de la clé API dans le Keychain iOS avec App Group sharing.

**Fonctionnalités:**
- `saveAPIKey(_ key: String)` : Sauvegarde sécurisée
- `getAPIKey()` : Récupération sécurisée
- `deleteAPIKey()` : Suppression
- Utilise `kSecAttrAccessGroup` pour le partage

### OpenAIService.swift
Service de communication avec l'API OpenAI.

**Configuration:**
- Modèle : `gpt-4o-mini` (rapide et économique)
- Temperature : `0.3` (cohérence élevée)
- Max tokens sortie : `10000` (pour des réponses longues)
- System prompt avec few-shot learning

**System Prompt:**
```
You are a writing improvement assistant.
Return ONLY the improved text without explanations.

Examples:
Input: "i want go to store today maybe buy some thing"
Output: "I want to go to the store today to maybe buy something."

[Plus d'exemples...]
```

### KeyboardViewController.swift
Controller principal de l'extension de clavier.

**Logique:**
1. Récupère le texte avant le curseur via `textDocumentProxy.documentContextBeforeInput`
2. Envoie à OpenAI via `OpenAIService.shared.improveText()`
3. Affiche le résultat dans un `UIAlertController`
4. Si validé, supprime l'ancien texte et insère le nouveau via `textDocumentProxy`

## 🎨 Interface

### App Principale
- Configuration de la clé API OpenAI
- Bouton de test pour vérifier la connexion
- Instructions d'activation du clavier
- Indicateurs de chargement et status

### Extension Clavier
- Bouton "✨ Improve Writing" (violet, 220x50)
- Indicateur de chargement pendant la requête API
- Label de status (succès/erreur)
- Bouton globe 🌐 pour changer de clavier

## ⚡ Limitations iOS

### textDocumentProxy
- ❌ **Pas de sélection de texte** : iOS ne permet pas de sélectionner du texte depuis une extension
- ✅ **Solution** : On récupère tout le texte avant le curseur avec `documentContextBeforeInput`
- ⚠️ **Implication** : Le texte après le curseur n'est pas analysé

### Network Access
- ⚠️ **"Allow Full Access" requis** : Les appels réseau nécessitent l'autorisation complète
- Sans cette autorisation, les requêtes API échoueront

## 💰 Coûts OpenAI

**GPT-4o-mini pricing** (Décembre 2024):
- Input : ~$0.15 / 1M tokens
- Output : ~$0.60 / 1M tokens

**Estimation** :
- Texte moyen : ~50 tokens input + 50 tokens output
- Coût par amélioration : ~$0.00004 (0.004¢)
- 1000 améliorations : ~$0.04

## 🔍 Debugging

### Déboguer l'extension
```bash
# Dans Xcode:
1. Sélectionnez le schéma "KeyboardExtension"
2. Product → Run (Cmd+R)
3. Choisissez une app hôte (Notes, Messages)
4. Les breakpoints fonctionneront dans KeyboardViewController
```

### Logs
```swift
// Dans KeyboardViewController
print("Text to improve: \(textBefore)")
print("Improved text: \(improvedText)")
```

### Erreurs communes

**"API key not configured"**
- ✅ Vérifiez que la clé est sauvegardée dans l'app
- ✅ Vérifiez que App Groups est configuré pour les deux cibles
- ✅ Vérifiez que Keychain Sharing est activé

**"No text to improve"**
- ✅ Tapez du texte avant de cliquer sur le bouton
- ✅ Le curseur doit être après du texte

**"Network request failed"**
- ✅ Activez "Autoriser l'accès complet" dans les réglages
- ✅ Vérifiez votre connexion internet
- ✅ Vérifiez que votre clé API est valide

## 🚧 Améliorations Futures

### Fonctionnalités
- [ ] Support de la sélection manuelle de texte
- [ ] Raccourcis clavier personnalisables
- [ ] Suggestions multiples (choisir parmi 3 options)
- [ ] Styles d'écriture (formel, casual, professionnel)
- [ ] Mode hors ligne avec cache
- [ ] Historique des améliorations
- [ ] Statistiques d'utilisation

### Optimisations
- [ ] Cache local des améliorations récentes
- [ ] Batch requests pour réduire les appels API
- [ ] Streaming responses pour feedback instantané
- [ ] Modèle local pour suggestions de base

### UI/UX
- [ ] Dark mode support complet
- [ ] Animations plus fluides
- [ ] Haptic feedback
- [ ] Personnalisation des couleurs
- [ ] Layout de clavier complet (AZERTY/QWERTY)

## 📄 Licence

Ce projet est un exemple éducatif. Utilisez-le librement pour apprendre et construire vos propres projets.

## 👤 Auteur

Créé par Sanz - 30/10/2025

---

**Note**: Ce clavier utilise l'API OpenAI. Assurez-vous de respecter les [conditions d'utilisation d'OpenAI](https://openai.com/policies/usage-policies) et de ne jamais partager votre clé API publiquement.
