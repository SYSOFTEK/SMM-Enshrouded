# SMM-Enshrouded v2.2.0.0

![GitHub release (latest by date)](https://img.shields.io/github/v/release/SYSOFTEK/SMM-Enshrouded)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/SYSOFTEK/SMM-Enshrouded/total)
![GitHub issues](https://img.shields.io/github/issues-raw/SYSOFTEK/SMM-Enshrouded)
![GitHub last commit](https://img.shields.io/github/last-commit/SYSOFTEK/SMM-Enshrouded)

![SCREENSHOT](/screenshot.jpg)

### ROADMAP v2.3.0.0
|English Description                                           |Description Francaise                                             |%    |
|--------------------------------------------------------------|------------------------------------------------------------------|-----|
|Test IF serveur is online via steamquerytool                  |Test si serveur en ligne via steamquerytool                       |100% |
|Notify update directly in the software                        |Notification de mise à jour directement dans le logiciel          |50%  |
|Backup and profile with JSON config file                      |Sauvegarde et profil avec le fichier de config JSON               |20%  |
|Players online list                                           |Liste des joueurs en ligne                                        |100% |
|Webhook Discord (players & server : online / offline)         |Webhook Discord (joueurs & serveur : en ligne / hors ligne)       |100% |

## Introduction (english version)
SMM-Enshrouded (Server Manager and Monitor for Enshrouded) is a software developed with AutoIt. It provides real-time monitoring of server performance, including CPU, RAM usage, and disk write speed. The software is currently available in French and English.

## Features
- **Real-time server monitoring**: Tracking of CPU, RAM usage, and disk write speed.
- **Integration of the Enshrouded server console**: Display of the game server console directly in the SMM-Enshrouded interface.
- **Configuration modification**: Modification of the Enshrouded server's JSON configuration via an accessible panel.

## Pre-Compilation
A pre-compiled binary of the software is available. However, it is important to note that some antivirus programs, and via VirusTotal scanning, may report false positives. These alerts do not reflect the presence of malware in the software. We encourage users to verify the sources if necessary. For those who prefer, it is also possible to compile the software from the sources.

## Compilation
Before compiling the software, make sure you have the following prerequisites:
- [AutoIt](https://www.autoitscript.com/site/autoit/)

Follow these steps to compile SMM-Enshrouded:
1. Compile the AutoIt script SMM-Enshrouded.au3 using AutoIt in the same folder as the other files (icon, images, etc.).

## Usage
To use SMM-Enshrouded, follow these instructions:
- Place and launch the SMM-Enshrouded.exe executable in the root folder where the enshrouded_server.exe file is located.
- Note that the executable's data will be extracted to the %appdata% directory.
- To configure the server, it needs to be launched once to create the configuration file.

## Available Languages
- French
- English

## License
This project is under the MIT license. See the `LICENSE` file for more information.

## Security and Data Integrity
It is important to emphasize that SMM-Enshrouded does not modify, affect, or inject any code into the original files of the Enshrouded server. The software acts solely as a monitoring and management tool.

---

## Introduction (version francaise)
SMM-Enshrouded (Server Manager and Monitor for Enshrouded) est un logiciel développé avec AutoIt. Il offre une surveillance en temps réel des performances du serveur, incluant l'utilisation du CPU, de la RAM, et la vitesse d'écriture sur le disque. Le logiciel est actuellement disponible en français et en anglais.

## Fonctionnalités
- **Surveillance en temps réel du serveur** : Suivi de l'utilisation du CPU, de la RAM, et de la vitesse d'écriture sur le disque.
- **Intégration de la console du serveur Enshrouded** : Affichage de la console du serveur de jeu directement dans l'interface de SMM-Enshrouded.
- **Modification de la configuration** : Modification de la configuration JSON du serveur Enshrouded via un panneau accessible.

## Pré-Compilation
Un binaire pré-compilé du logiciel est disponible. Cependant, il est important de noter que certains antivirus, et via le scan de VirusTotal peuvent signaler des faux positifs. Ces alertes ne reflètent pas la présence de logiciels malveillants dans le logiciel. Nous encourageons les utilisateurs à vérifier les sources si nécessaire. Pour ceux qui préfèrent, il est également possible de compiler le logiciel à partir des sources.

## Compilation
Avant de compiler le logiciel, assurez-vous d'avoir les prérequis suivants :
- [AutoIt](https://www.autoitscript.com/site/autoit/)

Suivez ces étapes pour compiler SMM-Enshrouded :
1. Compilez le script AutoIt SMM-Enshrouded.au3 en utilisant AutoIt dans le même dossier que les autres fichiers (icône, images, etc.).

## Utilisation
Pour utiliser SMM-Enshrouded, suivez ces instructions :
- Placez et lancez l'exécutable SMM-Enshrouded.exe dans le dossier racine où se trouve le fichier enshrouded_server.exe.
- Notez que les données de l'exécutable seront extraites dans le répertoire %appdata%.
- Pour pouvoir configurer le serveur, il est nécessaire de le lancer une fois afin de créer le fichier de configuration.

## Langues Disponibles
- Français
- Anglais

## Licence
Ce projet est sous licence MIT. Consultez le fichier `LICENSE` pour plus d'informations.

## Sécurité et Intégrité des Données
Il est important de souligner que SMM-Enshrouded ne modifie, n'affecte, ni n'injecte aucun code dans les fichiers originaux du serveur Enshrouded. Le logiciel agit uniquement en tant qu'outil de surveillance et de gestion.
