-- ===========================================
-- MIGRACE: Trvale ukladani otazek a odpovedi
-- ===========================================
-- Spustte tento SQL v Supabase SQL Editoru
-- POZOR: Nejprve zalohovane data, pokud nejake mate!

-- 1. Smazat stare tabulky (v opacnem poradi kvuli foreign keys)
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS questions;

-- 2. Vytvorit novou tabulku questions (bez omezeni na jednu otazku)
CREATE TABLE questions (
    id BIGSERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Vytvorit tabulku responses
CREATE TABLE responses (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT REFERENCES questions(id) ON DELETE CASCADE,
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
CREATE POLICY "Otazky jsou verejne citelne"
    ON questions FOR SELECT
    USING (true);

CREATE POLICY "Kdokoliv muze spravovat otazky"
    ON questions FOR ALL
    USING (true);

-- Politiky pro responses
CREATE POLICY "Odpovedi jsou verejne citelne"
    ON responses FOR SELECT
    USING (true);

CREATE POLICY "Kdokoliv muze pridavat odpovedi"
    ON responses FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Kdokoliv muze mazat odpovedi"
    ON responses FOR DELETE
    USING (true);

-- ===========================================
-- REALTIME
-- ===========================================

-- Povolit realtime pro obe tabulky
ALTER PUBLICATION supabase_realtime ADD TABLE questions;
ALTER PUBLICATION supabase_realtime ADD TABLE responses;

-- ===========================================
-- INDEXY
-- ===========================================

CREATE INDEX idx_questions_is_active ON questions(is_active) WHERE is_active = true;
CREATE INDEX idx_questions_created_at ON questions(created_at DESC);
CREATE INDEX idx_responses_question_id ON responses(question_id);
CREATE INDEX idx_responses_created_at ON responses(created_at DESC);
