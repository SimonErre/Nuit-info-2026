# 🎮 Maya - Le Jeu du NIRD

Un jeu éducatif développé avec **Godot Engine 3.x** pour promouvoir les logiciels libres, l'open source et le numérique responsable.

---

## 📖 Synopsis

Vous incarnez un membre du **NIRD** (Numérique Inclusif, Responsable et Durable), un collectif d'étudiants engagés dans la promotion des logiciels libres. Votre mission : convaincre le Directeur du lycée d'adopter les solutions open source dans l'établissement !

---

## 🎯 Objectif Principal

**Convaincre le Directeur** d'adopter les logiciels libres et open source dans l'établissement scolaire.

Pour y parvenir, vous devez :
- 📚 **Apprendre** en parlant aux PNJ (professeurs, élèves, personnel)
- 🧠 **Accumuler des connaissances** sur différents sujets
- 💬 **Débloquer des arguments** pour le débat final avec le Directeur
- 🎯 **Atteindre le seuil de conviction** requis (75% de connaissances)

---

## 🕹️ Contrôles

| Touche | Action |
|--------|--------|
| **Flèches directionnelles** | Se déplacer |
| **E** | Interagir avec un PNJ / Objet |
| **M** | Activer/Désactiver le son |

---

## 📊 Système de Jeu

### Statistiques du Joueur

| Stat | Description |
|------|-------------|
| ❤️ **Moral** | Vos points de vie (0-100). Si le moral tombe à 0, c'est Game Over ! |
| 🧠 **Connaissance** | Votre niveau de savoir accumulé (0-100). Nécessaire pour convaincre le Directeur. |

### Sujets à Débloquer

En parlant aux différents PNJ, vous pouvez débloquer des sujets de connaissance :

| Sujet | PNJ Source | Description |
|-------|------------|-------------|
| 📝 **Markdown** | Prof de Maths | Langage de balisage simple et pérenne |
| 🔧 **La Forge** | Admin Système | Plateforme nationale pour l'éducation |
| 🔒 **RGPD** | Admin Système | Protection des données personnelles |
| 🐧 **Linux** | Admin Système | Système d'exploitation libre |
| 🌱 **Écologie** | Élève Écolo | Impact environnemental du numérique |
| 🇫🇷 **Souveraineté** | Élève Écolo | Indépendance numérique nationale |
| ♻️ **Reconditionnement** | Quête Élève Écolo | Donner une seconde vie aux PC |

---

## 👥 Personnages (PNJ)

### 🧑‍🏫 Prof de Maths
Passionné par le Markdown, il vous apprendra les avantages de ce format de texte simple et écologique.

### 💻 Admin Système
Expert technique qui vous parlera de la Forge nationale, du RGPD et de Linux. Indispensable pour les arguments techniques !

### 🌱 Élève Écolo
Militant pour l'écologie numérique, il propose une quête de reconditionnement et vous sensibilise à l'impact environnemental.

### 👥 Fans de Windows
Des élèves sceptiques qu'il faudra convaincre des bienfaits de l'open source.

### 👩‍💼 Femme Info
Responsable informatique qui a des problèmes avec son PC. Peut-être pouvez-vous l'aider ?

### 🎩 M. le Directeur (Boss Final)
Le sceptique ultime ! Il vous testera avec des questions difficiles et peut vous "roaster" si vous manquez de connaissances.

---

## 🌱 Quête de Reconditionnement

Une quête optionnelle en 4 étapes proposée par l'Élève Écolo :

| Étape | Description |
|-------|-------------|
| 📦 **1. Récupérer le PC** | Trouver un vieux PC dans la salle informatique |
| 🔒 **2. Effacer les données** | Lancer un effacement sécurisé (respect RGPD) |
| 🔧 **3. Réparer le PC** | Nettoyer et dépoussiérer l'ordinateur |
| 📤 **4. Livrer le PC** | Donner le PC reconditionné à quelqu'un dans le besoin |

**Récompense** : +20 connaissances et sujet "Reconditionnement" débloqué !

---

## 💻 Interactions avec les Ordinateurs

### Ordinateur Windows
- Ouvrir le **Bloc-notes** pour lire des fichiers
- Utiliser l'**Invite de commandes** (cmd)
- Lire la **Lettre du NIRD** (votre mission)
- Option secrète : Installer **Linux** ! 🐧

### Ordinateur Linux
- Terminal Linux fonctionnel
- Interface Ubuntu

### Vieux PC (Quête)
- Mini-jeu de nettoyage/dépoussiérage
- Affiche un BSOD (écran bleu) si pas en quête

---

## ⚔️ Système de Combat (Dialogue)

Le "combat" se fait par le dialogue avec le Directeur :

- ✅ **Bonne réponse** : Gagne des points d'argument, augmente le combo
- ❌ **Mauvaise réponse** : Perd du moral, le Directeur vous "roast"
- 🔥 **Combo** : Enchaîner les bonnes réponses augmente vos gains
- 💀 **Game Over** : Si le moral tombe à 0

### Conditions de Victoire

Pour convaincre le Directeur, vous devez :
- Avoir au moins **75% de connaissance**
- Avoir débloqué au moins **2 sujets** différents

---

## 🏆 Fins du Jeu

| Fin | Condition |
|-----|-----------|
| 🏆 **Victoire Totale** | Directeur complètement convaincu (score maximum) |
| ✅ **Victoire Partielle** | Directeur convaincu d'essayer un logiciel libre |
| 💀 **Game Over** | Moral à 0 - Le directeur vous a achevé |

---

## 🛠️ Technologies Utilisées

- **Godot Engine 3.x** - Moteur de jeu open source
- **GDScript** - Langage de programmation
- **Export HTML5** - Jouable dans le navigateur

---

## 📁 Structure du Projet

```
mayaGame/
├── main.tscn          # Scène principale
├── GameData.gd        # Données globales du jeu (stats, quêtes)
├── Player.tscn/gd     # Joueur et déplacements
├── DialogueUI.tscn/gd # Interface de dialogue
├── Director.gd        # Boss final et ses dialogues
├── NPC.gd            # Script générique PNJ
├── [PNJ].gd          # Scripts spécifiques (AdminSys, ProfMaths, etc.)
├── ComputerUI.tscn/gd # Interface ordinateur
├── assets/           # Images et ressources
└── sprite/           # Sprites des personnages
```

---

## 🎓 Thèmes Éducatifs Abordés

Ce jeu sensibilise aux thématiques suivantes :

- 🆓 **Logiciels libres et open source** - Alternatives aux solutions propriétaires
- 🔒 **RGPD et protection des données** - Importance de la vie privée
- 🌍 **Écologie numérique** - Impact environnemental de l'informatique
- 🇫🇷 **Souveraineté numérique** - Indépendance technologique
- ♻️ **Économie circulaire** - Reconditionnement et seconde vie
- 📝 **Formats ouverts** - Markdown et pérennité des documents

---

## 🚀 Lancer le Jeu

### Version Web
Rendez-vous sur https://mayalabeille.vercel.app

---

## 📜 Crédits

Développé dans le cadre d'un projet éducatif sur le numérique responsable.

**Thème** : NIRD - Numérique Inclusif, Responsable et Durable

---

*🐧 Vive le libre !*