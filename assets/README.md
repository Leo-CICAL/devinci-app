[![Codemagic build status](https://api.codemagic.io/apps/5f1aaf9588aa90329c1b72a5/5f1aaf9588aa90329c1b72a4/status_badge.svg)](https://codemagic.io/apps/5f1aaf9588aa90329c1b72a5/5f1aaf9588aa90329c1b72a4/latest_build)
<p align="center">
  <a href="https://github.com/antoineraulin/devinci-app"><img src="assets/icon_blanc_a.png" height="140"></a>
</p>
<span align="center">

# Devinci

</span>

## Présentation

**Devinci** est une application qui a pour but de faciliter l'utilisation du portail étudiant du pôle Léonard Devinci. Cela passe notamment par la connexion automatique, sans devoir entrer ses identifiants à chaque utilisation, des informations accessibles facilement, des notifications pour prévenir d'une nouvelle note, la possibilité de se marquer présent depuis l'application, un mode nuit ou encore l'accès aux documents importants.

<a href="https://devinci.araulin.tech/" style="cursor: pointer;display: inline-block;text-align: center;white-space: nowrap;font-size: 12px;line-height: 1.17648;font-weight: 400;letter-spacing: -0.022em;min-width: 28px;padding-left: 16px;padding-right: 16px;padding-top: 8px;padding-bottom: 8px;border-radius: 18px;background: #0071e3;color: white;text-decoration: none;">En savoir plus</a>

- [Devinci](#devinci)
  - [Présentation](#présentation)
  - [Build Instructions](#build-instructions)
  - [Transparence et vie privée](#transparence-et-vie-privée)
  - [Technologies](#technologies)
  - [Contribution](#contribution)
  - [Dépendances](#dépendances)

## Build Instructions

1. Installer la dernière version de [Flutter](https://flutter.dev/docs/get-started/install).
2. Pour Android vous devez avoir installé Android-Studio, pour iOS vous devez avoir un Mac avec Xcode et les [Xcode developer tools](https://developer.apple.com/xcode/downloads/) installés. Normalement tout est très bien détaillé sur le site de Flutter.
3. Obtenir une clé de license pour le widget de Syncfusion : [ici](https://www.syncfusion.com/products/communitylicense), elle est gratuite.
4. Ouvrez le projet dans votre IDE (VS Code ou Android Studio), ils doivent être configuré pour supporter Flutter.
5. Recuperer les dépendances : ouvrez un terminal de commande au niveau du dossier racine du projet et faites :
    ```console
    pub get
    ```
6. Pour generer un apk (Android) : 
   - Pour un appareil 64 bits:
        ```console
        flutter build apk --target-platform=android-arm64
        ```
    - Pour un appareil 32 bits:
         ```console
        flutter build apk --target-platform=android-arm
        ``` 
7. Pour installer l'app sur iOS :
   - Brancher un appareil iOS sur votre Mac puis:
        ```console
        flutter run
        ```
        Ou <kbd>Fn</kbd>+<kbd>F5</kbd> sur VS Code

<a href="https://devinci.araulin.tech/beta.html" style="cursor: pointer;display: inline-block;text-align: center;white-space: nowrap;font-size: 12px;line-height: 1.17648;font-weight: 400;letter-spacing: -0.022em;min-width: 28px;padding-left: 16px;padding-right: 16px;padding-top: 8px;padding-bottom: 8px;border-radius: 18px;background: #0071e3;color: white;text-decoration: none;">Installation simplifiée</a>


## Transparence et vie privée

Ce projet a pour principale vocation d'aider sans nuire, c'est pourquoi le respect de la vie privée a été au centre des considérations lors de la création de l'application. Aucune donnée ne transite par un serveur, la connexion au portail, l'acquisition des données et le traitement de ces dernières se fait entièrement en local sur l'appareil de l'utilisateur. Toutes les données récupérées par Devinci proviennent soit directement du portail étudiant soit de fichier de configuration accessible et modifiable publiquement sur [GitHub](https://github.com/antoineraulin/devinci-app/tree/gh-pages). Les seuls moments ou des données sont envoyés par l'application sont lorsqu'un bug survient et que vous donnez votre accord explicite pour que les logs de l'erreur soit remontées au développeur via la plateforme [Sentry](https://sentry.io/) qui a été choisi parce qu'elle est open-source et qu'elle semble récolter moins d'informations personnelles que ses concurrents, elle peut de plus être installée sur un serveur personnel pour plus de contrôle, enfin lorsqu'une erreur survient vous avez la possibilité de donner un feedback sur l'erreur avec une capture d'écran, ces informations supplémentaires sont transmises quant à elles par mail via votre boîte mail au développeur.

## Technologies

- ### Flutter/Dart
  Ce projet repose en grande partie sur le framework [Flutter](https://flutter.dev/) créé par Google et basé sur le langage [Dart](https://dart.dev/) afin de proposer une expérience similaire sur Android et iOS. *Voir le projet sur [GitHub](https://github.com/flutter/flutter)*
- ### Sentry.io
  Devinci utilise les services de Sentry pour remonter les bugs/erreurs au développeur. (*Voir le projet sur [GitHub](https://github.com/getsentry/sentry)*). Sentry est intégré a l'application grâce à cette librairie : [sentry](https://pub.dev/packages/sentry)
- ### Matomo
  Matomo est une platefome d'analyse d'utilisation auto-hebergé, open-source, éthique et respectueuse de la vie-privée. Les données récoltées ne sont utilisées aux « fins propres » de Google comme elles pourraient l'être si j'utilisais Google Analytics dans ce projet. [En savoir plus](https://fr.matomo.org)
- ### Syncfusion flutter widgets
  Les widgets flutter de Syncfusion sont utilisés pour afficher l'emploi du temps et la grille des salles libres dans l'application. [En savoir plus](https://www.syncfusion.com/flutter-widgets/)

## Contribution

Vous souhaitez contribuer ? Prenez connaissance des [lignes directions de contribution](CONTRIBUTING.md)

## Dépendances

Voir dans le fichier [pubsec.yaml](https://github.com/antoineraulin/devinci-app/blob/master/pubspec.yaml)
