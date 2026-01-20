-- ===========================================
-- MIGRACE: Pridani participant_id pro sledovani ucastniku
-- ===========================================
-- Spustte tento SQL v Supabase SQL Editoru

-- Pridat sloupec participant_id do responses
ALTER TABLE responses ADD COLUMN IF NOT EXISTS participant_id TEXT;

-- Index pro rychlejsi vyhledavani podle ucastnika
CREATE INDEX IF NOT EXISTS idx_responses_participant_id ON responses(participant_id);
