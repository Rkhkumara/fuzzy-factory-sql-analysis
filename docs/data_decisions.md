# Keputusan Data (Data Decisions)

Dokumen ini mencatat keputusan yang diambil saat mengolah dataset Maven Fuzzy Factory
beserta alasan dan dampaknya, agar analisis bisa diaudit dan direproduksi.

## 1. Pemuatan data

| #   | Temuan                                                                                                 | Keputusan                                                                                | Alasan                                                                                                    |
| --- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| 1   | Baris header CSV ikut terimpor sebagai data di keenam tabel `raw` (opsi Header tidak aktif saat impor) | Hapus baris header dengan `DELETE`, lalu hitung ulang baris                              | Ini kesalahan impor, bukan pembersihan data. Jumlah baris akhir cocok dengan jumlah baris CSV dikurangi 1 |
| 2   | Kolom teks berisi string `'NULL'` (bukan NULL asli), dan ada string kosong                             | Ubah menjadi NULL asli dengan `NULLIF(NULLIF(col,''),'NULL')` saat memuat ke `analytics` | Agar `IS NULL`, `COUNT(col)`, dan join berperilaku benar                                                  |
| 3   | Dua lapisan skema: `raw` (semua TEXT, salinan persis CSV) dan `analytics` (bertipe, PK/FK)             | Cast tipe hanya saat `INSERT ... SELECT`                                                 | Data asli tetap utuh dan kegagalan cast mudah dilacak                                                     |

## 2. Validasi integritas

- Tidak ada PK duplikat dan tidak ada baris yatim (orphan) pada FK di keenam tabel.
- Total order sama dengan jumlah item order (rekonsiliasi lolos).
- Satu sesi menghasilkan paling banyak satu order (diverifikasi), sehingga `LEFT JOIN` sesi ke order tidak menggandakan baris.
- Tidak ada kolom status order, jadi semua order dianggap valid.
- Jumlah pageview halaman thank-you sama dengan jumlah order.

## 3. Definisi dan aturan bisnis

- **Channel:**
  - Sesi dengan UTM → `utm_source / utm_campaign`.
  - Tanpa UTM dan tanpa `http_referer` → `direct`.
  - Tanpa UTM tapi punya `http_referer` → `organic_search`.
  - `channel_group`: direct, organic_search, paid_search, paid_social.
- **Margin kotor:** harga − COGS.
- **Margin bersih:** harga − COGS − nilai refund. Asumsi: COGS tidak kembali saat refund (barang rusak atau hilang). Kalau asumsi ini salah, margin bersih terlalu rendah.
- **Refund:** diagregasi per `order_item_id` sebelum di-join agar tidak terjadi penggandaan baris (fan-out).
- **Funnel:** memakai flag "pernah mengunjungi langkah" (`MAX(CASE ...)`) tanpa pemeriksaan urutan.
  - Landing page digabung: `/home`, `/lander-1` sampai `/lander-5`.
  - Billing digabung: `/billing`, `/billing-2`.
  - Halaman produk dikenali dengan `LIKE '/the-%'`.

## 4. Keterbatasan data dan cara membaca hasil

- **Bulan tidak penuh:** Mar 2012 dan Mar 2015. Dikeluarkan dari pembacaan pertumbuhan dan tren.
- **Bulan sesi vs bulan item:** di Q1, jumlah order dihitung berdasarkan bulan sesi, sedangkan pendapatan berdasarkan bulan item order. Ada selisih kecil di batas bulan.
- **Periode aktif channel berbeda** (misalnya socialbook hanya 2014). Perbandingan channel dilakukan pada periode yang sama, bukan total semua waktu.
- **Tidak ada data biaya iklan:** hanya kualitas traffic (konversi, pendapatan per sesi) yang bisa dinilai, bukan efisiensi atau ROI.
- **Korelasi bukan sebab:** peluncuran produk berbarengan dengan perubahan lain (uji landing page, channel baru), jadi kenaikan konversi tidak bisa diatribusikan ke satu penyebab.
- **Dataset kemungkinan hasil simulasi:** hanya 4 produk dan pola yang rapi. Kesimpulan tidak boleh digeneralisasi ke bisnis nyata.
- **Perbandingan lintas filter:** angka dari filter berbeda (misalnya semua device vs desktop saja) tidak boleh dibandingkan langsung.

## 5. Catatan perubahan

| Tanggal    | Perubahan      |
| ---------- | -------------- |
| 18/10/2026 | Dokumen dibuat |
