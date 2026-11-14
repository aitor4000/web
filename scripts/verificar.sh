#!/usr/bin/env bash
# shellcheck disable=SC2015  # ok() siempre devuelve 0: «cond && ok || ko» no ejecuta ko por error.
# Comprobaciones de DNS y HTTP de aitorrioja.com contra el estado documentado en CONTEXT.md.
# Uso: scripts/verificar.sh [dns|http|todo]   (por defecto: todo)
# Compatible con el bash 3.2 de macOS. Requiere dig y curl.
set -u

D="aitorrioja.com"
W="www.${D}"
R="1.1.1.1"            # resolver público, para no depender de cachés locales
GH_USER="aitor4000"
CANON="https://${D}/"
modo="${1:-todo}"
fallos=0

ok() { printf '  OK     %s\n' "$1"; }
ko() { printf '  FALLO  %s\n' "$1"; fallos=$((fallos + 1)); }
q()  { dig +short @"$R" "$@"; }
lista() { tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'; }

check_dns() {
  echo "DNS (resolver ${R})"

  local esperado obtenido
  esperado=$(echo 185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153 | lista)
  obtenido=$(q "$D" A | lista)
  [ "$obtenido" = "$esperado" ] && ok "A del apex: GitHub Pages" || ko "A del apex: '${obtenido}'"

  esperado=$(echo 2606:50c0:8000::153 2606:50c0:8001::153 2606:50c0:8002::153 2606:50c0:8003::153 | lista)
  obtenido=$(q "$D" AAAA | lista)
  [ "$obtenido" = "$esperado" ] && ok "AAAA del apex: GitHub Pages" || ko "AAAA del apex: '${obtenido}'"

  obtenido=$(q "$W" CNAME)
  [ "$obtenido" = "${GH_USER}.github.io." ] && ok "CNAME de www: ${GH_USER}.github.io" || ko "CNAME de www: '${obtenido}'"

  obtenido=$(q "nx-${RANDOM}${RANDOM}.${D}" A)
  [ -z "$obtenido" ] && ok "sin registro comodín" || ko "hay comodín: un subdominio inventado resuelve a '${obtenido}'"

  obtenido=$(q "$D" MX | sort | tr '\n' ' ')
  case "$obtenido" in
    *"10 fwd1.porkbun.com."*"20 fwd2.porkbun.com."*|*"20 fwd2.porkbun.com."*"10 fwd1.porkbun.com."*) ok "MX: reenvío de Porkbun" ;;
    *) ko "MX: '${obtenido}'" ;;
  esac

  local spf
  spf=$(q "$D" TXT | grep -c 'v=spf1')
  if [ "$spf" -ne 1 ]; then ko "SPF: hay ${spf} registros (debe haber 1)"
  elif q "$D" TXT | grep 'v=spf1' | grep -q 'include:_spf.porkbun.com'; then ok "SPF: único, incluye Porkbun"
  else ko "SPF: no incluye _spf.porkbun.com"; fi

  q "_dmarc.${D}" TXT | grep -q 'v=DMARC1; *p=reject' && ok "DMARC p=reject" || ko "DMARC ausente o sin p=reject"

  [ -n "$(q "_github-pages-challenge-${GH_USER}.${D}" TXT)" ] && ok "TXT de verificación de GitHub presente" || ko "falta el TXT de verificación de GitHub"

  [ -z "$(q "_acme-challenge.${D}" TXT)" ] && ok "sin TXT _acme-challenge residuales" || ko "quedan TXT _acme-challenge"
}

check_http() {
  echo "HTTP"
  local u r
  for u in "http://${D}/" "http://${W}/" "https://${W}/" "https://${D}/"; do
    r=$(curl -sS -L -o /dev/null --max-time 20 -w '%{url_effective} %{http_code}' "$u" 2>&1)
    [ "$r" = "${CANON} 200" ] && ok "${u} termina en ${CANON} (200)" || ko "${u} -> ${r}"
  done

  r=$(curl -sS -o /dev/null --max-time 20 -w '%{http_code} %{redirect_url}' "https://${W}/" 2>&1)
  [ "$r" = "301 ${CANON}" ] && ok "www redirige con 301 al apex" || ko "redirección de www: '${r}'"

  r=$(curl -sS -o /dev/null --max-time 20 -w '%{http_code} %{redirect_url}' "http://${D}/" 2>&1)
  [ "$r" = "301 ${CANON}" ] && ok "HTTP redirige con 301 a HTTPS" || ko "HTTP a HTTPS: '${r}' (¿Enforce HTTPS activado?)"

  curl -sS --max-time 20 "$CANON" | grep -q 'Aitor Rioja</h1>' && ok "el contenido se lee sin JavaScript" || ko "no aparece el h1 esperado"
}

case "$modo" in
  dns)  check_dns ;;
  http) check_http ;;
  todo) check_dns; check_http ;;
  *) echo "Uso: $0 [dns|http|todo]"; exit 2 ;;
esac

echo
if [ "$fallos" -eq 0 ]; then echo "Todo correcto."; else echo "${fallos} comprobación(es) fallida(s)."; fi
exit $(( fallos > 0 ))
