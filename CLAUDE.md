# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## O projektu

Workshop Q&A – webová aplikace pro interaktivní otázky a odpovědi na workshopech. Admin publikuje otázky, účastníci odpovídají v reálném čase.

## Architektura

- **Frontend**: Statické HTML + vanilla JS + inline CSS (žádný build, žádný framework)
- **Backend**: Supabase (Postgres + Realtime subscriptions přes WebSocket)
- **Hosting**: Netlify (statický deploy, žádný build step)

Dvě nezávislé HTML stránky:
- `index.html` – rozhraní účastníka (zobrazí aktivní otázku, umožní odpovědět)
- `admin/index.html` – admin panel (publikuje otázky, vidí odpovědi a historii)

Obě stránky sdílejí stejné Supabase credentials (hardcoded konstanty `SUPABASE_URL` a `SUPABASE_ANON_KEY`). Supabase JS klient se načítá z CDN.

## Lokální vývoj

Žádný build, žádné závislosti. Stačí otevřít HTML soubory v prohlížeči. Pro funkční Supabase připojení musí být v kódu platné credentials.

## Datový tok

1. Admin volá `publishQuestion()` → deaktivuje předchozí otázku (`is_active = false`), vloží novou (`is_active = true`)
2. Supabase Realtime propaguje změnu → účastník okamžitě vidí novou otázku
3. Účastník volá `submitAnswer()` → vloží odpověď s `question_id` a `participant_id`
4. Supabase Realtime propaguje novou odpověď → admin ji okamžitě vidí

## Databáze

Dvě tabulky: `questions` (s `is_active` boolean) a `responses` (s FK na `question_id` a `participant_id`).

SQL migrace v pořadí:
1. `supabase-schema.sql` – staré schéma (jen 1 otázka, nepoužívat pro nové instalace)
2. `supabase-migration.sql` – aktuální schéma (historie otázek, `is_active` sloupec)
3. `supabase-add-participant.sql` – přidání `participant_id` sloupce

## Identifikace účastníků

Každý účastník má UUID v `localStorage` (klíč `workshop_participant_id`), generuje se přes `crypto.randomUUID()` při první návštěvě. Posílá se s každou odpovědí.

## Deploy

Push do `main` → Netlify automaticky deployne. Publish directory je root (`"."`).

## TODO

- Ochrana admin rozhraní heslem
- QR kód s URL pro účastníky
- Export odpovědí do CSV
