<div align="center">

<img src="./assets/images/logo_circle.png" alt="AïkiGrade Logo" width="160"/>

# AïkiGrade

**Train for your Aïkido grade exams and track your progress, privately and offline-friendly.**

[![CI](https://github.com/LouisLeNezet/AikiGrade/actions/workflows/ci.yml/badge.svg)](https://github.com/LouisLeNezet/AikiGrade/actions/workflows/ci.yml)
[![License: PolyForm Noncommercial](https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-blue)](./LICENCE)
[![Built with Flutter](https://img.shields.io/badge/built%20with-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

[**Open the web app**](https://louislenezet.github.io/AikiGrade) · [Report a bug](https://github.com/LouisLeNezet/AikiGrade/issues) · [Suggest a feature](https://github.com/LouisLeNezet/AikiGrade/issues)

</div>

---

## About

AïkiGrade is an application designed to help Aïkido practitioners prepare for their grade exams and keep track of what they master. It is built with Flutter and Dart, and its source code is public.

<!-- Add screenshots here, for example:
<p align="center">
  <img src="./docs/screenshots/exam.png" width="240" alt="Examination mode"/>
  <img src="./docs/screenshots/training.png" width="240" alt="Training mode"/>
</p>
-->

## Features

- **Examination mode**
  - All techniques expected for each Kyu, from the FFAAA handbook
  - Self-evaluate your knowledge before the real exam
- **Training mode**
  - Review the techniques you know, and those you don't master yet
  - Track your improvement over time, technique by technique
- **Training resources**
  - A library of training resources (e.g. YouTube videos) *(work in progress)*
- **Privacy first**
  - No cloud, no account, no tracking
  - All data is stored locally on your device
- **Cross-platform**
  - Available now as a [web app](https://louislenezet.github.io/AikiGrade)
  - Android version coming soon, as a local application

## Try it

- **Web:** [louislenezet.github.io/AikiGrade](https://louislenezet.github.io/AikiGrade)
- **Android:** an APK will be available on the [Releases page](https://github.com/LouisLeNezet/AikiGrade/releases) once the first version is published.

## Run it locally

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install) (see `pubspec.yaml` for the supported version).

```bash
git clone https://github.com/LouisLeNezet/AikiGrade.git
cd AikiGrade
git checkout dev

flutter pub get
flutter run -d chrome
```

Useful commands:

```bash
flutter analyze   # static analysis
flutter test      # run the tests
```

## Contributing

Contributions are welcome! You can:

- report bugs and suggest improvements through [issues](https://github.com/LouisLeNezet/AikiGrade/issues),
- correct or complete the technique data,
- submit pull requests.

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) first: it explains how to set up the project, the workflow (pull requests target `dev`) and the coding guidelines.

## About the project

AïkiGrade is developed by the Aïkido club of Le Rheu, France.

## License

Released under the [PolyForm Noncommercial License 1.0.0](./LICENCE).
You can use, modify and share the code for noncommercial purposes.