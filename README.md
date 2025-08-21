# Pzemysław Kubik

Dema wszystkich aplikacji znajdują się w folderze `demos/` !

**Zadanie 1** Tic Tac Toe

:white_check_mark: 5.0: wszystkie wymagania:
https://github.com/Onarix/scripts25/commit/34217d7998cbbc9d5f646ac341e650c0164180d9

Kod folder: 1.tictactoe
#

**Zadanie 2** Sklep ReactJS + NodeJS

Wszystkie wymagania: https://github.com/Onarix/scripts25/commit/0decd0961558abea6ceecbaf42500318cc78dcf3

:white_check_mark: 3.0 – Podstawowe endpointy w Node.js (Express)

```
GET /api/products

GET /api/categories

POST /api/transactions
```
To są podstawowe REST API endpointy do obsługi sklepu.

:white_check_mark: 3.5 – Dane zapisywane w bazie danych po stronie Node.js
Produkty i kategorie są w SQLite.

Transakcje są zapisywane w bazie przez Node.js po stronie backendu.

:white_check_mark:  4.0 – Axios wykorzystywany do wywołań
Frontend (React) używa axios.post i axios.get do komunikacji z backendem.

Przykład: wysyłanie transakcji przez axios.post('/transactions', {...})

:white_check_mark:  4.5 – Koszyk i płatność działają na React Hook
Koszyk jest zarządzany przez useState.

Funkcja pay() działa na stanie komponentu → React Hook.

:white_check_mark: 5.0 – Konfiguracja CORS
Backend (Node.js) ma:

```js
const cors = require('cors');
app.use(cors());
```

Frontend wywołuje zapytania na odpowiedni adres (np. http://localhost:3001).

CORS działa i jest skonfigurowany.
#

**Zadanie 3** Mario w PhaserJS

:white_check_mark: 3.0 - Należy stworzyć jeden poziom z przeszkodami oraz dziurami w które
można wpaść i zginąć
https://github.com/Onarix/scripts25/commit/cdd9d3d618ee82dc44a40fd9d1928b881ac93415

#

**Zadanie 4** Crawler w Ruby

:white_check_mark: 3.0 -  Należy pobrać podstawowe dane o produktach (tytuł, cena), dowolna
kategoria
https://github.com/Onarix/scripts25/commit/043a16b7726219066940f1a596b89e40c8472a16

:white_check_mark: 3.5 -  Należy pobrać podstawowe dane o produktach wg słów kluczowych
https://github.com/Onarix/scripts25/commit/81a1ab3e877b5ea94d15d44b672485a2b44f7041

#
