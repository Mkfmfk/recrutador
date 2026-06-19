# 🚀 Recrutador - Agregador de Vagas

Sistema de agregação de vagas de emprego que puxa dados de múltiplas APIs públicas e armazena em PostgreSQL (AWS RDS).

## 📦 Fontes de Vagas

| API | Precisa de Key? | Cobertura | Status |
|-----|----------------|-----------|--------|
| RemoteOK | ❌ Não | Global (remotas) | ✅ Pronto |
| Arbeitnow | ❌ Não | Europa (remotas) | ✅ Pronto |
| The Muse | ❌ Opcional | EUA | ✅ Pronto |
| Adzuna | ✅ Sim (grátis) | Global + Brasil | ✅ Pronto |
| Jooble | ✅ Sim (grátis) | Global + Brasil | ✅ Pronto |
| Reed | ✅ Sim (grátis) | Reino Unido | ✅ Pronto |

## 🏁 Quick Start

### 1. Instalar dependências
```bash
npm install
```

### 2. Preview (sem banco de dados)
Busca vagas e salva em `data/vagas-preview.json`:
```bash
node src/preview-jobs.js
```

### 3. Configurar banco AWS
```bash
# Copie e configure o .env
copy .env.example .env

# Deploy do RDS via CloudFormation
aws cloudformation create-stack \
  --stack-name recrutador-db \
  --template-body file://aws/cloudformation-rds.yaml \
  --parameters ParameterKey=DBPassword,ParameterValue=SuaSenhaSegura123

# Após o RDS estar pronto, execute o schema
npm run setup-db
```

### 4. Importar vagas para o banco
```bash
npm run fetch-jobs
```

## 🔑 Obtendo API Keys (gratuitas)

1. **Adzuna**: https://developer.adzuna.com/ (cadastro + aprovação em ~24h)
2. **Jooble**: https://jooble.org/api/about (cadastro instantâneo)
3. **Reed**: https://www.reed.co.uk/developers/jobseeker (cadastro + aprovação)
4. **The Muse**: https://www.themuse.com/developers/api/v2 (opcional, funciona sem)

## 🗄️ Estrutura do Banco

- `companies` - Empresas que publicam vagas
- `jobs` - Vagas de emprego (com deduplicação por fonte)
- `import_logs` - Histórico de importações

## 📁 Estrutura do Projeto

```
Recrutador/
├── aws/
│   └── cloudformation-rds.yaml   # Infraestrutura AWS
├── data/
│   └── vagas-preview.json        # Preview das vagas (gerado)
├── src/
│   ├── database/
│   │   ├── schema.sql            # Schema PostgreSQL
│   │   ├── setup.js              # Script de setup do banco
│   │   └── db.js                 # Pool de conexões
│   ├── providers/
│   │   ├── remoteok.js           # API RemoteOK
│   │   ├── arbeitnow.js          # API Arbeitnow
│   │   ├── adzuna.js             # API Adzuna
│   │   ├── jooble.js             # API Jooble
│   │   ├── reed.js               # API Reed
│   │   └── themuse.js            # API The Muse
│   ├── fetchJobs.js              # Orquestrador de importação
│   └── preview-jobs.js           # Preview sem banco
├── .env.example                  # Template de configuração
├── package.json
└── README.md
```

## 🔄 Automatização (Cron)

Para buscar vagas automaticamente a cada 6 horas:
```bash
# Adicione ao crontab ou use AWS EventBridge + Lambda
0 */6 * * * cd /path/to/Recrutador && node src/fetchJobs.js
```

## 📈 Próximos Passos

- [ ] API REST para consultar vagas
- [ ] Frontend com busca e filtros
- [ ] Elasticsearch para full-text search
- [ ] Sistema de autenticação (empresas + candidatos)
- [ ] Painel admin
- [ ] Notificações por email
