📱 Instrukcja Uruchomienia – GoodLoop

Hack Heroes 2025

⏱️ Szacowany czas konfiguracji: 10–15 minut

Poniższy przewodnik opisuje szczegółowy proces uruchomienia aplikacji GoodLoop w środowisku deweloperskim wraz z pełną konfiguracją usług Firebase, niezbędnych do działania aplikacji.

📋 1. Wymagania techniczne

Aby skompilować i uruchomić projekt z kodu źródłowego, Twoje środowisko musi spełniać następujące wymagania:

Flutter SDK: Wersja 3.0 lub nowsza (kanał stable).

Git: Klient do pobrania repozytorium.

Środowisko IDE: Zalecane Android Studio lub Visual Studio Code z wtyczkami Flutter/Dart.

Urządzenie:

Fizyczny telefon z Androidem (włączone debugowanie USB).

Lub Emulator Androida (skonfigurowany w Android Studio).

✅ Sprawdź konfigurację:
Uruchom poniższą komendę w terminalu, aby upewnić się, że wszystko jest gotowe:

flutter doctor

🚀 2. Pobieranie i Instalacja Zależności

Krok 2.1: Klonowanie repozytorium

Otwórz terminal w folderze, w którym chcesz zapisać projekt, i wykonaj komendę:

git clone [https://github.com/Wojsonexe/goodloop.git](https://github.com/Wojsonexe/goodloop.git)

Krok 2.2: Instalacja bibliotek

Przejdź do katalogu projektu i pobierz wszystkie wymagane paczki Fluttera:

cd goodloop
flutter pub get

🔥 3. Konfiguracja Firebase (Kluczowe!)

Aplikacja korzysta z Firebase do logowania użytkowników oraz przechowywania zadań w czasie rzeczywistym. Ze względów bezpieczeństwa plik google-services.json nie znajduje się w repozytorium – musisz wygenerować własny.

Krok 3.1: Utworzenie projektu

Przejdź do Konsoli Firebase.

Kliknij "Dodaj projekt" (Add project).

Nazwij go dowolnie, np. goodloop-dev (Google Analytics możesz wyłączyć).

Krok 3.2: Dodanie aplikacji Android

W panelu głównym projektu kliknij ikonę Androida (zielony robot).

W polu "Nazwa pakietu Androida" (Android package name) wpisz dokładnie:
com.goodloop.app

Kliknij "Zarejestruj aplikację" (Register app).

Pobierz plik google-services.json.

Przenieś pobrany plik do folderu w projekcie:
android/app/google-services.json

Krok 3.3: Włączenie Uwierzytelniania (Auth)

W menu po lewej wybierz Build -> Authentication.

Kliknij Get started.

W zakładce "Sign-in method" wybierz Email/Password.

Włącz opcję Enable i kliknij Save.

Krok 3.4: Konfiguracja Bazy Danych (Firestore)

W menu po lewej wybierz Build -> Firestore Database.

Kliknij Create database.

Wybierz lokalizację (np. eur3 - europe-west).

Wybierz tryb Test Mode (pozwala na łatwy odczyt/zapis podczas testów).

Kliknij Create.

📂 4. Inicjalizacja Danych (Zadania)

Aby aplikacja po uruchomieniu nie była pusta, musisz dodać "bank zadań", z którego aplikacja będzie korzystać.

W konsoli Firestore kliknij Start collection.

Wpisz ID kolekcji: dailyTasks (wielkość liter ma znaczenie!).

Dodaj pierwszy dokument (kliknij Auto-ID) i uzupełnij pola:

Pole

Typ

Wartość (Przykładowa)

text

string

Pochwal kogoś szczerze dziś

description

string

Może to być kolega z pracy, szkoły lub domownik.

category

string

kindness

difficulty

number

1

💡 Możesz dodać więcej dokumentów w tej kolekcji, aby pula zadań była większa.

▶️ 5. Uruchomienie Aplikacji

Podłącz telefon lub uruchom emulator, a następnie w terminalu projektu wpisz:

flutter run

Aplikacja powinna się skompilować, zainstalować i uruchomić. Po rejestracji nowego konta powinieneś zobaczyć zadanie dodane w punkcie 4.

🐛 Rozwiązywanie Problemów

Problem

Możliwa przyczyna i rozwiązanie

Błąd: google-services.json missing

Plik konfiguracyjny nie został znaleziony. Upewnij się, że znajduje się w folderze android/app/, a nie w głównym folderze android/.

Komunikat: No active tasks for today

Aplikacja działa, ale baza jest pusta lub źle nazwana. Sprawdź, czy kolekcja w Firestore nazywa się dokładnie dailyTasks i czy ma w środku dokumenty.

Błąd: Permission denied

Sprawdź zakładkę "Rules" w Firestore. Dla testów powinny wyglądać tak: allow read, write: if request.auth != null;.

📦 Gotowa wersja (APK)

Dla Jury oraz osób nietechnicznych udostępniamy gotowy plik instalacyjny, który nie wymaga konfiguracji środowiska.

👉 Pobierz GoodLoop.apk z sekcji Releases

<div align="center">
<i>Dokumentacja przygotowana na potrzeby konkursu Hack Heroes 2025.

Zespół GoodLoop</i>

</div>
