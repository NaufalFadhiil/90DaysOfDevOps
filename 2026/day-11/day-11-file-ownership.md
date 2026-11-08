# 👑 Day 11: Linux File Ownership Challenge (`chown` & `chgrp`)

- **Target Pembelajaran:** Penguasaan Manajemen Kepemilikan Berkas (*User & Group Ownership*), Operasi Atomik `owner:group`, dan Pembaruan Kepemilikan Rekursif (*Recursive Ownership*) di Linux.
- **Studi Kasus:** Tata Kelola Hak Akses Proyek Multi-Tier, Isolasi Data Tim (*Role-Based Access Control*), dan Standardisasi Kepemilikan Lingkungan Produksi.
- **Lingkungan Uji:** Debian GNU/Linux 13 (Trixie, Kernel 6.12.x, x86_64).
- **Standar Industri:** Principle of Least Privilege, Access Isolation, Secure Container Volume Mapping, Multi-Engineer Collaboration.

---

## 🧭 Bagian 1: Konsep Fundamental & Anatomi Kepemilikan (Task 1)

Setiap entitas (berkas maupun direktori) di Linux memiliki dua tingkat kepemilikan utama yang dicatat langsung pada *inode*:
1. **User Owner:** Pengguna tunggal yang memiliki berkas. User ini berhak menentukan izin akses (`chmod`) dan memiliki kontrol penuh atas berkas.
2. **Group Owner:** Grup sistem yang menaungi sekumpulan pengguna untuk berbagi izin akses ke berkas tersebut.

### 1. Anatomi Output `ls -l`
```text
drwxrwxr-x 2 berlin    heist-team 4096 Nov  8 10:58 app-logs
-rw-rw-r-- 1 professor heist-team    0 Nov  8 10:58 project-config.yaml
              └───┬───┘ └───┬────┘
              Owner (u)   Group (g)
```

---

## 🛠️ Bagian 2: Operasi Dasar `chown` & `chgrp` (Task 2 & 3)

### 1. Mengubah User Owner dengan `chown` (Task 2)
Operasi perubahan pemilik file `devops-file.txt`:
```bash
# Pembuatan dan pengecekan awal
touch devops-file.txt
ls -l devops-file.txt
# Awal: milik noop:noop

# Mengubah pemilik ke user tokyo
sudo chown tokyo devops-file.txt

# Mengubah pemilik ke user berlin
sudo chown berlin devops-file.txt
```

**Verifikasi:**
```text
-rw-rw-r-- 1 berlin noop 0 Nov  8 10:42 devops-file.txt
```
> 💡 **Prinsip Keamanan:** Di Linux, hanya pengguna `root` (atau via `sudo`) yang diizinkan memindahkan kepemilikan berkas ke user lain (*chown*). Pengguna biasa tidak dapat "menyerahkan" file miliknya ke pengguna lain untuk mencegah pengalihan kuota disk (*disk quota abuse*) atau jebakan keamanan (*Trojan drop*).

---

### 2. Mengubah Group Owner dengan `chgrp` (Task 3)
Operasi pembuatan grup baru dan penggantian grup file `team-notes.txt`:
```bash
# Pembuatan file dan grup sistem baru
touch team-notes.txt
sudo groupadd heist-team

# Mengubah grup kepemilikan berkas
sudo chgrp heist-team team-notes.txt
```

**Verifikasi:**
```text
-rw-rw-r-- 1 noop heist-team 0 Nov  8 10:43 team-notes.txt
```

---

## ⚡ Bagian 3: Operasi Gabungan Owner & Group (`chown user:group`) (Task 4)

Daripada menjalankan `chown` dan `chgrp` secara terpisah, standar industri menggunakan sintaks gabungan titik dua (`:`) yang bersifat atomik:
$$\text{Syntax:} \quad \mathbf{\text{sudo chown <owner>:<group> <target>}}$$

### 1. Eksekusi Perintah
```bash
# File konfigurasi: owner professor, group heist-team
touch project-config.yaml
sudo chown professor:heist-team project-config.yaml

# Folder aplikasi: owner berlin, group heist-team
mkdir app-logs
sudo chown berlin:heist-team app-logs
```

### 2. Bukti Nyata Terminal
```bash
ls -ld project-config.yaml app-logs
```
**Output Nyata Terminal:**
```text
drwxrwxr-x 2 berlin    heist-team 4096 Nov  8 10:58 app-logs
-rw-rw-r-- 1 professor heist-team    0 Nov  8 10:58 project-config.yaml
```

---

## 🌲 Bagian 4: Manajemen Kepemilikan Rekursif (`chown -R`) (Task 5)

Pada arsitektur aplikasi (seperti deployment source code web atau persistent volume database), direktori biasanya memiliki sub-folder dan ribuan file turunan. Mengubah ownership satu per satu tidak realistis, sehingga digunakan flag rekursif **`-R`**.

### 1. Struktur Direktori Bertingkat
```bash
mkdir -p heist-project/vault
mkdir -p heist-project/plans
touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
sudo groupadd planners
```

### 2. Eksekusi Recursive Ownership
```bash
sudo chown -R professor:planners heist-project
```

### 3. Bukti Nyata Terminal (`ls -lR`)
```bash
ls -lR heist-project
```
**Output Nyata Terminal:**
```text
heist-project:
total 8
drwxrwxr-x 2 professor planners 4096 Nov  8 11:01 plans
drwxrwxr-x 2 professor planners 4096 Nov  8 11:01 vault

heist-project/plans:
total 0
-rw-rw-r-- 1 professor planners 0 Nov  8 11:01 strategy.conf

heist-project/vault:
total 0
-rw-rw-r-- 1 professor planners 0 Nov  8 11:01 gold.txt
```
> 🛡️ **Validasi:** Seluruh sub-direktori (`plans/`, `vault/`) beserta berkas di dalamnya (`strategy.conf`, `gold.txt`) sukses mewarisi kepemilikan `professor:planners` secara menyeluruh dan seragam.

---

## 🏦 Bagian 5: Skenario Studi Kasus Multi-Role (`bank-heist`) (Task 6)

Simulasi tata kelola isolasi data sensitif pada proyek perbankan dengan pemisahan tugas (*Segregation of Duties*):

### 1. Penyiapan Grup dan Berkas
```bash
sudo groupadd vault-team
sudo groupadd tech-team

mkdir -p bank-heist
touch bank-heist/access-codes.txt
touch bank-heist/blueprints.pdf
touch bank-heist/escape-plan.txt
```

### 2. Matriks Penerapan Kepemilikan
```bash
sudo chown tokyo:vault-team bank-heist/access-codes.txt
sudo chown berlin:tech-team bank-heist/blueprints.pdf
sudo chown nairobi:vault-team bank-heist/escape-plan.txt
```

### 3. Bukti Nyata Terminal
```bash
ls -l bank-heist
```
**Output Nyata Terminal:**
```text
total 0
-rw-rw-r-- 1 tokyo   vault-team 0 Nov  8 11:03 access-codes.txt
-rw-rw-r-- 1 berlin  tech-team  0 Nov  8 11:04 blueprints.pdf
-rw-rw-r-- 1 nairobi vault-team 0 Nov  8 11:04 escape-plan.txt
```

---

## 🏢 Bagian 6: Analisis Kasus Nyata di Industri DevOps & SRE

### 1. Insiden "Permission Denied" pada Nginx Web Root
- **Masalah:** Aplikasi web memunculkan `500 Internal Server Error` saat mengunggah gambar produk.
- **Akar Masalah (RCA):** File di-deploy oleh CI/CD runner menggunakan user `root` atau `ubuntu`, sedangkan worker process Nginx berjalan di bawah user `www-data`.
- **Solusi Industri:**
  ```bash
  sudo chown -R www-data:www-data /var/www/html/storage/
  ```

### 2. Insiden Docker Volume Bind Mount
- **Masalah:** Aplikasi Node.js di dalam container crash saat startup dengan error `EACCES: permission denied, open '/app/logs/server.log'`.
- **Akar Masalah (RCA):** Direktori log di host dibuat oleh user root atau user host dengan UID berbeda dari non-root user di dalam Docker container (misalnya user `node` dengan UID 1000).
- **Solusi Industri:** Menyesuaikan UID/GID host atau mengubah kepemilikan volume mount agar sesuai dengan UID runtime container:
  ```bash
  sudo chown -R 1000:1000 ./host-app-data/
  ```

---

## 📋 Bagian 7: Ringkasan Perintah Penting (Command Toolkit)

- `ls -l <file>` : Melihat pemilik (*user*) dan grup (*group*) dari suatu file.
- `ls -ld <dir>` : Melihat kepemilikan direktori tanpa melihat file di dalamnya.
- `sudo chown <user> <file>` : Mengubah user pemilik berkas.
- `sudo chgrp <group> <file>` : Mengubah grup pemilik berkas.
- `sudo chown <user>:<group> <target>` : Mengubah pemilik dan grup sekaligus secara atomik.
- `sudo chown -R <user>:<group> <dir>` : Mengubah kepemilikan direktori secara rekursif ke seluruh file dan folder di dalamnya.
- `sudo chown :<group> <file>` : Alternatif mengganti grup menggunakan sintaks `chown`.

---

## 💡 Bagian 8: Pelajaran Kunci (Key Takeaways)

1. **Efisiensi Sintaks Gabungan:** Sintaks `chown user:group` adalah standar de-facto di script deployment otomasi karena mengeksekusi satu system call yang lebih cepat dan aman dibanding memisahkannya dengan `chgrp`.
2. **Kekuatan Flag `-R`:** Memastikan tidak ada file yang "tertinggal" dengan izin lama saat melakukan migrasi atau provisioning server baru.
3. **Pemisahan Peran (*Segregation of Duties*):** Mengelompokkan berkas ke grup yang tepat (`vault-team`, `tech-team`) mencegah personil yang tidak berkepentingan mengakses berkas sensitif, mendukung kepatuhan audit keamanan (*security compliance*).

