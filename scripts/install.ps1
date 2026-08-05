$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath '.env')) {
    throw 'Arquivo .env não encontrado. Copie .env.example para .env antes de continuar.'
}

docker compose exec -T mysql bash /workspace/scripts/install.sh

if ($LASTEXITCODE -ne 0) {
    throw 'A instalação do banco falhou.'
}
