# Manual — Night Ferry

Dokumen ini berisi hal-hal yang **belum bisa diotomatiskan** atau butuh akses akun/UI Roblox.
Semua perintah dijalankan dari root repo: `D:\GAWE\Roblox\night-ferry`.

## Status otomatis

Sudah jalan dan diverifikasi:

- Toolchain: Rokit, Rojo 7.7.1, Wally, Selene, StyLua, luau-lsp, Lune.
- Quality gates: `scripts/check.ps1`.
- Build place: `rojo build default.project.json`.
- Test end-to-end lokal: `scripts/e2e.ps1` (Studio headless + Jest Roblox).
- CI statis: `.github/workflows/ci.yml` (lint, format, type check, build, artifact).
- Skill project: `.opencode/skills/roblox-dev-loop`, `.opencode/skills/roblox-anomaly-authoring`.

Yang belum: koneksi Studio MCP, publish place, dan test di CI.

## Verifikasi terakhir (2026-10-21)

- `scripts/check.ps1`: pass (Selene, StyLua, luau-lsp, build).
- `scripts/e2e.ps1`: `1 passed, 1 total` + `[NightFerry] e2e tests passed`.
- CI run `39585863877` (commit `40d7d2a`): **success**.
- Artifact CI: `NightFerry-place` (1.067 byte, belum kedaluwarsa).
- Studio MCP: **belum connected**; `opencode mcp list` gagal karena `mcp.bat` belum ada.

Artifact CI bisa diunduh dari halaman run di GitHub. Download lewat CLI butuh `gh auth login`; lewat browser tidak.

---

## 1. Studio MCP (sekali saja)

MCP dipakai agent untuk inspect DataModel, playtest, baca console, dan screenshot.
Tanpa ini, agent hanya bisa mengedit file dan build place.

1. Buka Roblox Studio dan login.
2. Buka **Assistant** → tombol **⋯** → **Manage MCP Servers**.
3. Aktifkan **Enable Studio as MCP server**.
4. Pastikan file `%LOCALAPPDATA%\Roblox\mcp.bat` muncul.
5. Restart OpenCode.
6. Verifikasi:

```powershell
opencode mcp list
```

Harus menampilkan `roblox_studio` dengan status `connected`, bukan `pending`.

7. Tes dari sesi OpenCode baru: minta agent memanggil `list_roblox_studios`, lalu `search_game_tree`.

**Kalau tetap pending:**

- Pastikan Studio masih terbuka saat OpenCode start.
- Cek `Test-Path "$env:LOCALAPPDATA\Roblox\mcp.bat"`.
- Kalau `mcp.bat` tidak ada, matikan lalu nyalakan lagi opsi MCP di Studio.
- Kalau path berbeda, ganti `command` di `opencode.json` ke path absolut `StudioMCP.exe` versi Studio yang terpasang.

**Aturan:** MCP tidak boleh mengedit `src/**` atau `Packages/**`. Edit kode selalu lewat file + Rojo. MCP hanya untuk inspect, execute, playtest.

---

## 2. Akun dan group Roblox

- [ ] Aktifkan 2FA di akun Roblox.
- [ ] Buat group pemilik experience (mis. `Night Ferry`).
- [ ] Buat experience/place di bawah group itu, bukan di akun pribadi.
- [ ] Upload asset (audio, image, mesh) ke group yang sama.
- [ ] Pastikan akun dalam keadaan good standing.

Untuk target **Select**:

- [ ] Verifikasi identitas (ID) di Creator Hub.
- [ ] 2FA aktif.
- [ ] Isi maturity questionnaire dengan jujur; target **Moderate atau lebih rendah**.
- [ ] Tidak ada link/ajakan ke platform luar.
- [ ] Konten tidak melanggar kebijakan Roblox.

Catatan: syarat Select bisa berubah. Cek halaman **Creator Dashboard → Monetization** sebelum submit.

---

## 3. Publish place dan Open Cloud (hanya saat diperlukan)

Belum dilakukan karena belum ada place ID. Lakukan saat mau:

- publish build ke Roblox, atau
- menjalankan E2E di CI lewat Open Cloud.

Langkah:

1. Buat place kosong di Studio, simpan ke group.
2. Catat **place ID** dan **universe ID**.
3. Buat **Open Cloud API key** di Creator Dashboard, batasi ke universe tersebut.
4. Scope yang dibutuhkan untuk test:
   - `universe-places:write`
   - `universe.place.luau-execution-session:write`
5. Simpan sebagai GitHub Actions secrets, jangan pernah commit:
   - `ROBLOX_OPEN_CLOUD_API_KEY`
   - `ROBLOX_UNIVERSE_ID`
   - `ROBLOX_PLACE_ID`

CI saat ini **tidak** memakai Open Cloud; jadi secrets belum diperlukan.

---

## 4. Push dan verifikasi CI

Push sudah dilakukan ke `origin/main`. Setelah push:

1. Buka `https://github.com/cepsssy/night-ferry/actions`.
2. Buka workflow **ci** yang terbaru.
3. Pastikan job `build` hijau.
4. Unduh artifact **NightFerry-place**, buka `.rbxl` di Studio, dan pastikan place bisa dibuka.
5. Kalau merah, baca langkah yang gagal:
   - `rokit trust` / `rokit install` → masalah trust di runner.
   - `wally install` → cek `wally.lock`.
   - `luau-lsp` → cek unduhan `globalTypes.None.d.luau`.
   - `stylua` / `selene` → jalankan `scripts/check.ps1` lokal.

**Penting:** GitHub-hosted runner tidak punya Roblox Studio, jadi E2E tidak jalan di CI.
E2E hanya lokal (`scripts/e2e.ps1`) atau di self-hosted runner Windows yang punya Studio dan login.

---

## 5. Menjalankan test end-to-end

Dari root repo:

```powershell
.\scripts\e2e.ps1
```

Yang dilakukan script:

1. `rojo build test.project.json -o build/NightFerryTests.rbxl`
2. Mencari `RobloxStudioBeta.exe` versi terbaru.
3. Menjalankan Studio dengan `--task RunScript`, `--localPlaceFile`, `--runScriptFile scripts/e2e.luau`, `--outputFile build/e2e-output.log`, `--quitAfterExecution`.
4. Gagal (exit non-zero) kalau output tidak memuat `[NightFerry] e2e tests passed`.

Output sukses yang diharapkan:

```text
 PASS  Tests/smoke.spec
  ✓ adds 1 + 1

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
[NightFerry] e2e tests passed
```

Syarat:

- Roblox Studio terpasang dan sudah pernah login.
- Tidak ada instance Studio lain yang mengunci place (script memakai instance baru; kalau macet, tutup Studio lalu ulangi).
- `rojo` ada di PATH; script menambahkan `%USERPROFILE%\.rokit\bin` otomatis.

### Manual Play mode

Kalau ingin melihat langsung di Studio:

```powershell
rojo build test.project.json -o build/NightFerryTests.rbxl
```

Buka `build/NightFerryTests.rbxl`, tekan **Play**, lihat Output:

```text
[NightFerry] tests passed
```

### Menambah test

- Taruh file `*.spec.luau` di `tests/`.
- Test otomatis ditemukan oleh `tests/jest.config.luau` (`testMatch = { "**/*.spec" }`).
- Jalankan `.\scripts\e2e.ps1` lagi.
- Jangan menaruh runner di dalam folder test dengan nama yang cocok `*.spec.luau`; runner ada di `tests/spec.luau`.

---

## 6. Playtest visual lewat MCP

Setelah MCP connected:

1. `list_roblox_studios`
2. `search_game_tree` → pastikan `ReplicatedStorage.Shared` dan `ServerScriptService.Server`.
3. `start_stop_play` (start).
4. `get_console_output` → cari `[NightFerry] server boot` dan `[NightFerry] client boot`.
5. `screen_capture` → simpan bukti.
6. `start_stop_play` (stop).

Untuk perubahan visual, lampirkan screenshot dan console output di PR/commit message.

---

## 7. Skill dan sesi agent

Skill sudah terdeteksi OpenCode. Yang belum diuji adalah kepatuhan perilaku di sesi baru.

Tes cepat di sesi OpenCode baru:

1. Minta: "tambahkan config shift baru dan jalankan gate".
2. Agent harus memakai `roblox-dev-loop`: edit `src/`, jalankan `scripts/check.ps1`, lalu playtest/MCP.
3. Kalau agent mengedit lewat MCP atau melewati gate, perbaiki isi skill.

Skill yang tersedia:

- `roblox-dev-loop` — sync Rojo, gates, playtest MCP.
- `roblox-anomaly-authoring` — tambah anomaly dari config sampai test.

---

## 8. Ditunda

| Item | Kapan diaktifkan | Catatan |
|---|---|---|
| Blender + Roblox plugin | saat art pertama | `https://create.roblox.com/docs/art/modeling/roblox-blender-plugin` |
| Open Cloud publish | setelah place ID + API key | `https://create.roblox.com/docs/cloud/reference/features/places` |
| E2E di CI via OCALE | setelah suite test nyata | butuh API key + place published |
| ProfileStore | saat DataService dibuat | `https://madstudioroblox.github.io/ProfileStore/` |
| UI/net library | saat vertical slice | React-Lua / Fusion / Zap / Blink |
| `rojo syncback` | hanya saat porting place lama | bukan untuk proyek greenfield |

---

## 9. Troubleshooting

| Gejala | Penyebab | Perbaikan |
|---|---|---|
| `rokit` tidak ditemukan | PATH belum refresh | `$env:Path = "$env:USERPROFILE\.rokit\bin;$env:Path"` atau buka terminal baru |
| `opencode mcp list` = pending | MCP Studio belum aktif / `mcp.bat` belum ada | aktifkan di Studio, restart OpenCode |
| Studio CLI tidak menghasilkan log | Studio belum login / place terkunci | buka Studio manual, login, tutup, ulangi `scripts/e2e.ps1` |
| `No tests found` | `testMatch` salah | gunakan `testMatch = { "**/*.spec" }`; jangan tambahkan `.luau` |
| `Unknown global 'Random'` | definitions luau-lsp belum ada | jalankan `scripts/check.ps1` (mengunduh definitions) |
| Wally package tidak ditemukan | dev-deps ada di `DevPackages` | `test.project.json` memetakan `DevPackages` sebagai `Packages` |
| CI gagal di `rokit install` | tool belum di-trust | pastikan langkah `rokit trust ...` ada sebelum `rokit install` |
| File generated ter-commit | `.gitignore` kurang | cek `git status`; jangan commit `Packages/`, `DevPackages/`, `build/`, `sourcemap.json`, `globalTypes.d.luau` |
| CI gagal di `stylua --check` | checkout Windows mengubah LF ke CRLF | `.gitattributes` sudah memaksa `eol=lf`; jangan hapus |

---

## 10. Checklist selesai

- [ ] Studio MCP connected (`opencode mcp list`).
- [ ] `scripts/check.ps1` exit 0.
- [ ] `scripts/e2e.ps1` exit 0 dan mencetak `[NightFerry] e2e tests passed`.
- [ ] CI hijau di GitHub Actions.
- [ ] Artifact `.rbxl` bisa dibuka di Studio.
- [ ] Playtest MCP menghasilkan console + screenshot.
- [ ] Place/experience dimiliki group dan 2FA aktif.
- [ ] Tidak ada secret yang ter-commit.
