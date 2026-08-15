# Printer

Operating notes for the Bambu Lab A1 this project prints on, and the MCP server
used to drive it.

> Real hostnames, serials and the LAN access code are **not** in this repo.
> They live in `.envrc`, which is gitignored. Placeholders below are written as
> `<PRINTER_HOST>`, `<BAMBU_SERIAL>`, `<BAMBU_TOKEN>`.


Drives a Bambu Lab A1 over the LAN via
[bambu-printer-mcp](https://github.com/DMontgomery40/bambu-printer-mcp)
(npm `@rowbotik/bambu-printer-mcp`), and holds the OpenSCAD sources for parts
printed on it.

## Safety

The tools drive real hardware. `print_3mf`, `start_print_job`, `set_temperature`
and `cancel_print` take physical effect immediately on a machine that may be
unattended. Confirm before starting, cancelling, or heating anything. Read-only
tools (`get_printer_status`, `get_printer_filaments`, `list_printer_files`,
`camera_snapshot`, `get_stl_info`) need no confirmation.

Before any control tool, check `get_printer_status` for an active job. A print
was already running during setup and nearly got disturbed.

## Printer

| | |
|---|---|
| Model | Bambu Lab A1, 0.4 nozzle, stainless |
| Build volume | 256 x 256 x 256 |
| IP | <PRINTER_HOST> (DHCP - can change) |
| Serial | <BAMBU_SERIAL> |
| MAC | <PRINTER_MAC> |
| WLAN | <WLAN_SSID> (same /24 as this machine, which is <THIS_HOST>) |
| Bed | textured PEI plate |
| AMS | none - single external spool (`vt_tray`) |

Open LAN ports: 8883 MQTT/TLS, 990 FTPS, 6000 camera.

## Credentials

`.envrc` (direnv) holds the values. The access code is *not* the Bambu cloud
password. It is the LAN code, and it lives in
`~/.config/BambuStudio/BambuStudio.conf` as a **nested map**, which is why a
naive single-line grep for `"access_code": "..."` finds nothing:

```json
"access_code": { "<BAMBU_SERIAL>": "<BAMBU_TOKEN>" }
```

Read it from that file. The printer screen only shows it once LAN Only Mode is
enabled, and enabling that unbinds the printer from the cloud account, which is
not needed - LAN access already works with the code alone.

`.envrc` is untracked and holds a credential. If this directory becomes a git
repo, gitignore it first.

## MCP registration

Registered at **user scope** in `~/.claude.json`, so it loads from any
directory. `.envrc` is documentation and shell convenience, *not* what feeds the
server. Editing `.envrc` alone changes nothing. To re-register:

```bash
claude mcp remove bambu-printer -s user && \
claude mcp add bambu-printer -s user \
  -e PRINTER_HOST=<PRINTER_HOST> \
  -e BAMBU_SERIAL=<BAMBU_SERIAL> \
  -e BAMBU_TOKEN=<BAMBU_TOKEN> \
  -e BAMBU_MODEL=a1 \
  -e SLICER_TYPE=bambustudio \
  -e SLICER_PATH=/usr/bin/bambu-studio \
  -e BED_TYPE=textured_plate \
  -- npx -y @rowbotik/bambu-printer-mcp
```

Verify with `claude mcp get bambu-printer`.

## Finding the printer if the IP moves

Match on the MAC:

```bash
ip neigh | grep -i <printer_mac>
```

Do **not** wide-scan. SSDP discovery returns nothing here (the AP filters
multicast and nine docker bridges confuse routing), and a 762-socket parallel
port scan over WiFi *missed the printer entirely* while turning up an Apple
device on 8883 as a false positive. Probe candidates directly instead:

```bash
for p in 8883 990 6000; do timeout 3 bash -c "</dev/tcp/<PRINTER_HOST>/$p"; done
```

