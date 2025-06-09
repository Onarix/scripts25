# 🛒 React + Node.js Sklep Internetowy

Prosty sklep internetowy z backendem opartym na Node.js (Express + SQLite) oraz frontendem w React. Aplikacja umożliwia przeglądanie produktów, dodawanie ich do koszyka i symulację płatności z zapisem transakcji w bazie danych.

---

## 📦 Wymagania

- Node.js (v16+)
- npm (Node Package Manager)
- opcjonalnie: `sqlite3` do podglądu danych

---

## 📁 Struktura projektu
```
shopJS/
├── backend/ ← Node.js + SQLite (Express API)
└── frontend/ ← React + Axios (User API)
```

---

## 🖥️ Backend – `backend/`

### 🔧 Instalacja

```bash
cd backend
npm install
```

### ▶️ Uruchomienie

```bash
node index.js
```
Serwer uruchomi się na:
```
http://localhost:3000
```

## 🌐 Frontend – `frontend/`

### 🔧 Instalacja
```bash
cd frontend
npm install
```

### ▶️ Uruchomienie
```bash
npm start
```
Aplikacja dostępna będzie pod:
```
http://localhost:3000
```
