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
├── index.html                   # Rozhraní pro účastníky
├── admin/index.html             # Admin rozhraní
├── supabase-schema.sql          # Staré SQL schéma (jen 1 otázka)
├── supabase-migration.sql       # Aktuální schéma s historií otázek
├── supabase-add-participant.sql # Migrace pro přidání participant_id
├── netlify.toml                 # Konfigurace Netlify
├── .env.example                 # Šablona pro env proměnné
├── CLAUDE.md                    # Instrukce pro Claude Code
└── README.md                    # Tento soubor
```

## Setup Supabase

### 1. Vytvoř projekt
- Jdi na https://supabase.com
- Create new project
- Zapamatuj si **Project URL** a **anon key** (Settings → API)

### 2. Spusť SQL schéma
V Supabase SQL Editoru spusť obsah `supabase-migration.sql` (nové schéma s historií):
- Vytvoří tabulky `questions` a `responses`
- Přidá sloupec `is_active` pro označení aktivní otázky
- Nastaví RLS policies (veřejný přístup)
- Zapne realtime pro obě tabulky

Poté spusť `supabase-add-participant.sql` pro přidání identifikace účastníků.

**Poznámka:** Soubor `supabase-schema.sql` obsahuje staré schéma (bez historie). Pro nové instalace použij `supabase-migration.sql`.

### 3. Environment variables
Supabase credentials jsou v kódu jako konstanty (pro jednoduchost). Alternativně je lze nastavit přes Netlify env variables.

## Deployment na Netlify

### 1. Propoj GitHub repo
- https://app.netlify.com → Add new site → Import from Git
- Vyber repozitář
- Build command: (prázdné, není potřeba)
- Publish directory: `.`

### 2. Nastav environment variables (volitelné)
Site settings → Environment variables:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 3. Deploy
Každý push do `main` automaticky deployne.

## Lokální vývoj

Prostě otevři `index.html` v prohlížeči. Pro plnou funkcionalitu potřebuješ:
1. Mít vytvořený Supabase projekt
2. Mít spuštěné SQL migrace
3. Mít správné credentials v kódu

## Databázové schéma

```sql
questions (historie všech otázek)
├── id: BIGSERIAL PRIMARY KEY
├── text: TEXT NOT NULL
├── is_active: BOOLEAN DEFAULT true
└── created_at: TIMESTAMP

responses
├── id: BIGSERIAL PRIMARY KEY
├── question_id: BIGINT (FK -> questions.id, ON DELETE CASCADE)
├── participant_id: TEXT (UUID z localStorage účastníka)
├── text: TEXT NOT NULL
└── created_at: TIMESTAMP
```

Otázky a odpovědi se trvale uchovávají v databázi. Sloupec `is_active` označuje aktuálně zobrazenou otázku.

### Identifikace účastníků
Každý účastník dostane při první návštěvě náhodné UUID uložené do localStorage. Toto ID se posílá s každou odpovědí, což umožňuje sledovat odpovědi jednoho účastníka napříč více otázkami.

## Klíčové funkce

### Admin
- **Publikovat otázku** – deaktivuje předchozí otázku, vytvoří novou aktivní
- **Ukončit otázku** – nastaví `is_active = false`
- **Historie** – přehled všech minulých otázek s odpověďmi

### Účastník
- Vidí aktuální otázku v reálném čase
- Může odeslat odpověď
- Realtime subscription zobrazuje aktivní otázku okamžitě

### Realtime
Supabase channels na `questions` a `responses` tabulky. Změny se propagují všem klientům automaticky.

## Možná rozšíření

- [ ] Ochrana admin rozhraní heslem (query param `?admin=secret`)
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
