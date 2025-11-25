<div align="center">

# 💝 GoodLoop - Codzienne Akty Dobroci

### Aplikacja konkursowa Hack Heroes 2025

[![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![HackHeroes](https://img.shields.io/badge/Hack_Heroes-2025-red?style=for-the-badge)](https://hackheroes.pl/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Promujemy dobroć poprzez codzienne wyzwania i gamifikację ✨**

[📱 Funkcje](#-funkcje) • [🚀 Instalacja](#-szybka-instalacja) • [🎯 Cel Społeczny](#-cel-społeczny) • [🛠️ Technologie](#️-technologie) • [📥 Pobierz APK](#-pobierz-apk)

</div>

---

## 📖 O Projekcie

**GoodLoop** to aplikacja mobilna stworzona na potrzeby 10. edycji konkursu **Hack Heroes 2025**. Projekt łączy nowoczesną technologię z psychologią pozytywną, zachęcając użytkowników do wykonywania drobnych, codziennych aktów dobroci.

Każdego dnia o północy użytkownik otrzymuje nowe zadanie (np. _"Pochwal kogoś szczerze"_), którego wykonanie przynosi punkty, buduje motywacyjny "streak" i realnie zmienia świat na lepsze.

## 🎯 Cel Społeczny

W świecie pełnym negatywnych wiadomości, stresu i izolacji, GoodLoop odpowiada na palące problemy społeczne:

- 🌟 **Walka z znieczulicą:** Budujemy nawyk zauważania drugiego człowieka.
- 🔥 **Motywacja:** Mechanika _streaks_ (dni z rzędu) pomaga utrzymać regularność w czynieniu dobra.
- 🌍 **Wspólnota:** Anonimowy feed pozwala czerpać inspirację z dobrych uczynków innych, nie karmiąc ego (brak nazwisk, czysta inspiracja).
- 💪 **Sprawczość:** Pokazujemy młodym ludziom, że małe gesty mają wielką moc oddziaływania.

> **Czas realizacji projektu:** 10 - 25 listopada 2025

---

## ✨ Funkcje

### 📅 System Codziennych Zadań

- Automatyczne nowe zadanie każdego dnia.
- Kategorie: _życzliwość, pomoc, wdzięczność, dzielenie się_.
- Różne poziomy trudności punktowane gwiazdkami.

### 🎮 Gamifikacja

- **Punkty:** Za każde ukończone zadanie.
- **Poziomy:**
  - 🌱 Początkujący (0-100 pkt)
  - 🌿 Pomocnik (100-300 pkt)
  - 🌻 Inspirator (300-500 pkt)
  - 👑 Strażnik Dobra (500+ pkt)
- **Osiągnięcia:** System odznak (np. "Tygodniowy Wojownik", "Pierwsze Kroki").

### 🌍 Społeczność

- Anonimowy feed "GoodVibes".
- Możliwość dodania refleksji po wykonaniu zadania.
- Bezpieczna przestrzeń bez hejtu.

### 👤 Profil i Personalizacja

- Personalizacja awatara.
- Zaawansowane statystyki i historia.
- Ranking użytkowników (oparty na poziomie, nie na rywalizacji).

---

## 🎨 Galeria

|                          Ekran Powitalny                           |                         Zadanie Dnia                         |                         Profil Użytkownika                         |                                 Osiągnięcia                                  |
| :----------------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------------: | :--------------------------------------------------------------------------: |
| <img src="docs/screenshots/welcome.png" width="200" alt="Welcome"> | <img src="docs/screenshots/home.png" width="200" alt="Home"> | <img src="docs/screenshots/profile.png" width="200" alt="Profile"> | <img src="docs/screenshots/achievements.png" width="200" alt="Achievements"> |

---

## 🚀 Szybka Instalacja (Dla Jury)

Instalacja zajmuje mniej niż **10 minut**.

### Wymagania

- Flutter SDK (3.0+)
- Urządzenie z Androidem lub Emulator

### Krok po kroku

1.  **Sklonuj repozytorium:**

    ```bash
    git clone [https://github.com/](https://github.com/)[TWOJA_NAZWA_UZYTKOWNIKA]/goodloop.git
    cd goodloop
    ```

2.  **Zainstaluj zależności:**

    ```bash
    flutter pub get
    ```

3.  **Konfiguracja Firebase (Ważne!):**

    - _Opcja A (Szybka):_ Użyj pliku `google-services.json` dostarczonego w załączniku zgłoszenia (jeśli dołączono) i umieść go w `android/app/`.
    - _Opcja B (Własna):_ Utwórz projekt w Firebase Console, dodaj aplikację Android (`com.example.goodloop`) i pobierz własny `google-services.json`.

4.  **Uruchom aplikację:**
    ```bash
    flutter run
    ```

> 💡 **Szczegółowa instrukcja:** Zobacz plik [INSTALLATION.md](INSTALLATION.md) dla pełnego opisu konfiguracji backendu.

### 📥 Pobierz APK

Gotowy plik `.apk` do zainstalowania na telefonie znajduje się w sekcji **Releases** tego repozytorium.

- [Kliknij tutaj, aby pobrać najnowsze wydanie](https://github.com/[TWOJA_NAZWA_UZYTKOWNIKA]/goodloop/releases)

---

## 🛠️ Technologie

**Frontend:**

- 🎯 **Flutter & Dart:** Wydajność i cross-platformowość.
- 📦 **Riverpod:** Zarządzanie stanem (State Management).
- 🎨 **Material Design 3:** Nowoczesny interfejs użytkownika.
- ✨ **flutter_animate & confetti:** Płynne animacje i efekty nagradzania.

**Backend & Usługi:**

- 🔥 **Firebase Auth:** Logowanie i rejestracja.
- ☁️ **Cloud Firestore:** Baza danych NoSQL w czasie rzeczywistym.
- 🗄️ **Appwrite Storage / Firebase Storage:** Przechowywanie zdjęć profilowych.
- 🔔 **Flutter Local Notifications:** Lokalne powiadomienia przypominające o zadaniach.

---

## 📊 Zgodność z Hack Heroes 2025

| Wymaganie                | Status | Szczegóły                                     |
| :----------------------- | :----: | :-------------------------------------------- |
| **Aplikacja mobilna**    |   ✅   | Android (APK dostępne)                        |
| **Kod źródłowy**         |   ✅   | GitHub Public Repo                            |
| **Cel społeczny**        |   ✅   | Promowanie życzliwości i zdrowia psychicznego |
| **Instalacja < 10 min**  |   ✅   | `flutter run` + APK                           |
| **Możliwość kompilacji** |   ✅   | Standardowy stack Fluttera                    |
| **Prawa autorskie**      |   ✅   | Własny kod i zasoby open source               |

---

## 👥 Zespół

**Autor:** [Twoje Imię i Nazwisko]
**Szkoła:** [Pełna Nazwa Szkoły]
**Klasa:** [np. 3 Technikum Informatyczne]
**Opiekun:** [Imię i Nazwisko Opiekuna] (opcjonalnie)

---

## 📄 Licencja

Projekt udostępniony na licencji **MIT**.
Copyright (c) 2025 [Twoje Imię i Nazwisko].

_Aplikacja stworzona w ramach konkursu Hack Heroes 2025 organizowanego przez Fundację Media 3.0._

<div align="center">
	<br>
	Stworzone z 💝 i ☕
	<br>
	<i>Każdy mały akt dobroci ma znaczenie.</i>
</div>
