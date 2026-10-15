# 🗺️ Day 07: Linux File System Hierarchy & Scenario-Based Practice

- **Target Pembelajaran:** Penguasaan Struktur Direktori Linux (Filesystem Hierarchy Standard - FHS) & Alur Pemecahan Masalah (Troubleshooting Flow)
- **Dokumen Output:** `day-07-linux-fs-and-scenarios.md`
- **Lingkungan Uji:** Linux Server (Debian / Ubuntu / RHEL)
- **Prinsip Utama:** *Always check status first, trace logs, identify root cause, mitigate with minimal impact.*

---

## 🧭 Bagian 1: Linux File System Hierarchy (FHS)

Di Linux, seluruh file dan direktori bermula dari satu akar tunggal yaitu **`/` (root)**. Tidak ada konsep drive terpisah seperti `C:\\` atau `D:\\` di Windows.

### 1. Direktori Inti (Core Directories - Must Know)

| Direktori | Deskripsi & Isi Berkas | Contoh Berkas Nyata | Kapan DevOps Menggunakannya? |
| :--- | :--- | :--- | :--- |
| **`/`** | Akar tertinggi dari seluruh sistem berkas Linux. Semua partisi dan folder lain berada di bawahnya. | `bin`, `etc`, `var`, `home` | Saat memeriksa mount point storage utama menggunakan `df -h /`. |
| **`/etc`** | Pusat berkas konfigurasi sistem dan aplikasi. Hanya berisi teks konfigurasi statis, tidak ada binary eksekusi. | `/etc/hosts`, `/etc/nginx/nginx.conf`, `/etc/resolv.conf` | Saat mengubah konfigurasi web server, port database, atau setting DNS host. |
| **`/var/log`** | Pusat penyimpanan file log dari sistem operasi, kernel, dan aplikasi background. | `/var/log/syslog`, `/var/log/nginx/access.log`, `/var/log/auth.log` | Saat melakukan investigasi error aplikasi (500 Internal Server Error) atau audit keamanan login. |
| **`/home`** | Direktori tempat tinggal dan berkas kerja bagi user biasa (*non-root*). | `/home/naufal/.bashrc`, `/home/naufal/.ssh/authorized_keys` | Tempat menaruh kode aplikasi, konfigurasi lingkungan user, dan skrip personal. |
| **`/root`** | Direktori kerja khusus untuk user Superadmin (`root`). Terpisah dari `/home` demi keamanan dan ketersediaan saat mode darurat. | `/root/.ssh/id_ed25519` | Saat melakukan administrasi sistem tingkat rendah atau maintenance mode. |
| **`/tmp`** | Direktori berkas sementara (*temporary*). Sistem otomatis membersihkan isinya saat reboot atau berkala. | `/tmp/app.sock`, `/tmp/session_data.tmp` | Tempat aplikasi menyimpan cache sementara atau menguji izin tulis storage (*filesystem sanity*). |

---

### 2. Direktori Tambahan (Additional Directories - Good to Know)

| Direktori | Deskripsi & Isi Berkas | Contoh Berkas Nyata | Kapan DevOps Menggunakannya? |
| :--- | :--- | :--- | :--- |
| **`/bin` & `/usr/bin`** | Berisi berkas executable/binary perintah dasar sistem (CLI). | `/bin/ls`, `/bin/cat`, `/usr/bin/docker`, `/usr/bin/git` | Jalur utama pencarian perintah eksekusi yang didaftarkan di variabel `$PATH`. |
| **`/opt`** | Tempat instalasi aplikasi pihak ketiga (*optional / third-party standalone software*). | `/opt/google/`, `/opt/gitlab/`, `/opt/datadog-agent/` | Saat memasang agen monitoring enterprise atau software proprietary di luar package manager distro. |
| **`/proc` & `/sys`** | *Virtual filesystem* yang di-generate langsung oleh kernel di memori RAM (bukan di hard disk). | `/proc/cpuinfo`, `/proc/meminfo`, `/proc/<PID>/` | Saat ingin memeriksa informasi hardware real-time atau detail internal dari proses tertentu. |

---

### 3. Hands-on Commands Penting untuk File System

```bash
# 1. Melacak 5 file log terbesar di /var/log (mencegah disk penuh)
du -sh /var/log/* 2>/dev/null | sort -h | tail -5

# Output Nyata:
# 12M     /var/log/syslog.1
# 24M     /var/log/journal
# 48M     /var/log/nginx
# 110M    /var/log/syslog
# 280M    /var/log/audit/audit.log

# 2. Memeriksa identitas hostname server
cat /etc/hostname
# Output: debian-prod-server

# 3. Melihat file tersembunyi (dotfiles) di direktori home
ls -la ~
```

---

## 🛠️ Bagian 2: Scenario-Based Practice (Troubleshooting Flow)

---

### Contoh Kasus Terpecahkan (Solved Example)
**Kasus:** *"Bagaimana cara memeriksa apakah service web Nginx sedang aktif berjalan di server?"*

- **Langkah 1 (Cek Status Utama):**
  ```bash
  systemctl status nginx
  ```
  *Alasan:* Mengetahui status kesehatan instan (`active (running)` atau `failed`) beserta nomor PID-nya.
- **Langkah 2 (Cek Apakah Terdaftar):**
  ```bash
  systemctl list-units --type=service | grep -i nginx
  ```
  *Alasan:* Jika service tidak ditemukan, perintah ini memastikan apakah package Nginx memang terpasang di sistem.
- **Langkah 3 (Cek Konfigurasi Boot):**
  ```bash
  systemctl is-enabled nginx
  ```
  *Alasan:* Memastikan service otomatis menyala saat server reboot.

---

### Skenario 1: Service Web `myapp` Gagal Menyala (*Service Crash on Boot*)

**Deskripsi Masalah:**  
Aplikasi backend `myapp.service` dilaporkan mati setelah server di-reboot dan tidak dapat di-start kembali oleh tim developer.

**Alur Pemecahan Masalah (Step-by-Step):**

1. **Langkah 1: Periksa Status Service**
   ```bash
   sudo systemctl status myapp.service
   ```
   - *Hasil Observasi:* `Active: failed (Result: exit-code)` dengan exit code `1`.
2. **Langkah 2: Telusuri Log Error Terakhir**
   ```bash
   sudo journalctl -u myapp.service -n 30 --no-pager
   ```
   - *Hasil Observasi:* Ditemukan baris error fatal:  
     `Error: listen EADDRINUSE: address already in use 0.0.0.0:8080`
3. **Langkah 3: Cari Proses yang Membajak Port 8080**
   ```bash
   sudo ss -tulpn | grep :8080
   ```
   - *Hasil Observasi:* Ditemukan proses orphan lama `node` dengan PID `4512` yang masih menggantung.
4. **Langkah 4: Matikan Proses Pengganggu & Nyalakan Ulang Service**
   ```bash
   sudo kill -9 4512
   sudo systemctl start myapp.service
   sudo systemctl is-active myapp.service
   ```
   - *Hasil Akhir:* Mengembalikan status `active`. Aplikasi kembali melayani trafik pengguna.

---

### Skenario 2: Bencana Disk 100% Penuh (*Out of Disk Space Emergency*)

**Deskripsi Masalah:**  
Database PostgreSQL menolak transaksi baru dan memunculkan error: *"No space left on device"*.

**Alur Pemecahan Masalah (Step-by-Step):**

1. **Langkah 1: Konfirmasi Utilisasi Disk**
   ```bash
   df -h /
   ```
   - *Hasil Observasi:* Partisi root `/` menunjukkan `Use% 100%` (`Avail 0B`).
2. **Langkah 2: Cari Folder yang Menjadi Biang Kerok**
   ```bash
   du -sh /* 2>/dev/null | sort -rh | head -n 5
   ```
   - *Hasil Observasi:* Direktori `/var` memakan ruang `32GB` dari total `40GB`.
3. **Langkah 3: Telusuri Direktori Log**
   ```bash
   du -sh /var/log/* 2>/dev/null | sort -rh | head -n 5
   ```
   - *Hasil Observasi:* File `/var/log/journal/` membengkak hingga `22GB` karena akumulasi log sistem berbulan-bulan.
4. **Langkah 4: Bersihkan Log Lama dengan Aman**
   ```bash
   # Pangkas log systemd agar maksimal hanya memakan 500MB
   sudo journalctl --vacuum-size=500M
   df -h /
   ```
   - *Hasil Akhir:* Partisi root turun menjadi `48% Use`. Database kembali menerima penulisan data secara instan.

---

### Skenario 3: Utilisasi CPU Melonjak 100% (*High CPU Load Spike*)

**Deskripsi Masalah:**  
Monitoring server memicu alarm kritis: Utilisasi CPU rata-rata mencapai 98% selama 15 menit berturut-turut, menyebabkan request timeout pada user.

**Alur Pemecahan Masalah (Step-by-Step):**

1. **Langkah 1: Tangkap 5 Proses Pemakan CPU Terbesar**
   ```bash
   ps aux --sort=-%cpu | head -n 6
   ```
   - *Hasil Observasi:* Ditemukan satu proses aneh bernama `xmrig` (PID `7891`) yang memakan CPU `97.4%`.
2. **Langkah 2: Identifikasi Lokasi dan User Pemilik Proses**
   ```bash
   ls -l /proc/7891/exe
   ```
   - *Hasil Observasi:* Berkas binary mengarah ke `/tmp/.hidden/xmrig` dan dimiliki oleh user tak terdaftar. Teridentifikasi sebagai malware crypto miner.
3. **Langkah 3: Matikan Paksa Proses & Amankan Sistem**
   ```bash
   sudo kill -9 7891
   sudo rm -rf /tmp/.hidden
   ```
4. **Langkah 4: Validasi Ulang Beban CPU**
   ```bash
   top -b -n 1 | head -n 10
   ```
   - *Hasil Akhir:* Beban CPU turun kembali ke level normal `3.2%`.
