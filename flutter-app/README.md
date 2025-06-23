# Menoguide+

Bien-être, accompagnement et intelligence artificielle pour la ménopause

---

## 🌸 Présentation

**Menoguide+** est une application Flutter moderne dédiée au bien-être des femmes pendant la ménopause. Elle combine agents conversationnels IA, suivi de symptômes, météo personnalisée, événements communautaires et recommandations santé.

---

## ✨ Fonctionnalités principales

- **Chat IA multi-agents** (Google Vertex AI Reasoning Engines)
- **Suivi quotidien des symptômes** (humeur, sommeil, bouffées de chaleur, etc.)
- **Recommandations personnalisées** (articles, exercices, méditation)
- **Événements communautaires** (ateliers, webinaires, rencontres)
- **Météo et conseils adaptés**
- **Notifications et rappels intelligents**
- **Interface moderne, responsive et animée**
- **Authentification sécurisée (Firebase Auth)**

---

## 🚀 Installation rapide

1. **Clone le projet**
   ```bash
   git clone https://github.com/olamineZakaria/menoguide-plus.git
   cd menoguide-plus
   ```
2. **Installe les dépendances**
   ```bash
   flutter pub get
   ```
3. **Configure les assets et secrets**
   - Place tes clés Firebase et Google Cloud dans `assets/` (voir Sécurité ci-dessous)
   - Configure les icônes avec `flutter_launcher_icons` si besoin
4. **Lance l'application**
   ```bash
   flutter run
   ```

---

## 🛠️ Configuration requise

- **Flutter** 3.x
- **Dart** >=3.4.4 <4.0.0
- **Firebase** (Auth, Firestore, Storage)
- **Google Cloud Vertex AI** (Reasoning Engines)
- **Clés API** à placer dans `assets/` (non versionnées)

---

## 📁 Structure du projet

```
lib/
  app.dart                # Point d'entrée principal
  main.dart               # Bootstrap Flutter
  models/                 # Modèles de données (User, Message, Symptom...)
  blocs/                  # State management (BLoC)
  services/               # Services (auth, chat, weather, IA...)
  pages/                  # Pages principales (Home, Chat, Tracker...)
  widgets/                # Widgets réutilisables
  constants/              # Couleurs, thèmes, etc.
  utils/                  # Fonctions utilitaires
assets/
  images/, icons/, avatars/, animations/  # Ressources graphiques
android/, ios/, web/, windows/, macos/, linux/  # Plateformes supportées
```

---

## 🔒 Sécurité & bonnes pratiques

- **Ne versionnez jamais de clés ou secrets** (voir `.gitignore`)
- Les fichiers sensibles (ex: `menoguideplus-gcloud-service-account.json`) doivent rester en local
- Utilisez des variables d'environnement ou des coffres-forts pour la prod
- Respectez la RGPD pour les données utilisateurs

---

## 🤝 Contribution

1. Forkez le repo
2. Créez une branche (`git checkout -b feature/ma-fonctionnalite`)
3. Commitez vos changements (`git commit -am 'Ajout d'une fonctionnalité'`)
4. Pushez la branche (`git push origin feature/ma-fonctionnalite`)
5. Ouvrez une Pull Request

---

## 🧑‍💻 Technologies principales
- Flutter, Dart
- Firebase (Auth, Firestore, Storage)
- Google Cloud Vertex AI (Reasoning Engines)
- BLoC, Provider
- Shimmer, Lottie, Google Fonts, etc.

---

## �� Démos & captures d'écran

Ajoutez ici vos captures d'écran ou GIFs de l'application.


**Menoguide+** – Prendre soin de soi, ensemble, à chaque étape de la vie 🌱
