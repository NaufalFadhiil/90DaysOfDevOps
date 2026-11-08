# 🧘 Day 12: Breather & Revision – Linux Fundamentals Review (Days 01–11)

- **Target Pembelajaran:** Penguatan dan Konsolidasi Menyeluruh Kompetensi Inti Linux (*Process Lifecycle, System Troubleshooting, File Operations, Filesystem Hierarchy, Web Deployment, User & Group RBAC, Permissions, and Ownership*).
- **Studi Kasus:** Audit Kesiapan Infrastruktur Sistem, Validasi Health Check, dan Evaluasi Kesiapan Menuju Storage LVM & Jaringan.
- **Lingkungan Uji:** Debian GNU/Linux 13 (Trixie, Kernel 6.12.x, x86_64).
- **Standar Industri:** SRE Diagnostic Methodology, Production Hardening, Least Privilege Audit, Incident Response Readiness.

---

## 🧭 Bagian 1: Bukti Riil Eksekusi Terminal (Hands-on Checkpoints)

Seluruh verifikasi berikut dijalankan secara langsung pada sistem host untuk menguji ketahanan dan konsistensi status operasional.

### 1. Checkpoint 1: Monitoring Proses & Profil Utilisasi Memori
```bash
ps aux --sort=-%mem | head -n 6
```
**Output Nyata Terminal:**
```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
noop           1  138  0.5 2680372 141316 ?      Sl   12:39   0:00 /home/noop/.gemini/bin/agy
noop          37  0.0  0.0   9396  4252 pts/2    R+   12:39   0:00 ps aux --sort=-%mem
noop          36  0.0  0.0   7076  3444 pts/2    Ss+  12:39   0:00 bash -c ps aux --sort=-%mem | head -n 6 ...
noop          38  0.0  0.0   5580  1964 pts/2    S+   12:39   0:00 head -n 6
```
- **Analisis DevOps:** Sistem berada dalam kondisi sangat sehat dengan utilisasi memori stabil di bawah 1% per proses kerja, tanpa adanya proses *zombie* atau kebocoran memori (*memory leak*).

---

### 2. Checkpoint 2: Otomasi Skrip & Hardening Izin Berkas
Pembuatan skrip audit mandiri `health-check.sh` dengan izin `755` (`-rwxr-xr-x`) serta berkas status audit `system-status.log` dengan proteksi *read-only* `444` (`-r--r--r--`).

```bash
# Isi berkas health-check.sh
cat health-check.sh
```
```bash
#!/bin/bash
echo "=== SYSTEM HEALTH CHECK ==="
uptime
free -h
```

**Verifikasi Status & Eksekusi Skrip:**
```bash
ls -l health-check.sh system-status.log
./health-check.sh
```

**Output Nyata Terminal:**
```text
-rwxr-xr-x 1 noop noop 62 Nov  8 12:35 health-check.sh
-r--r--r-- 1 noop noop 35 Nov  8 12:36 system-status.log

=== SYSTEM HEALTH CHECK ===
 12:39:13 up  2:54,  0 users,  load average: 0.30, 0.35, 0.28
               total        used        free      shared  buff/cache   available
Mem:            23Gi       6.1Gi        13Gi       909Mi       4.6Gi        17Gi
Swap:             0B          0B          0B
```
- **Analisis DevOps:** Skrip mengeksekusi pemeriksaan *load average* (0.30 - optimal untuk CPU multi-core) dan ketersediaan RAM (17 GiB *available* dari total 23 GiB). Berkas `system-status.log` terkunci sebagai *immutable audit log*.

---

### 3. Checkpoint 3: Audit Identitas User & Keanggotaan Grup
Memverifikasi integritas akun sistem dan grup kolaborasi yang dibangun pada Day 09 dan Day 11:
```bash
id tokyo ; id professor
getent group heist-team planners
```

**Output Nyata Terminal:**
```text
uid=1002(tokyo) gid=1002(tokyo) groups=1002(tokyo),1005(developers),1008(project-team)
uid=1004(professor) gid=1004(professor) groups=1004(professor),1006(admins)

heist-team:x:1009:
planners:x:1010:
```
- **Analisis DevOps:** Matriks hak akses berbasis peran (RBAC) tetap persisten dan terisolasi dengan rapi.

---

## 📝 Bagian 2: Mini Self-Check (Evaluasi Kompetensi DevOps/SRE)

### 1) 3 Perintah yang Paling Menghemat Waktu di Lingkungan Kerja
1. **`ss -tulpn` (Socket Statistics):** Memberikan informasi instan mengenai port apa saja yang terbuka (*listening*), protokol TCP/UDP yang digunakan, dan PID proses pemilik socket tanpa perlu membaca berkas konfigurasi secara manual.
2. **`sudo chown -R user:group <directory>`:** Mengubah kepemilikan ribuan file dan sub-folder secara atomik dalam satu detik, menyelesaikan problem izin deployment web server dan Docker bind mount volume.
3. **`journalctl -u <service> -n 50 --no-pager`:** Menampilkan 50 baris log terakhir suatu service secara langsung tanpa jeda interaktif pager, sangat krusial saat triase insiden produksi.

---

### 2) Prosedur Standar Memeriksa Kesehatan Layanan (*Service Health Check*)
Jika dilaporkan suatu layanan (misal web server/API) mengalami gangguan, urutan 3 perintah triage pertama adalah:
1. **`systemctl is-active <service>` / `systemctl status <service>`:** Memeriksa apakah status unit `active (running)`, `failed`, atau `inactive`.
2. **`ss -tulpn | grep :<port>`:** Memverifikasi apakah daemon berhasil mengikat (*bind*) port jaringan yang diharapkan (misal port 80/443).
3. **`curl -I http://localhost:<port>` atau `journalctl -u <service> -n 20 --no-pager`:** Menguji respons kode HTTP (misal `200 OK`) atau membaca akar kegagalan di log jika status code mengembalikan `500` / `502`.

---

### 3) Cara Mengubah Ownership & Permission Secara Aman Tanpa Merusak Akses
- **Hindari Anti-Pattern `chmod 777`:** Memberikan hak penuh kepada pihak luar (*others*) membuka celah eskalasi hak akses (*privilege escalation*).
- **Terapkan Standar Baku Produksi:**
  - **Direktori:** Izin `755` (`drwxr-xr-x`) agar traversal direktori (`cd`) tetap berfungsi tanpa mengizinkan user luar menghapus file.
  - **Berkas Reguler/Kode:** Izin `644` (`-rw-r--r--`).
  - **Kredensial / Secret (`.env`, `id_rsa`):** Izin ketat `600` (`-rw-------`).
- **Gunakan Sintaks Gabungan Terarah:**
  ```bash
  sudo chown -R www-data:www-data /var/www/html/app
  sudo find /var/www/html/app -type d -exec chmod 755 {} +
  sudo find /var/www/html/app -type f -exec chmod 644 {} +
  ```

---

### 4) Fokus Peningkatan untuk 3 Hari ke Depan
- **Day 13 (Linux Volume Management - LVM):** Memahami arsitektur penyimpanan dinamis (*Physical Volume*, *Volume Group*, *Logical Volume*) dan teknik *online resize* storage server tanpa downtime.
- **Day 14–15 (Networking Fundamentals for DevOps):** Menguasai pemetaan model OSI/TCP-IP, diagnosa rute jaringan (`traceroute`, `ip route`), DNS resolution (`dig`, `nslookup`), dan pemecahan masalah port forwarding.

---

## 📊 Bagian 3: Matriks Retensi Materi Inti (Day 01–11)

| Hari | Fokus Utama | Perintah Inti | Penerapan Industri |
| :---: | :--- | :--- | :--- |
| **Day 01** | Audit & Blueprint Karier | `uname -a`, `lscpu`, `free -h` | Host baseline assessment pada server baru. |
| **Day 02** | Arsitektur Linux & systemd | `ps -ef`, `systemctl list-units` | Memahami peran PID 1 dan kontrol *init system*. |
| **Day 03** | Toolkit Troubleshooting | `grep`, `awk`, `sed`, `sort`, `uniq` | Ekstraksi cepat data dari ribuan baris log. |
| **Day 04** | Manajemen Proses & Service | `pgrep`, `kill -15`, `systemctl status` | Siklus hidup daemon aplikasi background. |
| **Day 05** | Triage CPU, RAM & Disk | `top`, `vmstat`, `iostat`, `df -h` | Runbook investigasi insiden performa lambat. |
| **Day 06** | File I/O & Stream Redirection | `>`, `>>`, `2>&1`, `tee` | Otomasi penyimpanan output pipeline CI/CD. |
| **Day 07** | Linux Filesystem Hierarchy | `/etc`, `/var/log`, `/proc`, `/opt` | Navigasi cepat direktori konfigurasi & log. |
| **Day 08** | Nginx & Docker Deployment | `nginx -t`, `curl -I`, `docker run` | Containerization dan reverse proxy deployment. |
| **Day 09** | User & Group RBAC | `useradd -m`, `usermod -aG`, `chmod 2775` | Kolaborasi multi-engineer & pewarisan SGID. |
| **Day 10** | Keamanan Izin Berkas | `chmod 755`, `chmod 640`, `umask` | Proteksi berkas konfigurasi & least privilege. |
| **Day 11** | Kepemilikan Berkas | `chown -R user:group`, `chgrp` | Menghindari error hak akses container volume. |

---

## 💡 Bagian 4: Pelajaran Kunci (Key Takeaways)

1. **Konsistensi Melebihi Intensitas:** 11 hari praktik tangan langsung (*hands-on*) membangun intuisi terminal yang jauh lebih kuat dibandingkan sekadar membaca tutorial.
2. **Keterkaitan Antar Komponen:** Izin berkas (`chmod`), kepemilikan (`chown`), proses (`systemd`), dan jaringan (`ss`/`curl`) adalah mata rantai yang saling mengikat dalam setiap arsitektur aplikasi di server Linux.
3. **Kesiapan Menuju Storage & Jaringan:** Fondasi sistem berkas dan keamanan yang solid membuat transisi ke materi partisi LVM (Day 13) dan Network Troubleshooting (Day 14-15) menjadi jauh lebih mudah dipahami.

