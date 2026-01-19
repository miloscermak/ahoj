# Workshop Q&A

Jednoduchá webová aplikace pro interaktivní otázky a odpovědi na workshopech.

## Architektura

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│    ADMIN    │──────▶│   SUPABASE   │◀──────│  ÚČASTNÍCI  │
│  (tab)      │       │  (realtime)  │       │  (tab)      │
└─────────────┘       └──────────────┘       └─────────────┘
```

- **Frontend**: Statické HTML + vanilla JS (žádný framework)
- **Backend**: Supabase (Postgres + Realtime subscriptions)
- **Hosting**: Netlify (statický deploy z GitHub)

## Struktura projektu

```
/
├── index.html          # Hlavní aplikace (účastník + admin v tabech)
├── supabase-schema.sql # SQL pro inicializaci databáze
├── netlify.toml        # Konfigurace Netlify
├── .env.example        # Šablona pro env proměnné
└── CLAUDE.md           # Tento soubor
```

## Setup Supabase

### 1. Vytvoř projekt
- Jdi na https://supabase.com
- Create new project
- Zapamatuj si **Project URL** a **anon key** (Settings → API)

### 2. Spusť SQL schéma
V Supabase SQL Editoru spusť obsah `supabase-schema.sql`:
- Vytvoří tabulky `questions` a `responses`
- Nastaví RLS policies (veřejný přístup)
- Zapne realtime pro obě tabulky

### 3. Environment variables
Supabase credentials půjdou do kódu jako konstanty (pro jednoduchost) nebo přes Netlify env variables.

## Deployment na Netlify

### 1. Propoj GitHub repo
- https://app.netlify.com → Add new site → Import from Git
- Vyber repozitář
- Build command: (prázdné, není potřeba)
- Publish directory: `/` nebo `.`

### 2. Nastav environment variables (volitelné)
Pokud chceš credentials mimo kód:
- Site settings → Environment variables
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 3. Deploy
Každý push do `main` automaticky deployne.

## Vývoj

### Lokální testování
Prostě otevři `index.html` v prohlížeči. Pro plnou funkcionalitu potřebuješ:
1. Mít vytvořený Supabase projekt
2. Mít spuštěné SQL schéma
3. Mít správné credentials v kódu

### Workflow
1. Udělej změny lokálně
2. `git push` do GitHub
3. Netlify automaticky deployne
4. Testuj na produkční URL

## Databázové schéma

```sql
questions (vždy max 1 záznam)
├── id: 1 (fixed)
├── text: TEXT
└── created_at: TIMESTAMP

responses
├── id: BIGSERIAL
├── question_id: 1
├── text: TEXT
└── created_at: TIMESTAMP
```

## Klíčové funkce

### Admin
- `publishQuestion()` - upsert do questions, smaže staré responses
- `clearQuestion()` - smaže otázku
- `clearResponses()` - smaže všechny odpovědi

### Účastník
- `submitAnswer()` - insert do responses
- Realtime subscription zobrazuje otázku okamžitě

### Realtime
Supabase channels na `questions` a `responses` tabulky. Změny se propagují všem klientům automaticky.

## TODO / Možná rozšíření

- [ ] Ochrana admin tabu heslem (query param `?admin=secret`)
- [ ] QR kód s URL pro účastníky
- [ ] Export odpovědí do CSV
- [ ] Více otázek najednou (carousel)
- [ ] Hlasování o odpovědích

## Troubleshooting

### Realtime nefunguje
- Zkontroluj, že tabulky mají zapnutý realtime v Supabase (Database → Replication)
- Zkontroluj RLS policies

### CORS chyby
- Supabase by mělo fungovat z jakékoliv domény
- Pokud ne, přidej doménu do Supabase Auth settings

### Odpovědi se nezobrazují
- Otevři browser console, hledej chyby
- Ověř, že `question_id` v responses odpovídá existující otázce
