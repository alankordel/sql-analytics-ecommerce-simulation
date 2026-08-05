$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath '.env')) {
    throw 'Arquivo .env não encontrado. Copie .env.example para .env antes de continuar.'
}

docker compose exec -T mysql bash /workspace/scripts/validate.sh

if ($LASTEXITCODE -ne 0) {
    throw 'As validações SQL falharam.'
}
