# 📝 Day 06: Linux Fundamentals – Read and Write Text Files (File I/O)

- **Target Pembelajaran:** Penguasaan Manipulasi File Teks, Redirection Streams (`>` vs `>>`), dan Piping (`tee`)
- **File Praktik:** `notes.txt`
- **Lingkungan Uji:** Linux Terminal (Bash Shell)
- **Konteks DevOps:** Modifikasi file konfigurasi server, inject environment variables, dan append public SSH keys.

---

## 🧠 Konsep Inti: Standar Streams di Linux (I/O Redirection)

Setiap proses di Linux secara default memiliki 3 aliran komunikasi data (*Streams*):
1. **`stdin` (Standard Input - File Descriptor 0):** Menerima input dari keyboard.
2. **`stdout` (Standard Output - File Descriptor 1):** Mengirim output normal ke layar terminal.
3. **`stderr` (Standard Error - File Descriptor 2):** Mengirim pesan kesalahan/error ke layar terminal.

Simbol **Redirection** memungkinkan DevOps Engineer mengalihkan aliran output ini langsung ke dalam berkas teks:
- **`>` (Overwrite / Timpa Habis):** Mengosongkan file target jika sudah ada, lalu menulis teks baru dari awal.
- **`>>` (Append / Tambah di Akhir):** Mempertahankan isi file yang sudah ada, lalu menyisipkan baris baru di baris paling bawah.

> ⚠️ **Catatan Kritis Keamanan DevOps (Incident Caution):**  
> Jangan pernah salah menggunakan `>` saat menambahkan SSH Public Key!  
> - `echo "ssh-key..." >> ~/.ssh/authorized_keys`  (Benar: Menambah akses baru).  
> - `echo "ssh-key..." > ~/.ssh/authorized_keys`   (Fatal: Menghapus semua akses SSH yang lama!).

---

## 🛠️ Alur Eksekusi Perintah & Pembahasan Mendalam

### 1. Inisialisasi File Berkas Baru

#### Command 1: `touch notes.txt`
- **Fungsi:** Membuat file kosong baru bernama `notes.txt`. Jika file sudah ada, perintah ini hanya memperbarui cap waktu (*timestamp*) modifikasi tanpa merusak isinya.
- **Output:** *(Exit code 0, file berhasil dibuat)*

---

### 2. Menulis & Menyisipkan Teks (Redirection)

#### Command 2: `echo "Line 1: Inisialisasi konfigurasi server produksi." > notes.txt`
- **Fungsi:** Menulis baris pertama ke dalam file. Karena menggunakan operator tunggal `>`, file dibuat dari nol atau ditimpa bersih.

#### Command 3: `echo "Line 2: Menambahkan parameter port reverse proxy Nginx." >> notes.txt`
- **Fungsi:** Menambahkan baris kedua di akhir file menggunakan operator ganda `>>` (*append mode*). Isi baris pertama tetap aman.

#### Command 4: `echo "Line 3: Mengaktifkan mode TLS/SSL Certificate Let's Encrypt." >> notes.txt`
- **Fungsi:** Menambahkan baris ketiga tanpa menimpa baris 1 dan 2.

---

### 3. Membaca Isi Berkas Teks (File Inspection)

#### Command 5: `cat notes.txt`
- **Fungsi:** Menampilkan seluruh isi file sekaligus ke layar terminal (*concatenate and display*).
- **Output Nyata:**
  ```text
  Line 1: Inisialisasi konfigurasi server produksi.
  Line 2: Menambahkan parameter port reverse proxy Nginx.
  Line 3: Mengaktifkan mode TLS/SSL Certificate Let's Encrypt.
  ```
- **Kapan DevOps memakainya?** Cocok untuk file konfigurasi kecil (di bawah 50 baris). Jangan gunakan `cat` untuk file log berukuran gigabyte karena akan membuat terminal *freeze*.

---

### 4. Membaca Bagian Awal & Akhir Berkas

#### Command 6: `head -n 2 notes.txt`
- **Fungsi:** Membaca **2 baris pertama** dari puncak file.
- **Output:**
  ```text
  Line 1: Inisialisasi konfigurasi server produksi.
  Line 2: Menambahkan parameter port reverse proxy Nginx.
  ```
- **Skenario DevOps:** Memeriksa baris header CSV atau baris deklarasi shebang (`#!/bin/bash`) pada skrip shell.

#### Command 7: `tail -n 2 notes.txt`
- **Fungsi:** Membaca **2 baris terakhir** dari dasar file.
- **Output:**
  ```text
  Line 2: Menambahkan parameter port reverse proxy Nginx.
  Line 3: Mengaktifkan mode TLS/SSL Certificate Let's Encrypt.
  ```
- **Skenario DevOps:** Perintah paling sering digunakan bersama flag `-f` (`tail -f`) untuk memantau aktivitas transaksi atau error terbaru di server secara live.

---

### 5. Menulis Sekaligus Membaca dengan `tee`

#### Command 8: `echo "Line 4: Catatan otomatis dari pipeline via command tee." | tee -a notes.txt`
- **Fungsi Perintah:**
  `tee` bekerja seperti persimpangan pipa air berbentuk huruf "T": ia memecah satu aliran input menjadi dua arah secara bersamaan:
  1. Menulis teks ke dalam file `notes.txt`.
  2. Sekaligus mencetak teks tersebut ke layar terminal.
- **Bedah Flag `-a`:**
  - `-a` (*append*): Memastikan `tee` menambahkan teks di akhir berkas tanpa menimpa isi lama.
- **Output yang Muncul di Terminal:**
  ```text
  Line 4: Catatan otomatis dari pipeline via command tee.
  ```

#### 🌟 Mengapa `tee` adalah Perintah Wajib DevOps? (Trik `sudo`)
Seringkali saat ingin mengedit file sistem terlindungi sebagai user biasa, perintah ini gagal:
`sudo echo "127.0.0.1 api.local" >> /etc/hosts` ➔ **Error: Permission denied!**  
*Penyebab:* Shell yang mengeksekusi redirection `>>` berjalan sebagai user biasa, bukan `root`.

**Solusi Standar DevOps:**
`echo "127.0.0.1 api.local" | sudo tee -a /etc/hosts`  
Perintah `tee` yang dijalankan dengan hak `sudo` akan berhasil menulis ke file sistem dengan aman!
