local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Requests básico
  s("req", {
    t({"import requests", "", ""}),
    t("url = '"),
    i(1, "https://example.com"),
    t({"'", ""}),
    t({"r = requests.get(url)", ""}),
    t({"print(r.status_code)", ""}),
    t("print(r.text)"),
  }),

  -- Requests con headers
  s("reqh", {
    t({"import requests", "", ""}),
    t("url = '"),
    i(1, "https://example.com"),
    t({"'", ""}),
    t({"headers = {", ""}),
    t({"    'User-Agent': 'Mozilla/5.0',", ""}),
    t({"    'Cookie': '"}),
    i(2, "session=xxx"),
    t({"'", "})", ""}),
    t({"r = requests.get(url, headers=headers)", ""}),
    t("print(r.text)"),
  }),

  -- POST JSON
  s("post", {
    t({"import requests", "", ""}),
    t("url = '"),
    i(1, "https://example.com/api"),
    t({"'", ""}),
    t({"data = {", ""}),
    t({"    '"}),
    i(2, "key"),
    t("': '"),
    i(3, "value"),
    t({"'", "})", ""}),
    t({"r = requests.post(url, json=data)", ""}),
    t("print(r.json())"),
  }),

  -- httpx básico
  s("httpx", {
    t({"import httpx", "", ""}),
    t("url = '"),
    i(1, "https://example.com"),
    t({"'", ""}),
    t({"r = httpx.get(url)", ""}),
    t({"print(r.status_code)", ""}),
    t("print(r.text)"),
  }),

  -- httpx async
  s("httpxa", {
    t({"import httpx", "import asyncio", "", ""}),
    t({"async def main():", ""}),
    t({"    async with httpx.AsyncClient() as client:", ""}),
    t({"        r = await client.get('"}),
    i(1, "https://example.com"),
    t({"')", ""}),
    t({"        print(r.text)", "", ""}),
    t("asyncio.run(main())"),
  }),

  -- XSS fuzzer
  s("xss", {
    t({"import requests", "", ""}),
    t({"payloads = [", ""}),
    t({"    '<script>alert(1)</script>',", ""}),
    t({"    '\"<script>alert(1)</script>',", ""}),
    t({"    \"'><script>alert(1)</script>\",", ""}),
    t({"]  ", "", ""}),
    t("url = '"),
    i(1, "https://example.com/search?q="),
    t({"'", "", ""}),
    t({"for payload in payloads:", ""}),
    t({"    r = requests.get(url + payload)", ""}),
    t({"    if payload in r.text:", ""}),
    t({"        print(f'[+] XSS found: {payload}')", ""}),
  }),

  -- SQLi tester
  s("sqli", {
    t({"import requests", "", ""}),
    t({"payloads = [\"'\", \"'' OR 1=1--\", \"' OR '1'='1\"]", "", ""}),
    t("url = '"),
    i(1, "https://example.com/user?id="),
    t({"'", "", ""}),
    t({"for payload in payloads:", ""}),
    t({"    r = requests.get(url + payload)", ""}),
    t({"    if 'error' in r.text.lower() or 'sql' in r.text.lower():", ""}),
    t({"        print(f'[!] Possible SQLi: {payload}')", ""}),
  }),

  -- SSRF tester
  s("ssrf", {
    t({"import requests", "", ""}),
    t({"payloads = [", ""}),
    t({"    'http://localhost',", ""}),
    t({"    'http://127.0.0.1',", ""}),
    t({"    'http://169.254.169.254/latest/meta-data/',", ""}),
    t({"]  ", "", ""}),
    t("url = '"),
    i(1, "https://example.com/fetch?url="),
    t({"'", "", ""}),
    t({"for payload in payloads:", ""}),
    t({"    try:", ""}),
    t({"        r = requests.get(url + payload, timeout=5)", ""}),
    t({"        print(f'[+] {payload}: {r.status_code}')", ""}),
    t({"    except:", ""}),
    t({"        pass", ""}),
  }),

  -- Argparse template
  s("argp", {
    t({"import argparse", "", ""}),
    t({"parser = argparse.ArgumentParser(description='"}),
    i(1, "Script description"),
    t({"')", ""}),
    t({"parser.add_argument('url', help='Target URL')", ""}),
    t({"parser.add_argument('-v', '--verbose', action='store_true')", ""}),
    t({"args = parser.parse_args()", "", ""}),
    t("print(args.url)"),
  }),
}
