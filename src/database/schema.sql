-- ===========================================
-- SCHEMA DO BANCO DE DADOS - RECRUTADOR
-- Execute no SQL Editor do Supabase:
-- https://supabase.com/dashboard → Projeto → SQL Editor
-- ===========================================

-- Empresas
CREATE TABLE IF NOT EXISTS companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    logo_url TEXT,
    website VARCHAR(500),
    description TEXT,
    industry VARCHAR(100),
    company_size VARCHAR(50),
    location VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Vagas
CREATE TABLE IF NOT EXISTS jobs (
    id BIGSERIAL PRIMARY KEY,
    external_id VARCHAR(255),
    source VARCHAR(50) NOT NULL,
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500),
    description TEXT,
    company_id BIGINT REFERENCES companies(id),
    company_name VARCHAR(255),
    location VARCHAR(255),
    location_type VARCHAR(50),
    job_type VARCHAR(50),
    salary_min DECIMAL(12,2),
    salary_max DECIMAL(12,2),
    salary_currency VARCHAR(10) DEFAULT 'BRL',
    category VARCHAR(100),
    tags TEXT[],
    experience_level VARCHAR(50),
    apply_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    published_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(source, external_id)
);

-- Histórico de importações
CREATE TABLE IF NOT EXISTS import_logs (
    id BIGSERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,
    jobs_fetched INTEGER DEFAULT 0,
    jobs_inserted INTEGER DEFAULT 0,
    jobs_updated INTEGER DEFAULT 0,
    errors INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'running'
);

-- ===========================================
-- ÍNDICES
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_jobs_source ON jobs(source);
CREATE INDEX IF NOT EXISTS idx_jobs_location_type ON jobs(location_type);
CREATE INDEX IF NOT EXISTS idx_jobs_job_type ON jobs(job_type);
CREATE INDEX IF NOT EXISTS idx_jobs_category ON jobs(category);
CREATE INDEX IF NOT EXISTS idx_jobs_is_active ON jobs(is_active);
CREATE INDEX IF NOT EXISTS idx_jobs_published_at ON jobs(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_jobs_company_name ON jobs(company_name);
CREATE INDEX IF NOT EXISTS idx_companies_name ON companies(name);
CREATE INDEX IF NOT EXISTS idx_companies_slug ON companies(slug);

-- ===========================================
-- ROW LEVEL SECURITY (RLS)
-- Permite leitura pública, escrita apenas via service_key
-- ===========================================
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_logs ENABLE ROW LEVEL SECURITY;

-- Políticas de leitura pública
CREATE POLICY "Vagas são públicas" ON jobs
    FOR SELECT USING (true);

CREATE POLICY "Empresas são públicas" ON companies
    FOR SELECT USING (true);

CREATE POLICY "Logs são públicos" ON import_logs
    FOR SELECT USING (true);

-- Políticas de escrita (apenas service_role)
CREATE POLICY "Service pode inserir vagas" ON jobs
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service pode atualizar vagas" ON jobs
    FOR UPDATE USING (auth.role() = 'service_role');

CREATE POLICY "Service pode inserir empresas" ON companies
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service pode atualizar empresas" ON companies
    FOR UPDATE USING (auth.role() = 'service_role');

CREATE POLICY "Service pode inserir logs" ON import_logs
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service pode atualizar logs" ON import_logs
    FOR UPDATE USING (auth.role() = 'service_role');
