# Night Ferry — Roadmap Mingguan, Event, dan Update Besar

**Tanggal:** 21 Oktober 2026
**Basis:** `Idea-Pitch.md`, `docs/superpowers/plans/2026-10-21-night-ferry-milestones.md`, dan kondisi repo saat ini.
**Asumsi:** 1 developer full-time + AI, art masih placeholder sampai Minggu 3. Kalau part-time, kalikan durasi 1,5–2x. Kalender memakai Minggu 1 = Senin, 26 Oktober 2026.
**Batas kerja:** dokumen ini hanya rencana. Implementasi kode ada di session lain; tidak ada perubahan `src/**` dari session ini.

---

## 0. Ringkasan keputusan

- **6 minggu pertama adalah runway tertutup:** loop → meta → konten → soft launch → stabilisasi → gate review.
- **Setelah gate**, satu update besar setiap 4 minggu, dengan event mingguan yang berputar otomatis.
- **Event mingguan bukan konten baru.** Event = satu baris config yang mengubah parameter shift. Tidak ada treadmill authoring tiap minggu.
- **Monetisasi hanya setelah gate** dan hanya kosmetik. Tidak ada pay-to-win, loot box, atau battle pass sebelum ada data D28.
- Kalau gate bilang *rework* atau *stop*, kalender update di bawah **tidak dijalankan**. Jangan bangun 16 minggu konten di atas loop yang belum terbukti.

---

## 1. Audit konteks repo (21 Oktober 2026)

| Area | Status | Bukti |
|---|---|---|
| Fondasi (M0) | Selesai | Toolchain, `scripts/check.ps1`, `scripts/e2e.ps1`, CI, Rojo build |
| Shift loop (M1) | Sebagian | Shared state/RNG/selection/rules/defs sudah ada; server loop dan client UI masih stub. Detail di `Game-Logic.md`. |
| State machine | Ada di working tree | `src/shared/ShiftState.luau` + `tests/shift-state.spec.luau` |
| RNG | Ada di working tree | `src/shared/Util/SeededRandom.luau` sudah punya `NextNumber` |
| Anomali | Sebagian | Defs, selection, 3 behavior, dan greybox ada; `AnomalyService`/`ShiftService` belum |
| Meta loop | Belum | Belum ada DataStore, coin, shop, upgrade |
| Live ops | Belum | Belum ada `WeeklyEventDefs` atau event service |
| Art | Belum | Masih greybox; belum ada aset |
| Select / MCP | Sebagian | Manual mencatat Studio MCP belum connected; paperwork Select belum mulai |

**Implikasi:** M1 sedang dikerjakan di session lain. Roadmap ini sengaja tidak menyentuh kode; audit di atas adalah snapshot 21 Oktober. Cek `Game-Logic.md` untuk status teknis terbaru. Minggu 1 tetap dimulai dari menyelesaikan loop, bukan dari event.

---

## 2. Prinsip yang mengikat roadmap

1. **Loop dulu, live-ops kemudian.** Tidak ada event publik sebelum shift pertama terbukti fun dan selesai <60 detik.
2. **Event = data, bukan konten.** Satu tabel modifier, diputar berdasarkan nomor minggu. Tidak ada map, quest, atau story baru per event.
3. **Satu update besar = satu headline feature + 4 anomali + 1 route/tier + 1 event skin.** Lebih dari itu = scope creep.
4. **Ship Jumat malam WIB / Sabtu 00:00 UTC.** Audience Roblox memuncak akhir pekan; ini juga pola update mingguan yang dipakai game sejenis. Tidak deploy Minggu.
5. **Gate sebelum scale.** Tidak ada rencana konten 16 minggu yang boleh jalan tanpa data Minggu 6.
6. **Cut art dan monetisasi sebelum cut loop atau test.** Ini aturan dari pitch, bukan preferensi.

---

## 3. Ritme mingguan developer

| Hari | Fokus | Output |
|---|---|---|
| Senin | Pilih 1 headline, tulis acceptance criteria, update roadmap | Scope minggu yang tidak bisa melebar |
| Selasa–Kamis | TDD: test dulu, implement, playtest lokal | Build yang bisa dimainkan |
| Jumat | `check.ps1`, `e2e.ps1`, playtest, fix P0, build artifact | Kandidat ship |
| Sabtu | Ship (kalau minggu ship), monitor console + analytics 24 jam | Update live atau patch |
| Minggu | Libur, tidak deploy | — |

Setiap minggu wajib meninggalkan **satu bukti playtest** (console atau screenshot), **satu catatan metrik**, dan **satu keputusan cut**.

---

## 4. Runway 6 minggu (committed)

| Minggu | Tanggal | Tema | Deliverable utama | Event | Exit gate |
|---|---|---|---|---|---|
| 1 | 26 Okt–1 Nov | M1 Vertical slice | Ferry greybox, 3 anomali, day/night loop, HUD, 2 pemain | Tidak ada; internal seed test | 2 loop penuh, day 5/5, night 3/3, failure path, reset |
| 2 | 2–8 Nov | M2 Meta loop | ProfileStore, coin, 3 upgrade, shop, tutorial | Internal `Ledger Week` | Rejoin simpan progress, beli upgrade, saldo tidak negatif |
| 3 | 9–15 Nov | M3 Konten + art + Select | 10–12 anomali, variasi anchor, art pass, closed playtest | `Fog Week` (closed test) | ≥8 playtester, ≥70% selesai shift 1, Select checklist |
| 4 | 16–22 Nov | M4 Soft launch | Weekly event, route 2, publish, analytics | `Maiden Voyage` (launch) | Place live, event jalan, 7 hari data, no P0 |
| 5 | 23–29 Nov | Stabilisasi + Update 1.1 | Fix launch, 2 anomali baru, tuning ekonomi | `Quiet Crossing` | Crash-free ≥99%, no P0, update shipped |
| 6 | 30 Nov–6 Des | M5 Gate review | Gate report, keputusan continue/rework/stop | `Ledger Week` | Keputusan tertulis, tidak ada konten baru |

### Minggu 1 — Vertical Slice (M1)

**Goal:** dua pemain bisa menyelesaikan dua loop penuh tanpa stuck.

**Build:**
- Shared state, RNG, `AnomalyDefs`, `AnomalySelection`, dan `InteractionRules` sudah ada di working tree (session lain); verifikasi lewat test.
- Sisa M1: `AnomalyService`, `ShiftService`, analytics funnel.
- Ferry greybox dan 3 behavior anomali (`WrongPassenger`, `ImpossibleCabin`, `RestlessCargo`) ada di working tree; verifikasi wiring-nya.
- HUD fase/timer/objective/seed; lighting day/night.
- Native `ProximityPrompt`, belum ada remote.

**Event:** tidak ada event publik. Pakai seed tetap untuk uji reproduksi.

**Exit:** `check.ps1` dan `e2e.ps1` hijau; 2 pemain menyelesaikan 2 loop; day 5/5; night 3/3; failure path; reset bersih; first interaction <60 detik; screenshot + console tersimpan.

**Cut kalau slip:** day task 5→3, anomali 3→2. Jangan cut state machine atau test.

### Minggu 2 — Meta Loop (M2)

**Goal:** pemain punya alasan kembali untuk shift berikutnya.

**Build:**
- ProfileStore + `DataService`: schema v1, session lock, autosave 60 detik, `BindToClose`.
- `EconomyService`: grant/spend server-only, saldo tidak pernah negatif.
- 3 upgrade: `lamp`, `ledger`, `hull`; 3 level; cost curve `[100, 250, 600]`.
- Coin shop dengan satu `RemoteFunction` tervalidasi dan rate limit.
- Tutorial 3 langkah: move, interact, fix; target first interaction <60 detik.
- Results screen menampilkan coin dan saldo.

**Event:** uji internal `Ledger Week` (2x coin day task) untuk memastikan pipeline modifier bekerja sebelum launch.

**Exit:** rejoin menyimpan coin/upgrade; pembelian apply; saldo tidak negatif; tutorial selesai; test ekonomi dan validasi remote hijau.

**Cut kalau slip:** upgrade ketiga dan polish shop. Pertahankan persistence + satu upgrade.

### Minggu 3 — Konten, Art, Select (M3)

**Goal:** cukup konten dan polish untuk closed playtest dan listing Select.

**Build:**
- 10–12 anomali; 2–3 anchor per tag; variasi per shift.
- Eksperimen `Ship's Log`: manifest penumpang/kargo supaya anomali = deviasi dari manifest, bukan hafalan. A/B di playtest; pertahankan hanya kalau fairness dan completion membaik.
- Art pass: ferry hero, 10–15 prop, prop anomali, SFX prompt/anomali/malam, fog dan lighting.
- Select: place milik group, 2FA, verifikasi ID, maturity questionnaire Moderate, tanpa link eksternal.
- Closed playtest 8–15 pemain, dua sesi.

**Event:** `Fog Week` di closed test: +1 anomali, 1,25x coin, kabut lebih tebal.

**Exit:** 10–12 anomali; ≥8 playtester; ≥70% selesai shift 1; no P0; Select checklist selesai; screenshot HP.

**Cut kalau slip:** hero art dan SFX dulu. Jangan cut jumlah anomali atau playtest.

### Minggu 4 — Soft Launch (M4)

**Goal:** place publik dengan alasan mingguan untuk kembali.

**Build:**
- `WeeklyEventDefs` + `WeeklyEventService` + banner HUD.
- Route 2 `North Passage`: unlock, bobot anomali berbeda, warna fog, coin multiplier.
- Publish place di group; icon/thumbnail; dashboard Creator Analytics.
- First content update: 2 anomali baru + event launch.

**Event:** `Maiden Voyage`: +1 anomali, 1,25x coin, flag kosmetik launch.

**Exit:** place live; event mingguan jalan; 7 hari data; no P0; first content update shipped.

**Cut kalau slip:** route 2 bisa geser ke Minggu 5. Launch dengan route 1 + event. Jangan tunda launch hanya karena art.

### Minggu 5 — Stabilisasi + Update 1.1

**Goal:** perbaiki launch, jangan tambah sistem baru.

**Build:**
- Fix P0/P1, tuning ekonomi, cek performa HP low-end.
- Update 1.1: 2 anomali baru + varian event. Tidak ada sistem baru.
- Rotasi event otomatis pertama.

**Event:** `Quiet Crossing`: −1 anomali, 0,9x coin, day lebih pendek. Cocok untuk pemain baru.

**Exit:** crash-free ≥99%; no P0; data D1 terkumpul; update shipped.

**Cut kalau slip:** tunda Update 1.1. Stabilisasi lebih penting daripada konten.

### Minggu 6 — Gate Review (M5)

**Goal:** putuskan continue, rework, atau stop berdasarkan data, bukan feeling.

**Build:** tidak ada fitur baru. Tulis `docs/metrics/gate-report.md`: funnel, D1/D7/D28, sessions/day, spend days, bug/seed log, feedback playtest.

**Event:** `Ledger Week` (2x coin day task). Event rendah risiko, tanpa konten baru.

**Exit:** gate report lengkap; keputusan tertulis; rencana 4 minggu berikutnya dipilih.

**Cut kalau slip:** kalau data masih tipis, geser gate ke Minggu 7. Jangan menebak.

---

## 5. Gate review Minggu 6

Target dari pitch, dipakai sebagai heuristik:

| Metrik | Target | Kalau miss |
|---|---|---|
| Shift 1 completion | ≥70% | Perbaiki spawn, tutorial, objective pertama |
| D1 | ≥30% | Perbaiki loop sesi pertama dan reward |
| D7 | ≥12% | Perjelas progres upgrade dan alasan kembali |
| D28 | ≥5% | Tambah kedalaman meta/route, bukan event baru |
| Sessions/day returning | ≥1,3 | Pendekkan shift atau tambah alasan harian |

**Aturan:** miss 2 dari 4 setelah dua content update → rework core loop sebelum user acquisition.

| Keputusan | Aksi |
|---|---|
| **Continue** | Jalankan Update 1.2–1.4, tambah kosmetik Robux, private server |
| **Rework** | Minggu 7–10 ubah loop (manifest deduction, shift lebih pendek, co-op role), closed playtest, relaunch Minggu 11 |
| **Stop** | Arsipkan game; simpan tech base untuk pitch berikutnya |

---

## 6. Update train setelah gate (conditional)

Hanya jalan kalau gate = **Continue**.

### Heartbeat 4 minggu

| Minggu dalam siklus | Fokus | Output |
|---|---|---|
| A — Build | 1 headline feature + 4 anomali + test | Build yang bisa dimainkan |
| B — Ship | Konten lengkap, ship Sabtu, monitor 24 jam | Update live |
| C — Stabilize | Fix, tuning, baca feedback; tanpa scope baru | Patch |
| D — Preview | Scope update berikutnya, closed test, metrik | Go/no-go |

Event mingguan tetap berputar otomatis selama siklus ini. Tidak ada pekerjaan event tambahan.

### Kalender 12 minggu

| Minggu | Tanggal | Update | Headline | Event contoh |
|---|---|---|---|---|
| 7–8 | 7–20 Des | 1.2 `The Deep` | Route 3 tier sulit, 4 anomali, upgrade `Sonar` | `Fog Week` / `Blackout` |
| 9 | 21–27 Des | Seasonal | `Harbor Lights`; skin musim dingin, tanpa sistem baru | `Harbor Lights` |
| 10 | 28 Des–3 Jan | Stabilize | Fix, tuning, metrik | `Quiet Crossing` |
| 11–12 | 4–17 Jan | 1.3 `Ship's Log` | Manifest + co-op role, 4 anomali, QoL, kosmetik pertama | `Ledger Week` / `Cargo Boom` |
| 13 | 18–24 Jan | Stabilize | Fix, tuning | `Blackout` |
| 14–16 | 25 Jan–14 Feb | 1.4 `The Lighthouse` | Endgame tier, 4 anomali, prestige, seasonal | `Harbor Lights` / `Sweet Passage` |
| 17–18 | 15–28 Feb | Stabilize + Season 2 | Metrik, rencana season berikutnya | `Ghost Tide` / `Fog Week` |

**Catatan:** tanggal dan tema adalah contoh; geser sesuai hasil gate. Yang tidak boleh bergeser adalah heartbeat 4 minggu dan aturan “satu headline per update.”

---

## 7. Sistem weekly event

### 7.1 Bentuk data

```lua
-- src/shared/Config/WeeklyEventDefs.luau
local WeeklyEventDefs = {
	{
		id = "fog_week",
		name = "Fog Week",
		modifiers = {
			anomalyCountDelta = 1,
			coinMultiplier = 1.25,
			fogEndMultiplier = 0.6,
		},
		anomalyWeights = { impossible_cabin = 2 },
	},
	-- ...
}

return table.freeze(WeeklyEventDefs)
```

Server menghitung minggu dari waktu UTC, memilih event, menerapkan modifier saat shift dimulai, lalu mempublikasikan `EventId`, `EventName`, dan `EventModifiers` sebagai attribute. Client hanya menampilkan banner dan mengubah lighting/fog.

### 7.2 Aturan rotasi

- `weekIndex = math.floor(os.time() / 604800)` — epoch week, UTC. Tidak perlu ISO week yang rentan edge case.
- Event dipilih dari **rotasi tetap 8 minggu** di config. Tidak ada RNG untuk pemilihan event.
- Seed tetap dipakai untuk pemilihan anomali di dalam shift, bukan untuk memilih event.
- Seasonal event boleh override satu minggu lewat rentang tanggal.
- Tidak boleh ada event yang sama dua minggu berturut-turut.
- Test: minggu yang sama menghasilkan event yang sama; tidak ada ID duplikat; clamp anomali 2–4; multiplier > 0.

**Kenapa rotasi tetap, bukan seeded random?** Karena event mingguan harus bisa diprediksi untuk perencanaan konten dan support. RNG menambah kode tanpa menambah nilai. Kalau pool membesar melewati 8 event, baru pertimbangkan seeded shuffle.

### 7.3 Pool event

| Event | Modifier | Rasa | Kapan dipakai |
|---|---|---|---|
| `Fog Week` | +1 anomali, 1,25x coin, fog 0,6x | Lebih sulit, lebih tebal | Launch, hype week |
| `Quiet Crossing` | −1 anomali, 0,9x coin, day 0,8x | Santai | Minggu pemain baru, setelah update berat |
| `Ledger Week` | 2x coin day task | Reward kerja siang | Setelah update besar |
| `Passenger Rush` | +2 task penumpang, 1,2x ticket coin, bobot `WrongPassenger` 2x | Ramai | Mid-cycle |
| `Cargo Boom` | +2 task kargo, 1,25x cargo coin, bobot `RestlessCargo` 2x | Fokus kargo | Mid-cycle |
| `Blackout` | lampu 0,5x, coin anomali 1,5x | Tegang | Halloween / update horor ringan |
| `Moonless Night` | night 1,25x, +1 anomali, 1,4x coin | Malam panjang | Weekend |
| `Ghost Tide` | bobot anomali langka 3x, 1,15x coin, fog ungu | Variasi | Seasonal |
| `Maiden Voyage` | +1 anomali, 1,25x coin, flag launch | Perayaan | Launch saja |
| `Harbor Lights` | 1,2x coin, lighting musim dingin, flag | Hangat | Desember |

### 7.4 Guardrails event

- Tidak ada map, quest, atau story baru per event. Kalau butuh itu, itu update besar, bukan weekly event.
- Tidak ada currency FOMO baru. Hadiah = coin dan flag kosmetik.
- Jumlah anomali selalu 2–4; durasi shift ≤12 menit; semua event bisa dimainkan solo.
- Tidak ada event berbayar atau entry ticket.
- Tidak ada event yang menaikkan beban server secara signifikan (tanpa partikel ribuan, tanpa NPC baru).

---

## 8. Update besar: aturan isi

| Update | Minggu | Headline | Budget konten | Monetisasi |
|---|---|---|---|---|
| 1.0 `First Crossing` | 4 | Launch core | 10–12 anomali, route 1–2, meta, weekly event | Tidak ada |
| 1.1 `Two New Anomalies` | 5 | Content top-up | 2 anomali, 1 varian event | Tidak ada |
| 1.2 `The Deep` | 8 | Route 3 tier sulit + `Sonar` | 4 anomali, 1 upgrade, art es/fog | Tidak ada |
| 1.3 `Ship's Log` | 12 | Manifest + co-op role | 4 anomali, QoL, 2 kosmetik, private server | Kosmetik + private server |
| 1.4 `The Lighthouse` | 16 | Endgame tier + prestige | 4 anomali, prestige, seasonal skin | Rotating cosmetic shop |

**Aturan:** satu update hanya boleh punya satu headline feature. Sisanya adalah konten pendukung. Kalau butuh dua sistem baru dalam satu update, pecah jadi dua update.

### Seasonal event

Seasonal = reskin + modifier, bukan game baru.

| Event | Waktu | Isi | Biaya produksi |
|---|---|---|---|
| `Harbor Lights` | 19 Des–3 Jan | Lighting musim dingin, flag, 1,2x coin | Rendah |
| `Thaw` | Maret | Fog bersih, bonus kargo | Rendah |
| `Founder's Week` | Juni | Flag anniversary, +10% coin | Rendah |
| `Ghost Tide` | September | Varian anomali langka, fog ungu, tanpa gore | Sedang |

---

## 9. Monetisasi (hanya setelah gate)

- Gate = Continue → tambah **2 produk kosmetik Robux**: ferry skin dan uniform.
- `ProcessReceipt` idempotent + receipt ledger; grant hanya di server.
- Update 1.3: rotating cosmetic shop + private server.
- Jangan: pay-to-win upgrade, loot box, energy system, battle pass sebelum ada data D28.
- Konten tetap Moderate: eerie, bukan gore; tanpa link eksternal.

---

## 10. Metrik dan gate

| Tahap | Metrik | Target | Aksi kalau miss |
|---|---|---|---|
| Launch | Shift 1 completion | ≥70% | Fix onboarding/spawn |
| Launch | D1 | ≥30% | Fix sesi pertama |
| Launch | D7 | ≥12% | Perjelas meta dan alasan kembali |
| Launch | D28 | ≥5% | Tambah kedalaman, bukan event |
| Launch | Sessions/day | ≥1,3 | Pendekkan shift |
| Minggu 5 | Crash-free sessions | ≥99% | Stop konten, fix dulu |
| Minggu 5 | First interaction | <60 detik | Pindahkan spawn/shorten lobby |
| Setiap update | D7 vs 2 minggu sebelumnya | Tidak turun >2pp | Pause konten, fix |
| Setiap update | P0 open | 0 | No ship |
| Event | Event participation | Diagnostik, bukan gate | Kalau rendah, cek banner/reward |
| Ekonomi | Coin per shift | ±20% dari target | Tuning grant/cost |
| Co-op | % shift dengan ≥2 pemain | Diagnostik | Kalau rendah, cek spawn/party flow |

---

## 11. Yang sengaja tidak dibangun

- Event mingguan bespoke (map/quest baru tiap minggu).
- PvP, ranked, matchmaking.
- Battle pass, loot box, energy, daily login streak.
- Global leaderboard sebelum D28.
- Route 3 art sebelum gate.
- UI khusus console/mobile sebelum playtest HP.
- Framework atau dependency baru yang tidak menggantikan >100 baris kode.
- Sistem sosial/hangout yang tidak menambah loop ferry.

---

## 12. Handoff ke session implementasi (7 hari pertama)

Bagian ini untuk session sebelah. Session ini hanya menulis rencana; tidak ada perubahan kode.

- [x] `ShiftState`, `NextNumber`, `AnomalyDefs`, `AnomalySelection`, `InteractionRules` ada di working tree.
- [ ] Verifikasi test shared lewat `.\scripts\e2e.ps1`; perbaiki kalau merah.
- [ ] `AnomalyService` dan `ShiftService`.
- [ ] Verifikasi `GreyboxFerry`/`WorldService` dan wiring 3 behavior anomali.
- [ ] HUD fase/timer/objective/seed dan lighting day/night.
- [ ] Jalankan `.\scripts\check.ps1`.
- [ ] Playtest 2 pemain; catat seed, console, screenshot.
- [ ] Commit; tulis `docs/evidence/m1-playtest.md`.

---

## 13. Cara menyesuaikan

| Situasi | Penyesuaian |
|---|---|
| Part-time / solo tanpa AI | Kalikan Minggu 1–6 jadi 1,5–2x; heartbeat pasca-gate tetap 4 minggu |
| 2+ developer | Paralelkan art dan konten; jangan percepat gate |
| Launch slip | Cut route 2 dan art; jangan cut loop, test, atau event system |
| Gate = Rework | Stop update train; jangan ship 1.2 |
| Gate = Stop | Arsipkan; jangan paksakan konten |
| Event terasa repetitif | Tambah 1 modifier baru ke pool; jangan buat map baru |

---

**Aturan terakhir:** kalau sebuah ide tidak bisa dijelaskan sebagai satu baris di `WeeklyEventDefs` atau satu headline update, itu bukan bagian dari roadmap ini.
