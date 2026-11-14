<div align="right">
  <a href="./README.md"><img src="https://img.shields.io/badge/English-Switch_language-0A66C2?style=flat-square" alt="English"></a>
  <a href="./README.pl.md"><img src="https://img.shields.io/badge/Polski-Aktywny-dc143c?style=flat-square" alt="Polski"></a>
</div>

# Pomiar efektywności technicznej gospodarek europejskich a poziom PKB
### Studium empiryczne oparte na funkcjach Cobba-Douglasa, CES oraz Translog

**Autor:** Filip Gorczyca  
**Kierunek studiów:** Analityka Gospodarcza, Uniwersytet Ekonomiczny w Krakowie (UEK)

---

## Cel projektu
Empiryczna analiza makroekonomiczna i ekonometryczna oceniająca wpływ nakładów kapitału fizycznego oraz zasobów pracy na poziom realnego PKB i efektywność techniczną **9 gospodarek europejskich** (**Belgia, Szwajcaria, Niemcy, Hiszpania, Francja, Wielka Brytania, Włochy, Holandia oraz Polska**) w latach **2000-2022**.

W badaniu zestawiono trzy specyfikacje funkcji produkcji - **Cobba-Douglasa (CD)**, **funkcję o stałej elastyczności substytucji (CES)** oraz **elastyczną funkcję Translog** - w celu weryfikacji efektów skali, substytucyjności vs komplementarności czynników wytwórczych oraz wrażliwości ocen efektywności technicznej na wybór postaci analitycznej modelu.

---

## Dane i zmienne badawcze
* **Źródło danych:** Penn World Table (PWT) wersja 11.0 (dane panelowe z lat 2000-2022).
* **Zmienne w modelu:**
  * `rgdpna` ($Q$ / $Y$) - Realny PKB w cenach stałych z 2021 r. według parytetu siły nabywczej (w USD).
  * `rnna` ($K$) - Nakłady kapitału fizycznego w cenach stałych z 2021 r. (w USD).
  * `emp` ($L$) - Liczba osób pracujących w gospodarce (w mln osób).

### Statystyki opisowe badanych gospodarek (Średnia oraz zakres Min-Max)
| Kraj | Realny PKB (bln USD) | Zatrudnienie (mln osób) | Kapitał fizyczny (bln USD) |
| :--- | :---: | :---: | :---: |
| **Niemcy (DEU)** | 4,51 (3,98 - 5,11) | 42,24 (39,52 - 45,84) | 18,08 (15,57 - 20,76) |
| **Francja (FRA)** | 3,12 (2,69 - 3,52) | 27,64 (25,97 - 30,29) | 17,87 (14,63 - 20,96) |
| **Wielka Brytania (GBR)** | 2,99 (2,48 - 3,49) | 30,16 (27,44 - 33,21) | 13,92 (11,02 - 16,89) |
| **Włochy (ITA)** | 2,84 (2,62 - 3,00) | 24,67 (22,93 - 25,80) | 17,95 (14,99 - 19,80) |
| **Hiszpania (ESP)** | 1,88 (1,55 - 2,13) | 19,16 (16,71 - 21,16) | 11,27 (8,24 - 13,30) |
| **Holandia (NLD)** | 1,04 (0,89 - 1,26) | 8,96 (8,28 - 10,18) | 4,76 (3,89 - 5,61) |
| **Polska (POL)** | 1,04 (0,68 - 1,53) | 15,52 (13,58 - 17,78) | 2,50 (1,51 - 3,75) |
| **Szwajcaria (CHE)** | 0,65 (0,53 - 0,79) | 4,54 (3,94 - 5,14) | 2,99 (2,35 - 3,67) |
| **Belgia (BEL)** | 0,56 (0,47 - 0,67) | 4,52 (4,11 - 5,04) | 3,11 (2,40 - 3,89) |

---

## Metodologia ekonometryczna i implementacja w R
Skrypt obliczeniowy (`kod_R.R`) realizuje pełny proces estymacji i weryfikacji diagnostycznej na rachunku macierzowym:
1. **Model Cobba-Douglasa:** Macierzowy estymator MNK $\hat{\beta} = (X^T X)^{-1} X^T Y$, wyznaczenie macierzy kowariancji, testy $t$ dla efektu skali ($H_0: RTS = 1$) oraz technicznej stopy substytucji ($TRS$), a także pomiar efektywności technicznej metodą skorygowanych najmniejszych kwadratów (COLS).
2. **Model CES:** Aproksymacja Kmenty dla wyznaczenia punktów startowych oraz nieliniowa optymalizacja metodą Newtona (`micEconCES`) w wariantach ze składnikiem losowym multiplikatywnym i addytywnym (przy zmiennych i stałych efektach skali - VRS oraz CRS).
3. **Model Translog:** Pełna elastyczna postać drugiego rzędu z członami kwadratowymi i interakcją ($\ln L \cdot \ln K$, $\ln^2 L$, $\ln^2 K$), weryfikacja wklęsłości funkcji za pomocą wyznacznika obrzeżonej macierzy Hessego ($\det(BH) = 84,29 > 0$), elastyczność substytucji Allena ($AES_{LK}$), test $F$ zasadności rozszerzenia modelu względem Cobba-Douglasa ($p = 2,91 \times 10^{-25}$) oraz estymacja efektywności technicznej na bazie skośności reszt.

---

## Zestawienie wyników empirycznych

| Parametr / Wskaźnik | Cobb-Douglas (CD) | CES (Multiplikatywny VRS) | Translog (Elastyczny) |
| :--- | :---: | :---: | :---: |
| **Elastyczność względem pracy ($El_L$)** | 0,5354 | 0,5252 | 0,7003 |
| **Elastyczność względem kapitału ($El_K$)** | 0,4017 | 0,4127 | 0,2567 |
| **Efekt skali ($RTS$)** | 0,9371 (Malejące) | 0,9379 (Malejące) | 0,9569 (Malejące) |
| **Produkt krańcowy pracy ($MP_L$)** | 58 310,45 mln USD | 56 899,71 mln USD | 73 510,89 mln USD |
| **Produkt krańcowy kapitału ($MP_K$)** | 0,0900 mln USD | 0,0908 mln USD | 0,0517 mln USD |
| **Elastyczność substytucji ($\sigma$ / $DES$ / $AES$)** | 1,0000 (Stała) | 1,1996 (Substytuty) | 0,4410 (Komplementarne) |
| **Średnia efektywność techniczna ($TE$)** | 84,92% | 84,57% | 96,87% |

---

## Główne wnioski z badania
1. **Przewaga modelu elastycznego Translog:** Test $F$ na redukcję modelu ($p = 2,91 \times 10^{-25}$) jednoznacznie odrzuca restrykcyjną postać Cobba-Douglasa na rzecz funkcji Translog. Dodatni wyznacznik obrzeżonego Hesjanu ($84,29$) potwierdza wklęsłość funkcji i spełnienie prawa malejących przychodów krańcowych.
2. **Komplementarność kapitału i pracy:** Podczas gdy uproszczone modele dwuczynnikowe narzucają jednostkową substytucyjność (CD: $\sigma = 1$) lub wskazują na umiarkowaną zastępowalność (CES: $DES = 1,20$), lepiej dopasowany model Translog wykazuje silną komplementarność czynników wytwórczych oraz sztywność technologiczną ($AES = 0,44$).
3. **Wrażliwość ocen efektywności technicznej:** Sztywne założenia funkcyjne modeli CD i CES prowadzą do niedoszacowania efektywności badanych gospodarek (ok. 85%), natomiast uwzględnienie nieliniowych interakcji w modelu Translog wskazuje na wykorzystanie potencjału produkcyjnego na poziomie 96,87%.
4. **Dominująca rola pracy i malejące efekty skali:** We wszystkich trzech specyfikacjach elastyczność PKB względem nakładów pracy ($0,53 - 0,70$) przewyższa elastyczność względem kapitału fizycznego ($0,26 - 0,41$), a efekt skali kształtuje się nieznacznie poniżej jedności ($RTS \in [0,937; 0,957]$).

---

## Zawartość repozytorium
| Plik | Opis |
| :--- | :--- |
| [`kod_R.R`](./kod_R.R) | Skrypt w języku R zawierający estymację macierzową MNK, aproksymację Kmenty, optymalizację CES, wyznaczenie obrzeżonego Hesjanu i elastyczności Allena w modelu Translog oraz obliczenia efektywności technicznej. |
| [`POMIAR EFEKTYWNOSCI GOSPODAREK EUROPY.pdf`](./POMIAR%20EFEKTYWNOSCI%20GOSPODAREK%20EUROPY.pdf) | Pełne 24-stronicowe opracowanie empiryczne zawierające wyprowadzenia teoretyczne, tabele statystyczne oraz interpretację makroekonomiczną. |
