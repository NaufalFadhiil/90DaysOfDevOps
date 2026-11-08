# 🔒 Day 10: Linux File Permissions & Security Management Challenge

- **Target Pembelajaran:** Penguasaan Manajemen Izin Berkas (File Permissions), Notasi Oktal vs Simbolik, Mekanisme Umask, dan Penegakan Prinsip *Least Privilege* di Linux.
- **Studi Kasus:** Pengamanan Berkas Konfigurasi, Eksekusi Skrip Otomasi CI/CD, dan Isolasi Izin Akses Direktori Proyek.
- **Lingkungan Uji:** Debian GNU/Linux 13 (Trixie, Kernel 6.12.x, x86_64).
- **Standar Industri:** Principle of Least Privilege, Access Isolation, Hardening Secrets (SSH Keys, Environment Variables), Secure Script Execution.

---

## 🧭 Bagian 1: Pembuatan Berkas & Inspeksi Izin Awal (Task 1 & 2)

Pada tahap awal, kita membuat beberapa jenis berkas kerja standar (berkas kosong, berkas catatan teks, dan skrip Bash) untuk mengamati bagaimana Linux menetapkan izin akses bawaan (*default permissions*).

### 1. Eksekusi Pembuatan Berkas (Task 1)

```bash
# 1. Membuat file kosong menggunakan touch
touch devops.txt

# 2. Membuat file catatan dengan beberapa baris konten menggunakan echo/redirection
echo -e "DevOps Engineering Pillars:\n1. Infrastructure as Code\n2. CI/CD Automation\n3. Observability & SRE" > notes.txt

# 3. Membuat skrip eksekusi Bash
cat << 'EOF' > script.sh
#!/bin/bash
echo "Hello DevOps"
EOF
```

**Verifikasi Izin Awal dengan `ls -l`:**
```bash
ls -l devops.txt notes.txt script.sh
```

**Output Nyata Terminal:**
```text
-rw-rw-rw- 1 noop noop  0 Nov  4 00:17 devops.txt
-rw-rw-rw- 1 noop noop 97 Nov  4 00:17 notes.txt
-rw-rw-rw- 1 noop noop 32 Nov  4 00:17 script.sh
```

---

### 2. Pembacaan Berkas & Inspeksi Akun Sistem (Task 2)

#### A. Membaca Berkas Lokal (`cat` dan `vim` read-only)
```bash
cat notes.txt
```
**Output:**
```text
DevOps Engineering Pillars:
1. Infrastructure as Code
2. CI/CD Automation
3. Observability & SRE
```

Untuk melihat berkas tanpa risiko memodifikasinya secara tidak sengaja di terminal produksi:
```bash
view script.sh       # atau vim -R script.sh (Read-only mode)
```

#### B. Inspeksi Berkas Kredensial `/etc/passwd` (`head` & `tail`)
Berkas `/etc/passwd` berisi daftar pengguna sistem. Di lingkungan DevOps, memverifikasi akun sistem sering dilakukan dengan `head` (melihat akun sistem bawaan) dan `tail` (melihat akun pengguna atau engineer yang baru dibuat, seperti pada Day 09).

```bash
# 5 baris pertama: Akun sistem fundamental Linux
head -n 5 /etc/passwd
```
**Output Nyata:**
```text
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
```

```bash
# 5 baris terakhir: Akun kolaborator tim proyek (dari praktik Day 09)
tail -n 5 /etc/passwd
```
**Output Nyata:**
```text
chuck:x:1001:1001:,,,:/home/chuck:/bin/bash
tokyo:x:1002:1002::/home/tokyo:/bin/bash
berlin:x:1003:1003::/home/berlin:/bin/bash
professor:x:1004:1004::/home/professor:/bin/bash
nairobi:x:1005:1007::/home/nairobi:/bin/bash
```

---

## 🔬 Bagian 2: Dekonstruksi Mendalam Model Izin Berkas Linux (Task 3)

### 1. Anatomi 10 Karakter String Izin (*Permission String*)

Setiap baris output `ls -l` diawali oleh 10 karakter penentu hak akses:

```text
 -   r w x   r - x   r - -
[0] [1 2 3] [4 5 6] [7 8 9]
 |     |       |       |
 |     |       |       +---> Others (Pengguna lain di luar sistem/grup)
 |     |       +-----------> Group (Anggota grup pemilik berkas)
 |     +-------------------> Owner / User (Pemilik berkas)
 +-------------------------> File Type (- = file biasa, d = direktori, l = link)
```

### 2. Matriks Representasi Biner & Oktal

Di balik representasi simbolik (`rwx`), kernel Linux menghitung hak akses menggunakan bit biner 3-digit:

| Operasi | Simbol | Nilai Biner | Bobot Oktal | Deskripsi |
| :--- | :---: | :---: | :---: | :--- |
| **Read** | `r` | `100` | **4** | Izin membaca isi berkas / melihat daftar file direktori |
| **Write** | `w` | `010` | **2** | Izin memodifikasi isi berkas / menambah/menghapus file direktori |
| **Execute** | `x` | `001` | **1** | Izin menjalankan berkas program / melakukan *traversal* ke direktori |
| **No Access**| `-` | `000` | **0** | Tidak ada hak akses |

**Formula Perhitungan Oktal:**
$$\text{Oktal} = \sum (\text{Bobot Bit Aktif})$$
- `rwx` = $4 + 2 + 1 = 7$
- `rw-` = $4 + 2 + 0 = 6$
- `r-x` = $4 + 0 + 1 = 5$
- `r--` = $4 + 0 + 0 = 4$
- `---` = $0 + 0 + 0 = 0$

---

### 3. Perbedaan Krusial `rwx` pada File vs Direktori

Salah satu kesalahpahaman umum di kalangan pemula DevOps adalah menganggap `rwx` bekerja identik pada file dan folder.

| Izin | Efek pada Berkas Regular (File) | Efek pada Direktori (Folder) |
| :---: | :--- | :--- |
| **`r` (Read)** | Mengizinkan membaca data berkas (contoh: `cat file.txt`). | Mengizinkan melihat daftar nama berkas di dalamnya (`ls directory/`). |
| **`w` (Write)** | Mengizinkan menambah atau memotong konten berkas. | Mengizinkan membuat (`touch`), menghapus (`rm`), atau mengubah nama berkas di dalam direktori. |
| **`x` (Execute)** | Mengizinkan berkas dieksekusi sebagai program/skrip biner. | Mengizinkan **masuk ke dalam direktori (`cd`)** dan mengakses metadata (inode) berkas di dalamnya (*Directory Traversal*). |

> ⚠️ **Catatan Penting SRE:** Sebuah direktori dengan izin `r--` memungkinkan user melihat nama file di dalamnya, namun tanpa izin `x`, user **tidak dapat** membaca isi file tersebut atau melihat ukuran dan atributnya! Oleh sebab itu, direktori standar Linux selalu membutuhkan bit `x` (contoh: `755`).

---

### 4. Peran Nilai `umask` pada Berkas Baru

Mengapa file yang baru dibuat tidak otomatis memiliki izin `777` atau `666`?
Kernel Linux menerapkan nilai **`umask` (User Mask)** sebagai filter bitwise pengurangan hak akses:
- **Izin Maksimal Bawaan File:** `666` (`rw-rw-rw-`)
- **Izin Maksimal Bawaan Direktori:** `777` (`rwxrwxrwx`)
- **Formula:**
  $$\text{Izin Efektif} = \text{Izin Maksimal} - \text{umask}$$

Pada server produksi standar Debian/Ubuntu dengan umask `0022`:
- File baru: $666 - 022 = \mathbf{644}$ (`-rw-r--r--`)
- Direktori baru: $777 - 022 = \mathbf{755}$ (`drwxr-xr-x`)

---

## 🛠️ Bagian 3: Modifikasi Hak Akses & Studi Kasus Penerapan (Task 4)

Kita menerapkan modifikasi hak akses menggunakan dua metode: **Notasi Simbolik** (`+`, `-`, `=`) dan **Notasi Oktal Angka**.

### 1. Menjadikan `script.sh` Executable
Skrip Bash memerlukan izin eksekusi (`x`) agar dapat diluncurkan langsung melalui `./script.sh`.

```bash
# Memberikan izin eksekusi
chmod +x script.sh

# Eksekusi skrip
./script.sh
```

**Output Nyata:**
```text
Hello DevOps
```

**Verifikasi Izin:**
```bash
ls -l script.sh
# Output: -rwxr-xr-x 1 noop noop 32 Nov  4 00:17 script.sh
```

---

### 2. Mengubah `devops.txt` Menjadi Read-Only
Untuk melindungi file log audit atau file konfigurasi statis agar tidak dapat diubah oleh siapapun:

```bash
# Menghapus izin tulis (write) untuk semua entitas (all: u, g, o)
chmod a-w devops.txt

# Atau menggunakan notasi oktal murni
chmod 444 devops.txt
```

**Verifikasi Izin:**
```bash
ls -l devops.txt
# Output: -r--r--r-- 1 noop noop 0 Nov  4 00:17 devops.txt
```

---

### 3. Mengatur `notes.txt` ke Pola Izin Restricted (`640`)
Standar industri untuk file konfigurasi sensitif (seperti konfigurasi aplikasi web yang dibaca oleh grup `www-data`):
- **Owner:** Read & Write ($4 + 2 = 6$)
- **Group:** Read Only ($4 = 4$)
- **Others:** No Access ($0 = 0$)

```bash
chmod 640 notes.txt
```

**Verifikasi Izin:**
```bash
ls -l notes.txt
# Output: -rw-r----- 1 noop noop 97 Nov  4 00:17 notes.txt
```

---

### 4. Membuat Direktori `project/` dengan Izin Standar `755`
Direktori kerja kolaboratif yang dapat dimasuki oleh seluruh user, namun hanya owner yang dapat menambah atau menghapus file:

```bash
mkdir -p project
chmod 755 project
```

**Verifikasi Izin:**
```bash
ls -ld project
# Output: drwxr-xr-x 2 noop noop 4096 Nov  4 00:17 project
```

---

### 5. Matriks Perubahan Hak Akses (Before vs After)

| Berkas / Direktori | Izin Awal (Symbolic / Octal) | Izin Akhir (Symbolic / Octal) | Justifikasi Arsitektur DevOps |
| :--- | :---: | :---: | :--- |
| **`script.sh`** | `-rw-rw-rw-` (`666`) | `-rwxr-xr-x` (`755`) | Skrip otomasi CI/CD & deployment wajib memiliki bit eksekusi. |
| **`devops.txt`** | `-rw-rw-rw-` (`666`) | `-r--r--r--` (`444`) | Berkas baseline audit / referensi sistem berstatus *immutable read-only*. |
| **`notes.txt`** | `-rw-rw-rw-` (`666`) | `-rw-r-----` (`640`) | Konfigurasi internal: hanya tim/grup terdaftar yang boleh membaca. |
| **`project/`** | - | `drwxr-xr-x` (`755`) | Direktori kerja dengan izin akses traversal (`x`) bagi seluruh anggota sistem. |

---

## 🛡️ Bagian 4: Pengujian Keamanan & Dokumentasi Pesan Error (Task 5)

Sebagai engineer DevOps, memahami bagaimana sistem menolak akses (*access denial*) dan membaca pesan error kernel adalah kunci utama saat mendiagnosis kegagalan pipeline atau container.

### 1. Skenario Error 1: Menulis ke Berkas Read-Only
Mencoba memodifikasi berkas `devops.txt` yang telah disetel ke mode baca-saja:

```bash
echo "Unauthorized modification attempt" >> devops.txt
```

**Output Error Nyata:**
```text
bash: devops.txt: Permission denied
```

**Root Cause Analysis (RCA):**
- Kernel Linux memeriksa mode bit inode berkas saat menerima system call `open(path, O_WRONLY|O_CREAT|O_APPEND)`.
- Karena bit `w` bernilai `0` untuk owner (`noop`), kernel langsung menghentikan syscall dan mengembalikan kode error `EACCES (Permission denied)`.
- **Implementasi Industri:** Mencegah modifikasi data konfigurasi secara tidak sengaja oleh skrip background atau malware.

---

### 2. Skenario Error 2: Menjalankan Skrip Tanpa Izin Eksekusi
Mencoba mengeksekusi skrip setelah mencabut bit eksekusi (`chmod -x`):

```bash
chmod -x script.sh
./script.sh
```

**Output Error Nyata:**
```text
bash: ./script.sh: Permission denied
```

**Root Cause Analysis (RCA):**
- Saat program dijalankan melalui `./script.sh`, shell memanggil syscall `execve()`.
- Kernel memeriksa bit `x` (execute) pada berkas biner/skrip. Tanpa bit tersebut, kernel menolak membuat konteks proses baru (*Process Address Space*).
- **Implementasi Industri:** Di runner CI/CD (seperti GitHub Actions), error ini sering muncul ketika developer lupa menjalankan `chmod +x entrypoint.sh` sebelum commit ke Git.

---

### 3. Matriks Referensi Keamanan Izin Berkas di Lingkungan Produksi

| File / Komponen Produksi | Rekomendasi Permission | Dampak Jika Izin Terlalu Terbuka (Salah Konfigurasi) |
| :--- | :---: | :--- |
| **Private SSH Key (`~/.ssh/id_rsa`)** | `600` (`-rw-------`) | SSH client menolak koneksi: *"Permissions 0777 are too open. It is required that your private key files are NOT accessible by others."* |
| **Public SSH Key (`authorized_keys`)** | `644` atau `600` | SSH server OpenSSH akan menolak autentikasi public key jika file writable oleh pihak luar. |
| **Web Server Root (`/var/www/html`)** | `755` (Dir), `644` (File) | Jika disetel `777`, penyerang (*attacker*) dapat mengunggah file PHP berbahaya (*web shell*). |
| **Environment Secrets (`.env`)** | `600` atau `640` | Mencegah pembocoran database credentials dan API tokens ke akun sistem non-privilege. |

---

## 📋 Bagian 5: Ringkasan Perintah Penting (Command Toolkit)

- `ls -l <file>` : Memeriksa izin, kepemilikan user, grup, dan ukuran file.
- `ls -ld <dir>` : Memeriksa izin khusus direktori (tanpa menampilkan isi dalamnya).
- `chmod <octal> <file>` : Mengubah izin berkas dengan notasi angka 3-digit (contoh: `chmod 755 app.sh`).
- `chmod [u/g/o/a][+/-/=][r/w/x] <file>` : Mengubah izin secara simbolik (contoh: `chmod u+x,g-w deploy.sh`).
- `chmod -R <octal> <dir>` : Menerapkan perubahan izin secara rekursif ke seluruh sub-direktori dan file.
- `head -n <N> <file>` : Menampilkan N baris pertama dari suatu berkas konfigurasi.
- `tail -n <N> <file>` : Menampilkan N baris terakhir dari suatu berkas log atau user.
- `umask` : Memeriksa nilai mask sistem saat ini yang mengontrol izin bawaan berkas baru.

---

## 💡 Bagian 6: Pelajaran Kunci (Key Takeaways)

1. **Prinsip Least Privilege Bukan Sekadar Teori:** Di produksi, jangan pernah menggunakan jalan pintas `chmod 777`. Setiap berkas harus memiliki hak akses seminimal mungkin yang diperlukan untuk menjalankan fungsinya secara aman.
2. **Oktal adalah Representasi Biner:** Memahami perhitungan biner ($4-2-1$) memungkinkan engineer menghitung dan mengaudit permission secara instan di kepala tanpa perlu bergantung pada tabel referensi.
3. **Eksekusi Direktori vs File:** Bit `x` pada direktori adalah izin krusial untuk melintasi folder (*directory traversal*). Mematikan bit `x` pada direktori akan memutus akses ke seluruh file di dalamnya, meskipun file-file tersebut memiliki izin `r` penuh.
4. **Validasi Error di CI/CD:** Pesan `Permission denied` pada pipeline otomasi hampir selalu bermuara pada ketiadaan bit `+x` pada runner atau kontainer non-root yang mencoba menulis ke direktori yang tidak diizinkan.

