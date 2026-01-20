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
├── index.html            # Rozhraní pro účastníky
├── admin/index.html      # Admin rozhraní
├── supabase-schema.sql   # SQL pro inicializaci databáze
├── supabase-migration.sql     # Migrace pro trvalé ukládání otázek
├── supabase-add-participant.sql # Migrace pro přidání participant_id
├── netlify.toml          # Konfigurace Netlify
├── .env.example          # Šablona pro env proměnné
└── CLAUDE.md             # Tento soubor
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

**Poznámka:** Soubor `supabase-schema.sql` obsahuje staré schéma (bez historie). Pro nové instalace použij `supabase-migration.sql`.

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
Každý účastník dostane při první návštěvě náhodné UUID uložené do localStorage. Toto ID se posílá s každou odpovědí, což umožňuje sledovat odpovědi jednoho účastníka napříč více otázkami v rámci session.

## Klíčové funkce

### Admin
- `publishQuestion()` - deaktivuje předchozí otázku, vytvoří novou aktivní otázku
- `deactivateQuestion()` - ukončí aktuální otázku (nastaví `is_active = false`)
- `loadHistory()` - načte historii všech otázek s odpověďmi

### Účastník
- `submitAnswer()` - insert do responses s `question_id` aktivní otázky
- Realtime subscription zobrazuje aktivní otázku okamžitě

### Realtime
Supabase channels na `questions` a `responses` tabulky. Změny se propagují všem klientům automaticky.

### Historie
Všechny otázky a odpovědi zůstávají v databázi. Admin rozhraní obsahuje sekci "Historie otázek" kde lze procházet minulé otázky a jejich odpovědi.

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
