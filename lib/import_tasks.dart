import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> importDailyTasks() async {
  final firestore = FirebaseFirestore.instance;

  final data = {
    "task1": {
      "text": "Pochwał kogoś szczerze dziś",
      "difficulty": 1,
      "category": "kindness",
    },
    "task2": {
      "text": "Pomóż komuś z zadaniem domowym",
      "difficulty": 2,
      "category": "help",
    },
    "task3": {
      "text": "Wyślij wiadomość z podziękowaniem",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task4": {
      "text": "Podziel się czymś pomocnym z kimś",
      "difficulty": 1,
      "category": "sharing",
    },
    "task5": {
      "text": "Wysłuchaj kogoś bez przerywania",
      "difficulty": 2,
      "category": "presence",
    },
    "task6": {
      "text": "Uśmiechnij się do 5 osób dzisiaj",
      "difficulty": 1,
      "category": "kindness",
    },
    "task7": {
      "text": "Zrób coś miłego dla rodziny",
      "difficulty": 2,
      "category": "help",
    },
    "task8": {
      "text": "Napisz pozytywny komentarz online",
      "difficulty": 1,
      "category": "kindness",
    },
    "task9": {
      "text": "Pomóż komuś nieznajomemu",
      "difficulty": 3,
      "category": "help",
    },
    "task10": {
      "text": "Doceniaj małe rzeczy dzisiaj",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task11": {
      "text": "Zadzwoń do kogoś, kto czuje się samotnie",
      "difficulty": 2,
      "category": "presence",
    },
    "task12": {
      "text": "Podziel się swoją wiedzą z kimś",
      "difficulty": 1,
      "category": "sharing",
    },
    "task13": {
      "text": "Przytrzymaj komuś drzwi",
      "difficulty": 1,
      "category": "kindness",
    },
    "task14": {
      "text": "Pochwal czyjeś osiągnięcie publicznie",
      "difficulty": 1,
      "category": "kindness",
    },
    "task15": {
      "text": "Pomóż sprzątać w domu bez pytania",
      "difficulty": 2,
      "category": "help",
    },
    "task16": {
      "text": "Napisz list z podziękowaniem",
      "difficulty": 2,
      "category": "gratitude",
    },
    "task17": {
      "text": "Podaruj komuś swój czas",
      "difficulty": 3,
      "category": "presence",
    },
    "task18": {
      "text": "Zostaw pozytywną notatkę dla kogoś",
      "difficulty": 1,
      "category": "kindness",
    },
    "task19": {
      "text": "Pomóż w organizacji wydarzenia",
      "difficulty": 3,
      "category": "help",
    },
    "task20": {
      "text": "Podziel się posiłkiem z kimś",
      "difficulty": 2,
      "category": "sharing",
    },
    "task21": {
      "text": "Wysłuchaj czyichś problemów z empatią",
      "difficulty": 2,
      "category": "presence",
    },
    "task22": {
      "text": "Podziękuj osobie z obsługi",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task23": {
      "text": "Naucz kogoś newej umiejętności",
      "difficulty": 3,
      "category": "sharing",
    },
    "task24": {
      "text": "Powiedz komuś co w nim cenisz",
      "difficulty": 2,
      "category": "kindness",
    },
    "task25": {
      "text": "Pomóż komuś z zakupami",
      "difficulty": 2,
      "category": "help",
    },
    "task26": {
      "text": "Doceniaj rzeczy które masz",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task27": {
      "text": "Spędź czas jakości z bliską osobą",
      "difficulty": 2,
      "category": "presence",
    },
    "task28": {
      "text": "Podziel się inspirującą historią",
      "difficulty": 1,
      "category": "sharing",
    },
    "task29": {
      "text": "Zapytaj kogoś jak się czuje",
      "difficulty": 1,
      "category": "kindness",
    },
    "task30": {
      "text": "Pomóż w projekcie społecznym",
      "difficulty": 3,
      "category": "help",
    },
    "task31": {
      "text": "Napisz list z uznaniem do nauczyciela",
      "difficulty": 2,
      "category": "gratitude",
    },
    "task32": {
      "text": "Bądź w pełni obecny podczas rozmowy",
      "difficulty": 2,
      "category": "presence",
    },
    "task33": {
      "text": "Podziel się swoimi materiałami do nauki",
      "difficulty": 1,
      "category": "sharing",
    },
    "task34": {
      "text": "Pochwal czyjś styl lub wygląd",
      "difficulty": 1,
      "category": "kindness",
    },
    "task35": {
      "text": "Pomóż komuś z technologią",
      "difficulty": 2,
      "category": "help",
    },
    "task36": {
      "text": "Podziękuj za coś co uznawałeś za oczywiste",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task37": {
      "text": "Wyłącz telefon i porozmawiaj z kimś",
      "difficulty": 2,
      "category": "presence",
    },
    "task38": {
      "text": "Podziel się dobrą książką lub filmem",
      "difficulty": 1,
      "category": "sharing",
    },
    "task39": {
      "text": "Uśmiechnij się do swojego odbicia w lustrze",
      "difficulty": 1,
      "category": "kindness",
    },
    "task40": {
      "text": "Pomóż komuś uporządkować przestrzeń",
      "difficulty": 2,
      "category": "help",
    },
    "task41": {
      "text": "Napisz dziennik wdzięczności",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task42": {
      "text": "Zagraj z kimś w grę bez patrzenia w telefon",
      "difficulty": 2,
      "category": "presence",
    },
    "task43": {
      "text": "Podziel się pomysłem który komuś pomoże",
      "difficulty": 1,
      "category": "sharing",
    },
    "task44": {
      "text": "Zapytaj kogoś o jego dzień",
      "difficulty": 1,
      "category": "kindness",
    },
    "task45": {
      "text": "Pomóż w przygotowaniu posiłku",
      "difficulty": 2,
      "category": "help",
    },
    "task46": {
      "text": "Podziękuj za piękną pogodę",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task47": {
      "text": "Słuchaj muzyki razem z kimś",
      "difficulty": 1,
      "category": "presence",
    },
    "task48": {
      "text": "Podziel się swoimi notatkami",
      "difficulty": 1,
      "category": "sharing",
    },
    "task49": {
      "text": "Powiedz komuś że w niego wierzysz",
      "difficulty": 2,
      "category": "kindness",
    },
    "task50": {
      "text": "Pomóż komuś w problemie technicznym",
      "difficulty": 2,
      "category": "help",
    },
    "task51": {
      "text": "Doceniaj swoje własne wysiłki",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task52": {
      "text": "Idź na spacer z kimś i rozmawiaj",
      "difficulty": 2,
      "category": "presence",
    },
    "task53": {
      "text": "Podziel się przepisem kulinarnym",
      "difficulty": 1,
      "category": "sharing",
    },
    "task54": {
      "text": "Pochwal czyjś wysiłek nie rezultat",
      "difficulty": 2,
      "category": "kindness",
    },
    "task55": {
      "text": "Pomóż komuś z nauką języka",
      "difficulty": 3,
      "category": "help",
    },
    "task56": {
      "text": "Napisz 3 rzeczy za które jesteś wdzięczny",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task57": {
      "text": "Zorganizuj wspólne wyjście",
      "difficulty": 3,
      "category": "presence",
    },
    "task58": {
      "text": "Podziel się swoimi narzędziami",
      "difficulty": 1,
      "category": "sharing",
    },
    "task59": {
      "text": "Napisz pozytywną recenzję lokalu",
      "difficulty": 1,
      "category": "kindness",
    },
    "task60": {
      "text": "Pomóż w wolontariacie",
      "difficulty": 3,
      "category": "help",
    },
    "task61": {
      "text": "Podziękuj rodzicom za wychowanie",
      "difficulty": 2,
      "category": "gratitude",
    },
    "task62": {
      "text": "Spędź wieczór bez technologii",
      "difficulty": 3,
      "category": "presence",
    },
    "task63": {
      "text": "Podziel się swoim ulubionym miejscem",
      "difficulty": 1,
      "category": "sharing",
    },
    "task64": {
      "text": "Pochwal czyjaś determinację",
      "difficulty": 1,
      "category": "kindness",
    },
    "task65": {
      "text": "Pomóż sąsiadowi z czymś",
      "difficulty": 2,
      "category": "help",
    },
    "task66": {
      "text": "Doceniaj swoje zdrowie dziś",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task67": {
      "text": "Obejrzyj film razem z kimś",
      "difficulty": 2,
      "category": "presence",
    },
    "task68": {
      "text": "Podziel się playlistą muzyczną",
      "difficulty": 1,
      "category": "sharing",
    },
    "task69": {
      "text": "Napisz miłą wiadomość na forum",
      "difficulty": 1,
      "category": "kindness",
    },
    "task70": {
      "text": "Pomóż w organizacji urodzin",
      "difficulty": 3,
      "category": "help",
    },
    "task71": {
      "text": "Podziękuj za drugą szansę",
      "difficulty": 2,
      "category": "gratitude",
    },
    "task72": {
      "text": "Pograj w planszówkę z rodziną",
      "difficulty": 2,
      "category": "presence",
    },
    "task73": {
      "text": "Podziel się swoją pasją z kimś",
      "difficulty": 2,
      "category": "sharing",
    },
    "task74": {
      "text": "Pochwal czyjaś pomoc",
      "difficulty": 1,
      "category": "kindness",
    },
    "task75": {
      "text": "Pomóż w przygotowaniu prezentacji",
      "difficulty": 2,
      "category": "help",
    },
    "task76": {
      "text": "Podziękuj za wspomnienia",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task77": {
      "text": "Gotuj razem z kimś",
      "difficulty": 2,
      "category": "presence",
    },
    "task78": {
      "text": "Podziel się linkiem do przydatnego artykułu",
      "difficulty": 1,
      "category": "sharing",
    },
    "task79": {
      "text": "Pochwal czyjaś kreatywność",
      "difficulty": 1,
      "category": "kindness",
    },
    "task80": {
      "text": "Pomóż komuś przygotować się do egzaminu",
      "difficulty": 3,
      "category": "help",
    },
    "task81": {
      "text": "Doceniaj małe przyjemności życia",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task82": {
      "text": "Idź na kawę i pogadaj z kimś",
      "difficulty": 2,
      "category": "presence",
    },
    "task83": {
      "text": "Podziel się swoją strategią uczenia się",
      "difficulty": 2,
      "category": "sharing",
    },
    "task84": {
      "text": "Pochwal czyjaś cierpliwość",
      "difficulty": 1,
      "category": "kindness",
    },
    "task85": {
      "text": "Pomóż w naprawie czegoś",
      "difficulty": 2,
      "category": "help",
    },
    "task86": {
      "text": "Podziękuj za przyjaźń",
      "difficulty": 2,
      "category": "gratitude",
    },
    "task87": {
      "text": "Zrób coś twórczego razem z kimś",
      "difficulty": 3,
      "category": "presence",
    },
    "task88": {
      "text": "Podziel się swoimi doświadczeniami",
      "difficulty": 2,
      "category": "sharing",
    },
    "task89": {
      "text": "Pochwal czyjaś uczciwość",
      "difficulty": 1,
      "category": "kindness",
    },
    "task90": {
      "text": "Pomóż w poszukiwaniu informacji",
      "difficulty": 2,
      "category": "help",
    },
    "task91": {
      "text": "Doceniaj możliwości które masz",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task92": {
      "text": "Spędź czas na naturze z kimś",
      "difficulty": 2,
      "category": "presence",
    },
    "task93": {
      "text": "Podziel się swoimi celami i motywuj innych",
      "difficulty": 2,
      "category": "sharing",
    },
    "task94": {
      "text": "Pochwal czyjaś odwagę",
      "difficulty": 1,
      "category": "kindness",
    },
    "task95": {
      "text": "Pomóż w planowaniu podróży",
      "difficulty": 2,
      "category": "help",
    },
    "task96": {
      "text": "Podziękuj za naukę którą otrzymałeś",
      "difficulty": 1,
      "category": "gratitude",
    },
    "task97": {
      "text": "Ćwicz razem z kimś",
      "difficulty": 2,
      "category": "presence",
    },
    "task98": {
      "text": "Podziel się swoimi zasobami edukacyjnymi",
      "difficulty": 1,
      "category": "sharing",
    },
    "task99": {
      "text": "Pochwal czyjaś dobroć",
      "difficulty": 1,
      "category": "kindness",
    },
    "task100": {
      "text": "Pomóż komuś osiągnąć jego cel",
      "difficulty": 3,
      "category": "help",
    },
  };

  final batch = firestore.batch();
  final collection = firestore.collection('dailyTasks');

  data.forEach((key, value) {
    batch.set(collection.doc(key), value);
  });

  await batch.commit();
  print("✔ Import zakończony!");
}
