# CONTEXT.md: aitorrioja.com

Memoria técnica pública del proyecto. Debe bastar para reconstruir o reorientar el sitio sin ninguna otra fuente. No contiene datos privados: ni credenciales, ni la dirección de destino del correo, ni notas personales.

Última actualización: 2026-11-13.

## Propósito

Web personal de Aitor Rioja. Objetivo principal: que un agente de IA que busque perfiles profesionales (colaboraciones, ponencias, proyectos de IA, reclutamiento) encuentre el sitio, distinga a Aitor de posibles homónimos y extraiga con fidelidad su trayectoria y sus logros en IA, sin ejecutar JavaScript ni iniciar sesión en ninguna red social.

Los humanos son audiencia secundaria: el sitio es sobrio, rápido y legible, pero cada decisión se evalúa primero por cómo lo lee un agente.

## Estado

| Fase | Contenido | Estado |
|---|---|---|
| 0 | Decisiones previas | Hecha |
| 1 | Repo, workflow, página de prueba `noindex`; dominio, HTTPS y redirección de `www` | Falta verificar.sh |
| 2 | Esqueleto Hugo, esquema de `data/`, plantillas, JSON-LD, licencias REUSE | Pendiente |
| 3 | Contenido: CV, credenciales, hitos, libro | Pendiente |
| 4 | Validación: `curl`, schema.org, Rich Results, Lighthouse, prueba con LLM | Pendiente |
| 5 | Google Search Console y Bing Webmaster Tools | Pendiente |
| 6 | Identidad verificable: Bluesky, `rel="me"` recíprocos | Pendiente |

## Registro de decisiones

Fecha = fecha de registro en este archivo.

### 2026-11-06: Dominio y URL canónica
`aitorrioja.com`, registrado en Porkbun a 10 años. Canónico en el apex; `www` redirige al apex.

### 2026-11-06: Hosting en GitHub Pages
Permite servir el libro desde el propio dominio, lo que mejora la atribución, y compilar Hugo con GitHub Actions. Descartado Codeberg Pages: sus condiciones exigen licencias libres en repos públicos (CC BY-NC no lo es) y objetan cuentas usadas solo como web personal. Coste asumido: proveedor estadounidense. Mitigación: sitio estático en git, migrable en minutos (ver «Migrar a otro host»).

### 2026-11-06: Hugo sin tema de terceros
Binario único sin dependencias npm, multilenguaje nativo y HTML completo generado en build. Descartado HTML con datos JSON renderizados en cliente, porque oculta el contenido a rastreadores que no ejecutan JavaScript.

### 2026-11-06: Bilingüe
Español como fuente, en `/`; inglés como traducción, en `/en/`.

### 2026-11-06: Ninguna señal de búsqueda de empleo
Ni «open to work», ni «disponible», ni la propiedad `seeks`, ni equivalentes, en ningún idioma o formato.

### 2026-11-06: Privacidad técnica
Sin analítica, cookies, fuentes externas ni CDN de terceros. Todo se sirve desde el repo.

### 2026-11-06: Contacto
`contact@aitorrioja.com` con el reenvío gratuito de Porkbun (solo recepción). Motivo: canal accesible sin sesión y coste cero; el backend se sustituye cambiando solo los registros de correo, sin tocar la web. Descartado el autohospedaje: en casa, el MX expone la IP doméstica y una IP residencial no sirve para enviar; en VPS, el puerto 25 llega bloqueado por defecto y el mantenimiento es desproporcionado para el volumen.

### 2026-11-06: Identidad
Nombre canónico «Aitor Rioja», sin segundo apellido, coherente con LinkedIn. Sin fotografía. El empleador actual no se nombra; se describen sector y función.

### 2026-11-06: Licencias
MIT para el código (`layouts/`, `i18n/`, workflow, configuración); CC BY 4.0 para el contenido (`data/`, `content/`); CC BY-NC 4.0 para el libro. Declaración por ruta con la especificación REUSE, que se implementa en Fase 2. Motivo: el contenido se reutiliza con atribución; el libro conserva NC por decisión del autor.

### 2026-11-06: Libro
aitorrioja.com es el único canal de distribución del libro y su fuente canónica.

### 2026-11-06: Repositorio y verificación del dominio
Repo público `github.com/aitor4000/web`, rama `main`. Dominio verificado a nivel de cuenta en GitHub Pages (TXT `_github-pages-challenge-aitor4000`): impide que otra cuenta publique en el dominio o en sus subdominios inmediatos.

### 2026-11-06: Build
GitHub Actions con las acciones oficiales por tag mayor (`checkout@v7`, `configure-pages@v6`, `upload-pages-artifact@v5`, `deploy-pages@v5`). Hugo estándar fijado en 0.168.0 con verificación SHA-256 del binario. Regla: solo versiones con al menos 14 días publicadas; por eso no 0.169.0, publicada el 2026-10-27. Sin archivo `CNAME`: con workflow propio, GitHub lo ignora.

### 2026-11-06: Limpieza de la zona DNS
Se eliminan los registros por defecto de Porkbun: `ALIAS` del apex y `CNAME` comodín hacia `uixie.porkbun.com`, el URL forwarding y dos TXT `_acme-challenge` residuales. Motivo: la documentación de GitHub desaconseja los registros comodín porque exponen a la toma de subdominios aunque el dominio esté verificado. Se añade DMARC `p=reject`, ausente en la zona original.

## Infraestructura

**Registrador y DNS:** Porkbun. Nameservers `curitiba`, `fortaleza`, `maceio` y `salvador`, todos en `.ns.porkbun.com`. DNSSEC desactivado.

**Zona DNS (estado objetivo):**

| Tipo | Host | Valor | Función |
|---|---|---|---|
| A | apex | `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` | GitHub Pages |
| AAAA | apex | `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153` | GitHub Pages (IPv6) |
| CNAME | `www` | `aitor4000.github.io` | GitHub redirige `www` al apex |
| MX | apex | `fwd1.porkbun.com` (10), `fwd2.porkbun.com` (20) | Reenvío de correo |
| TXT | apex | `v=spf1 include:_spf.porkbun.com ~all` | SPF del reenvío |
| TXT | `_dmarc` | `v=DMARC1; p=reject;` | Bloquea suplantación del dominio |
| TXT | `_github-pages-challenge-aitor4000` | token de GitHub | Verificación de cuenta. No borrar |

Ningún registro comodín. Valores de GitHub según su documentación, consultada el 2026-11-06.

**Correo:** reenvío de Porkbun de `contact@` a un buzón privado, no documentado aquí. Reenvío operativo desde 2026-11-13, probado con envío externo. Solo recibe.

**GitHub Pages:** fuente «GitHub Actions»; dominio personalizado `aitorrioja.com`; «Enforce HTTPS» activado; certificado gestionado por GitHub.

## Desplegar

- Cada push a `main` ejecuta `.github/workflows/pages.yml`, que compila y publica.
- Ejecución manual: pestaña Actions → «Publicar en GitHub Pages» → «Run workflow».
- Previsualización local: `hugo server` y abrir `http://localhost:1313/`. La versión local puede no coincidir con la del workflow; la que vale es la del workflow.
- Actualizar Hugo: cambiar `HUGO_VERSION` en el workflow (respetando la regla de 14 días), compilar en local y hacer push.

## Comprobar

`scripts/verificar.sh` contrasta DNS y HTTP con el estado objetivo descrito arriba. Modos: `dns`, `http` o `todo` (por defecto). Sale con código distinto de 0 si algo falla.

## Añadir contenido

Se documenta en Fase 2, con el esquema de `data/`.

## Migrar a otro host

1. `hugo --gc --minify` genera en `public/` el sitio completo, servible por cualquier host estático.
2. Publicar `public/` en el nuevo host y comprobarlo con la URL provisional que ofrezca.
3. En Porkbun, sustituir los A y AAAA del apex y el CNAME de `www` por los valores del nuevo host, y configurar allí la redirección de `www` al apex.
4. Comprobar con `scripts/verificar.sh` (ajustando los valores esperados).
5. Solo cuando ningún registro apunte ya a GitHub: quitar el dominio en Settings → Pages y desactivar Pages. Hacerlo antes, con el DNS aún apuntando a GitHub, abre una ventana de toma del dominio. Mantener la verificación de cuenta mientras quede algún registro hacia GitHub.
6. Sustituir el workflow por el despliegue del nuevo host y actualizar este archivo.

## Qué no entra en el repo

El repo y todo su historial son públicos: lo commiteado se considera publicado. No entran credenciales, borradores, notas personales, la dirección de destino del correo ni información interna del empleador.
