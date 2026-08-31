local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- curl básico
  s("curl", {
    t("curl -X GET '"),
    i(1, "https://example.com"),
    t("' \\"),
    t({"  -H 'User-Agent: Mozilla/5.0' \\", ""}),
    t("  -v"),
  }),

  -- curl POST
  s("curlp", {
    t("curl -X POST '"),
    i(1, "https://example.com/api"),
    t("' \\"),
    t({"  -H 'Content-Type: application/json' \\", ""}),
    t({"  -d '{"}),
    i(2, '"key":"value"'),
    t({"}'" \\", ""}),
    t("  -v"),
  }),

  -- curl con cookie
  s("curlc", {
    t("curl '"),
    i(1, "https://example.com"),
    t("' \\"),
    t({"  -H 'Cookie: "}),
    i(2, "session=xxx"),
    t({"' \\", ""}),
    t("  -v"),
  }),

  -- httpie GET
  s("http", {
    t("http GET '"),
    i(1, "https://example.com"),
    t("' \\"),
    t({"  User-Agent:Mozilla/5.0 \\", ""}),
    t("  Cookie:"),
    i(2, "session=xxx"),
  }),

  -- httpie POST
  s("httpp", {
    t("http POST '"),
    i(1, "https://example.com/api"),
    t("' \\"),
    t("  "),
    i(2, "key"),
    t("="),
    i(3, "value"),
  }),

  -- ffuf directory
  s("ffuf", {
    t("ffuf -u 'https://"),
    i(1, "example.com"),
    t("/FUZZ' \\"),
    t({"  -w /usr/share/wordlists/dirb/common.txt \\", ""}),
    t({"  -c -mc all -fc 404", ""}),
  }),

  -- ffuf params
  s("ffufp", {
    t("ffuf -u 'https://"),
    i(1, "example.com"),
    t("/api?FUZZ=test' \\"),
    t({"  -w params.txt \\", ""}),
    t({"  -c -mc all -fc 404", ""}),
  }),

  -- Subdomain enum
  s("subenum", {
    t("subfinder -d "),
    i(1, "example.com"),
    t(" -silent | httpx -silent -tech-detect -status-code"),
  }),

  -- One-liner recon
  s("recon", {
    t("echo "),
    i(1, "example.com"),
    t(" | subfinder -silent | httpx -silent | tee alive.txt"),
  }),
}
