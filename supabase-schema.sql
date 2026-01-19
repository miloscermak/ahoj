-- ===========================================
-- WORKSHOP Q&A - SUPABASE SCHÉMA
-- ===========================================
-- Spusťte tento SQL v Supabase SQL Editoru

-- Tabulka pro aktuální otázku (vždy max 1 záznam)
CREATE TABLE questions (
    id INTEGER PRIMARY KEY DEFAULT 1,
    text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT single_question CHECK (id = 1)
);

-- Tabulka pro odpovědi účastníků
CREATE TABLE responses (
    id BIGSERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- ROW LEVEL SECURITY (RLS)
-- ===========================================

-- Povolit RLS
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Politiky pro questions
-- Kdokoliv může číst otázky
CREATE POLICY "Otázky jsou veřejně čitelné" 
    ON questions FOR SELECT 
    USING (true);

-- Pouze autentizovaní mohou měnit (nebo všichni pro jednoduchost)
CREATE POLICY "Kdokoliv může spravovat otázky" 
    ON questions FOR ALL 
    USING (true);

-- Politiky pro responses
-- Kdokoliv může číst odpovědi
CREATE POLICY "Odpovědi jsou veřejně čitelné" 
    ON responses FOR SELECT 
    USING (true);

-- Kdokoliv může přidávat odpovědi
CREATE POLICY "Kdokoliv může přidávat odpovědi" 
    ON responses FOR INSERT 
    WITH CHECK (true);

-- Kdokoliv může mazat odpovědi (pro admina)
CREATE POLICY "Kdokoliv může mazat odpovědi" 
    ON responses FOR DELETE 
    USING (true);

-- ===========================================
-- REALTIME
-- ===========================================

-- Povolit realtime pro obě tabulky
ALTER PUBLICATION supabase_realtime ADD TABLE questions;
ALTER PUBLICATION supabase_realtime ADD TABLE responses;

-- ===========================================
-- INDEXY
-- ===========================================

CREATE INDEX idx_responses_question_id ON responses(question_id);
CREATE INDEX idx_responses_created_at ON responses(created_at DESC);
