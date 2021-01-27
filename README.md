[![Codemagic build status](https://api.codemagic.io/apps/5f1aaf9588aa90329c1b72a5/5f1aaf9588aa90329c1b72a4/status_badge.svg)](https://codemagic.io/apps/5f1aaf9588aa90329c1b72a5/5f1aaf9588aa90329c1b72a4/latest_build)
[![Discord](https://img.shields.io/discord/760489327305556049)](https://discord.gg/wttsfQP)
<p align="center">
<a href="https://play.google.com/store/apps/details?id=eu.araulin.devinci"><img src="https://steverichey.github.io/google-play-badge-svg/img/fr_get.svg" height="100"></a>
<a href="https://testflight.apple.com/join/HUgzMmbA"><img src="https://devinci.araulin.tech/assets/testflight.png" height="100"></a>

</p>

<p align="center">
  <a href="https://github.com/antoineraulin/devinci-app"><img src="assets/icon_blanc_a.png" height="140"></a>
</p>
<span align="center">

# Devinci

</span>

![3 captures d'écran de l'application Devinci](.github_data/devinci.png)

## Présentation

**Devinci** est une application qui a pour but de faciliter l'utilisation du portail étudiant du pôle Léonard De Vinci. Cela passe notamment par la connexion automatique, sans devoir entrer ses identifiants à chaque utilisation, des informations accessibles facilement, des notifications pour prévenir d'une nouvelle note, la possibilité de se marquer présent depuis l'application, un mode nuit ou encore l'accès aux documents importants.

<a href="https://devinci.araulin.tech/" style="cursor: pointer;display: inline-block;text-align: center;white-space: nowrap;font-size: 12px;line-height: 1.17648;font-weight: 400;letter-spacing: -0.022em;min-width: 28px;padding-left: 16px;padding-right: 16px;padding-top: 8px;padding-bottom: 8px;border-radius: 18px;background: #0071e3;color: white;text-decoration: none;">En savoir plus</a>

- [Devinci](#devinci)
  - [Présentation](#présentation)
  - [Build Instructions](#build-instructions)
  - [Technologies](#technologies)
  - [Contribution](#contribution)
  - [Traduction](#traduction)
  - [Dépendances](#dépendances)

## Build Instructions

1. Installer la dernière version de [Flutter](https://flutter.dev/docs/get-started/install).
2. Pour Android vous devez avoir installé Android-Studio, pour iOS vous devez avoir un Mac avec Xcode et les [Xcode developer tools](https://developer.apple.com/xcode/downloads/) installés. Normalement tout est très bien détaillé sur le site de Flutter.
3. ~~Obtenir une clé de license pour le widget de Syncfusion : [ici](https://www.syncfusion.com/products/communitylicense), elle est gratuite.~~ elle n'est plus nécessaire
4. Ouvrez le projet dans votre IDE (VS Code ou Android Studio), ils doivent être configuré pour supporter Flutter.
6. Récupérer les dépendances : ouvrez un terminal de commande au niveau du dossier racine du projet et faites :
   ```console
   pub get
   ```
7. Pour générer un apk (Android) :
   - [générer un clé de signature](https://flutter.dev/docs/deployment/android#signing-the-app)
   - créer le fichier **`android/key.properties`** : 
      ```properties
      storePassword=********
      keyPassword=********
      keyAlias=key
      storeFile=C:\\Users\\[VOTRE NOM D'UTILISATEUR]\\key.jks
      ```
   - Pour un appareil 64 bits:
     ```console
     flutter build apk --target-platform=android-arm64
     ```
   - Pour un appareil 32 bits:
     ```console
     flutter build apk --target-platform=android-arm
     ```
8. Pour installer l'app sur iOS :
   - Brancher un appareil iOS sur votre Mac puis:
     ```console
     flutter run
     ```
     Ou <kbd>Fn</kbd>+<kbd>F5</kbd> sur VS Code

<a href="https://devinci.araulin.tech/beta.html" style="cursor: pointer;display: inline-block;text-align: center;white-space: nowrap;font-size: 12px;line-height: 1.17648;font-weight: 400;letter-spacing: -0.022em;min-width: 28px;padding-left: 16px;padding-right: 16px;padding-top: 8px;padding-bottom: 8px;border-radius: 18px;background: #0071e3;color: white;text-decoration: none;">Installation simplifiée</a>

## Technologies

- ### Flutter/Dart
  Ce projet repose en grande partie sur le framework [Flutter](https://flutter.dev/) créé par Google et basé sur le langage [Dart](https://dart.dev/) afin de proposer une expérience similaire sur Android et iOS. _Voir le projet sur [GitHub](https://github.com/flutter/flutter)_
- ### Sentry.io
  Devinci utilise les services de Sentry pour remonter les bugs/erreurs au développeur. (*Voir le projet sur [GitHub](https://github.com/getsentry/sentry)*). Sentry est intégré a l'application grâce à cette librairie : [sentry](https://pub.dev/packages/sentry)
- ### Matomo
  Matomo est une platefome d'analyse d'utilisation auto-hebergé, open-source, éthique et respectueuse de la vie-privée. Les données récoltées ne sont utilisées aux « fins propres » de Google comme elles pourraient l'être si j'utilisais Google Analytics dans ce projet. [En savoir plus](https://fr.matomo.org)
- ### Syncfusion flutter widgets
  Les widgets flutter de Syncfusion sont utilisés pour afficher l'emploi du temps et les salles libres dans l'application. [En savoir plus](https://www.syncfusion.com/flutter-widgets/flutter-calendar)

## Contribution

Vous souhaitez contribuer ? Prenez connaissance des [lignes directrices de contribution](CONTRIBUTING.md)

## Traduction

Aidez à traduire Devinci dans votre langue.
  
### Création d'une nouvelle langue

Si la langue que vous souhaitez traduire n'existe pas encore sous forme de fichier JSON, soumettez-nous une issue afin que nous puissions créer un modèle pour que vous puissiez commencer.

### Soumettre des modifications
Pour traduire, forkez ce repo et éditez le fichier JSON de votre langue situé dans `/assets/translations` . Ensuite, soumettez une pull request.

Notez que vous n'avez pas besoin de cloner votre fork pour faire les modifications; vous pouvez tout faire sur l'interface web de GitHub. Il vous suffit d'ouvrir un fichier dans votre propre fork et de cliquer sur l'icône du crayon pour commencer les modifications.

### Traduction
Le fichier JSON de traduction est constitué de paires de valeurs clés. La clé doit vous donner une bonne idée de l'endroit où se trouve le texte dans l'application.

Pour traduire, il suffit de modifier la valeur. Par exemple, disons que vous voyez
```JSON
{
"login" : "Connexion"
}
```
Il suffit de le changer en :

```JSON
{
"login" : "********"
}
```
où "********" est l'expression "login" dans la langue cible. J'utilise le bouton de connexion comme exemple ici.

Si vous rencontrez quelque chose comme :

```JSON
{
"copied":"{} copié"
}
```
laissez la partie `{}` seule et ne la traduisez pas. `{}` ne fait pas partie du texte et sera remplacé par la valeur appropriée lorsque l'application sera lancée.

Pareil pour :
```JSON
{
"unknown_error": "Une erreur inconnue est survenue.\n\nCode : {code}\nInformation: {exception}",
}
```
`{code}` et `{exception}` seront remplacés par les valeurs appropriées.

Pour le pluriel :
Exemple : 
```JSON
"day": {
    "zero":"{} дней",
    "one": "{} день",
    "two": "{} дня",
    "few": "{} дня",
    "many": "{} дней",
    "other": "{} дней"
  },
  "money": {
    "zero": "You not have money",
    "one": "You have {} dollar",
    "many": "You have {} dollars",
    "other": "You have {} dollars"
  }
```

Pour les genres : 
Exemple : 
```JSON
{
  "greetings":{
      "male":"Hi Mr. {}",
      "female":"Hello Ms. {}",
      "other":"Hello {}"
   }
}
```

### Langues existantes
Voici un tableau des codes de langue vers nom de langue, dans l'ordre alphabétique. Ces langues ont leurs fichiers modèles prêts, mais ne sont pas nécessairement prêtes à être utilisées dans l'application.

| code de langue | nom de la langue | nom natif | État |
| --- | --- | --- | :---: |
| `fr` (default) | French | Français | ✅ 
| `en` | English | English | ✅ |
| `de` | German | Deutsch | ✅ |




## Dépendances

Voir dans le fichier [pubsec.yaml](https://github.com/antoineraulin/devinci-app/blob/master/pubspec.yaml)
