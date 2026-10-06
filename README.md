# Simulasi: Memproses PR AI → PO Robot

Simulasi software interaktif bergaya "Try It" untuk melatih staf Purchasing. Isinya mengikuti
*Manual Guide Memproses PR & PO AI*. Semua aplikasi di dalamnya fiktif: SurelKu (email),
Jelajah (browser), NusaERP, dan KabarIn (chat).

| File | Kegunaan |
|---|---|
| `simulasi-pr-po-robot.html` | Simulasi lengkap dalam 1 file. Bisa dibuka langsung di browser, tanpa internet. |
| `dist/simulasi-pr-po-robot-scorm12.zip` | Paket SCORM 1.2 untuk diunggah ke LMS. |
| `scorm/imsmanifest.xml` | Manifest SCORM (judul, batas lulus `masteryscore`). |
| `scorm/build-scorm.sh` | Membuat ulang ZIP setelah file HTML diubah. |

## Isi pelatihan

**3 skenario**

| Skenario | Langkah | Isi |
|---|---|---|
| Alur normal | 17 | Email PR masuk → buka NusaERP → cek PDF PR → buka PO buatan Robot → approve & simpan → cek email Robot → konfirmasi ke supplier lewat chat |
| Kasus: harga naik | 9 | Supplier mengabari harga naik → keputusan → revisi harga di PO → approve ulang → kirim ulang PO |
| Kasus: barang kosong | 12 | Supplier mengabari barang kosong → keputusan → qty jadi 0 → kirim ulang PO → info ke grup outlet |

**3 mode**
- **Lihat (Demo)**: berjalan otomatis, kursor bergerak dan mengklik sendiri. Bisa dijeda.
- **Coba (Latihan)**: tombol yang benar berkedip dan diberi petunjuk. Setelah 2× salah, petunjuk lebih jelas muncul.
- **Uji (Tes)**: tanpa sorotan dan petunjuk. Kesalahan dan waktu dihitung. Setelah 3× salah di satu langkah, petunjuk tetap muncul, tetapi langkah itu bernilai 0.

**Nilai per langkah**: 1 (tanpa salah), 0,75 (1× salah), 0,5 (2×), 0,25 (3× atau lebih), 0 bila dibantu petunjuk.
Nilai akhir adalah rata-ratanya × 100. Batas lulus default 80.

## ⚠️ Sebelum dipakai untuk menilai karyawan

- [ ] **Kunci jawaban kasus harga naik & barang kosong sudah dicek pemilik SOP.** Jawaban "benar" di
      kedua kasus ini disusun dari dua kalimat di email Robot ("invoice harus sesuai harga PO",
      "perubahan harga/barang kosong segera diinfokan"). Soal wewenang persetujuan harga dan siapa yang
      mencari supplier pengganti, PDF tidak menjelaskannya.
- [ ] **Data fiktif diganti dengan data asli bila perlu** (lihat `CONFIG.data` di bawah).
- [ ] **Paket ZIP sudah dicoba di LMS produksi** dengan 1 akun tes. Selama pengembangan, paket ini
      diuji dengan runtime SCORM open-source (lihat Hasil pengujian), bukan LMS perusahaan.
- [ ] **Aturan lulus di LMS sudah diputuskan** (lihat `wajibSemuaSkenario`).

## Mengunggah ke LMS (SCORM 1.2)

1. Jika `simulasi-pr-po-robot.html` diubah, buat ulang paketnya: `sh scorm/build-scorm.sh`.
2. Unggah `dist/simulasi-pr-po-robot-scorm12.zip` sebagai aktivitas/paket SCORM.
3. Data yang dikirim ke LMS:
   - `cmi.core.lesson_status`: `incomplete` saat mulai, `completed` setelah mode Coba, `passed`/`failed` setelah mode Uji.
   - `cmi.core.score.raw`: nilai mode Uji (0–100).
   - `cmi.suspend_data`: nilai Uji terbaik per skenario, agar tetap tersimpan di sesi berikutnya.
   - `cmi.core.session_time`: lama sesi.
4. Batas lulus mengikuti `masteryscore` dari LMS bila ada. Kalau tidak ada, dipakai `CONFIG.nilaiLulus`.
   Samakan `adlcp:masteryscore` di `scorm/imsmanifest.xml` dengan nilai yang Anda inginkan.
5. Status `passed` tidak akan berubah menjadi `failed` karena tes berikutnya gagal.

Tanpa LMS, simulasi tetap berjalan normal (baris bawah halaman menampilkan "LMS: tidak terhubung").

## Mengubah isi

Semua pengaturan ada di dalam `simulasi-pr-po-robot.html`. Buka dengan editor teks biasa.

### 1. Data & teks — `CONFIG` (bagian `<script>`)
| Pengaturan | Arti |
|---|---|
| `nilaiLulus` | Batas lulus mode Uji (default 80). |
| `bantuanUjiSetelah` | Mode Uji: petunjuk muncul setelah N salah. `0` = tidak pernah. |
| `kecepatanDemo` | `2` = demo 2× lebih cepat. |
| `wajibSemuaSkenario` | `true` = lulus di LMS hanya bila **semua** skenario sudah diuji dan semuanya ≥ batas lulus (nilai yang dikirim = nilai terendah). |
| `data.*` | Nomor PR/PO, outlet, supplier, URL, isi email & chat. `{nama}` di dalam teks diganti otomatis. |
| `data.kodeHarga`, `hargaBaru`, `kodeKosong` | Barang mana yang naik harga / kosong (kode dari `PO_ITEMS`). |

### 2. Langkah — `<script id="steps-data">` (JSON)
Struktur: `{"skenario":[{ id, judul, deskripsi, pelajari[], ringkasan, sceneAkhir, langkah[] }]}`.
Satu objek di `langkah` adalah satu langkah, dan urutan array menentukan urutan alur.

**Langkah klik**
```json
{"id":"simpan-po","scene":"erp-po-form-ok","aksi":"click","target":"#po-save",
 "instruksi":"Klik Simpan untuk menyimpan PO.",
 "tugas":"Simpan PO.",
 "petunjuk":"Tombol hijau \"Simpan\" di kanan bawah formulir."}
```
- `target` boleh berisi beberapa selector dipisah koma. Selector **pertama** dipakai untuk sorotan & kursor demo.
- `instruksi` tampil di mode Lihat/Coba, `tugas` di mode Uji (jangan sebut letak tombol), `petunjuk` muncul setelah 2× salah.

**Langkah ketik**: tambahkan `"aksi":"type"`, `"teks":"..."`, lalu `"cocok"`:
- `"tepat"`: harus sama, lalu Enter. Tambahkan `"format":"angka"` agar `30000`, `30.000`, dan `Rp 30.000` dianggap sama.
- `"panduan"`: peserta menekan huruf apa saja dan teks terisi 1 kata per ketukan. Cocok untuk pesan panjang.

**Langkah keputusan (bercabang)**
```json
{"id":"putuskan","scene":"h-start","aksi":"pilih","target":"#opt-c",
 "pertanyaan":"Apa yang Anda lakukan?","kutipanDari":"Pak Budi","kutipan":"isi pesan pemicu",
 "opsi":[{"kunci":"a","teks":"…","akibat":"yang terjadi bila memilih ini"},
         {"kunci":"c","teks":"jawaban benar"}],
 "penjelasan":"kenapa jawaban ini benar",
 "instruksi":"…","tugas":"…","petunjuk":"…"}
```
`target` harus `#opt-<kunci>` milik opsi yang benar. Di mode Coba, jawaban yang benar tidak disorot sampai peserta 2× salah.

### 3. Kondisi layar — `SCENES` (bagian `<script>`)
`scene` pada sebuah langkah adalah kondisi layar **sebelum** langkah itu dikerjakan: jendela mana yang
terbuka, halaman ERP, isi chat, dan seterusnya. Scene baru dibuat dengan memperluas scene sebelumnya:
```js
SCENES['nama-baru'] = ext(SCENES['erp-po-form'], { browser: { approved: true } });
```
Karena setiap langkah menyebut scene-nya sendiri, tombol "Langkah sebelumnya" selalu memunculkan layar yang sama.

### 4. Tombol/halaman baru
Tambahkan HTML-nya di `buildERP()`, `buildMail()`, atau `buildChat()`, beri `id` unik, lalu pakai id itu sebagai `target`.
Untuk efek khusus (toast, balasan chat otomatis), tambahkan fungsi di objek `FX` lalu tulis `fx:'namaEfek'`
atau `fx:'balas:kunci-pesan'` pada scene.

### 5. Periksa
Buka file di browser, tekan **F12 → Console**. Kalau ada langkah yang menyebut scene yang belum dibuat,
atau target keputusan yang salah, peringatannya muncul di sana.

## Aksesibilitas & perangkat
- Bisa dipakai hanya dengan keyboard: **Tab** untuk pindah, **Enter** untuk klik. Fokus otomatis pindah ke jendela atau dialog yang baru muncul.
- Responsif sampai lebar HP (diuji di 390 px). Menghormati pengaturan "kurangi animasi" (`prefers-reduced-motion`).
- Suara (Web Audio) bisa dimatikan dengan tombol 🔊.

## Hasil pengujian (6 Okt 2026, Chromium)

| Pengujian | Cakupan | Hasil |
|---|---|---|
| Alur lengkap | 3 skenario × mode Lihat/Coba/Uji, layar desktop 1280 px & HP 390 px, termasuk sengaja salah klik, salah ketik, dan salah pilih | Semua selesai, tanpa error JavaScript |
| Kasus pinggiran | 18 kasus: keyboard saja, Kembali/Ulangi/Ganti mode di tengah animasi, Jeda demo, resize layar | 18/18 lolos |
| Runtime SCORM 1.2 | [scorm-again](https://github.com/jcputney/scorm-again) 3.4.5 (validasi format data seperti LMS): peserta baru lulus/gagal, sesi kedua (data dipulihkan), status lulus tidak turun, mode Coba, `wajibSemuaSkenario` 1/3 → 2/3 → 3/3 | 9/9 lolos, 0 error code SCORM |
| Aksesibilitas | axe-core di setiap layar ketiga skenario, desktop & HP (88 kondisi layar) | 0 pelanggaran |

Belum diuji: Firefox/Safari, perangkat HP fisik, LMS produksi, dan validasi manifest terhadap file skema XSD resmi.

## Keterbatasan yang diketahui
- Klik di area kosong (misalnya saat membaca email) dihitung sebagai kesalahan di mode Uji, sesuai spesifikasi "klik di area salah". Ini bisa terasa ketat bagi peserta yang suka mengklik sambil membaca. Pantau saat uji coba.
- Bagian yang belum ada di PDF tidak disimulasikan: login ERP, penerimaan barang, dan pencocokan invoice.
- Di HP, panduan mengetik 1 kata per ketukan bergantung pada keyboard virtual. Sudah diuji di Chromium, belum di perangkat fisik.
- Paket SCORM tidak menyertakan file skema XSD. Moodle umumnya tidak memerlukannya, tapi validator yang ketat bisa memberi peringatan.
