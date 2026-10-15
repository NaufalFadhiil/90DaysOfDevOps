# 🚨 Day 05: Linux Troubleshooting Drill – SRE Runbook

- **Judul Dokumen:** Standard Operating Procedure (SOP) & Troubleshooting Runbook
- **Target Layanan:** `docker.service` (Container Infrastructure Engine)
- **Lingkungan Uji:** Linux Debian (Kernel 6.x, x86_64)
- **Standar Operasional:** Observasi Metrik, Deteksi Dini Anomali, dan Matriks Mitigasi

---

## 📖 Apa itu Runbook?
**Runbook** adalah panduan teknis langkah-demi-langkah yang digunakan oleh SRE (*Site Reliability Engineer*) dan DevOps Engineer saat terjadi insiden di server produksi. Tujuannya adalah mempercepat waktu pemulihan sistem (*Mean Time to Recovery* / MTTR) melalui urutan diagnostik terstandar tanpa spekulasi.

---

## 🛠️ Bagian 1: Urutan Diagnostik & Pengujian Kesehatan Sistem (Health Check Routine)

### 1. Environment Basics (Pengecekan Identitas Lingkungan)

#### Command 1: `uname -a`
- **Tujuan:** Mengetahui nama kernel, hostname, versi rilis, dan arsitektur CPU host.
- **Output:**
  ```text
  Linux debian-srv 6.1.0-21-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.90-1 (2024-05-03) x86_64 GNU/Linux
  ```
- **Analisis DevOps:**
  Arsitektur adalah `x86_64`. Hal ini krusial saat menarik image Docker agar tidak terjadi error arsitektur (misalnya image berbasis `arm64/v8` dijalankan di atas kernel `amd64`).

#### Command 2: `cat /etc/os-release`
- **Tujuan:** Mengidentifikasi distribusi Linux dan nomor rilisnya.
- **Output:**
  ```text
  PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
  NAME="Debian GNU/Linux"
  VERSION_ID="12"
  VERSION="12 (bookworm)"
  ID=debian
  ```
- **Analisis DevOps:**
  Sistem menggunakan Debian 12 (Bookworm). Perintah paket manajer menggunakan `apt`, dan path konfigurasi service berada di bawah `/etc/systemd/system/` atau `/lib/systemd/system/`.

---

### 2. Filesystem Sanity (Uji Integritas & Izin Tulis File System)

#### Command 3: `mkdir -p /tmp/runbook-check && touch /tmp/runbook-check/write-test.tmp`
- **Tujuan:** Memvalidasi bahwa partisi storage dalam status *Read-Write* dan dapat menerima pembuatan file baru.
- **Output:**
  *(Exit code 0, tidak ada error)*

#### Command 4: `ls -ld /tmp/runbook-check && rm -rf /tmp/runbook-check`
- **Tujuan:** Memastikan permission direktori sementara benar dan file uji coba langsung dibersihkan.
- **Output:**
  ```text
  drwxr-xr-x 2 root root 4096 Oct 15 12:10 /tmp/runbook-check
  ```
- **Analisis DevOps:**
  Jika Linux mendeteksi kerusakan pada hard disk atau bad sector, kernel secara otomatis mengunci filesystem menjadi **Read-Only**. Uji tulis ke `/tmp` ini membuktikan storage berfungsi normal dan tidak terkunci.

---

### 3. CPU & Memory Profiling (Analisis Kapasitas Komputasi)

#### Command 5: `free -h`
- **Tujuan:** Menginspeksi ketersediaan memori fisik (RAM) dan penggunaan Swap.
- **Output:**
  ```text
                 total        used        free      shared  buff/cache   available
  Mem:           7.7Gi       1.8Gi       3.2Gi       120Mi       2.7Gi       5.6Gi
  Swap:          2.0Gi          0B       2.0Gi
  ```
- **Analisis DevOps:**
  - **Available Memori: `5.6Gi` (Sehat):** Angka acuan utama adalah kolom `available`, bukan `free`. Memori cadangan masih sangat memadai.
  - **Swap Used: `0B`:** Menandakan sistem tidak kekurangan RAM fisik. Jika swap mulai digunakan secara intensif, performa server akan turun drastis karena latensi disk.

#### Command 6: `ps -o pid,user,%cpu,%mem,comm -p $(pgrep -d, -x dockerd)`
- **Tujuan:** Mengisolasi dan memeriksa profil konsumsi resource proses `dockerd`.
- **Output:**
  ```text
    PID USER     %CPU %MEM COMMAND
   1245 root      0.2  1.8 dockerd
  ```
- **Analisis DevOps:**
  Daemon Docker berjalan efisien dengan konsumsi CPU `0.2%` dan RAM `1.8%`. Tidak ada indikasi *CPU spike* maupun *memory leak*.

---

### 4. Disk & Storage I/O (Pemeriksaan Ruang Penyimpanan)

#### Command 7: `df -h /`
- **Tujuan:** Memeriksa kapasitas ruang penyimpanan pada partisi sistem utama (root).
- **Output:**
  ```text
  Filesystem      Size  Used Avail Use% Mounted on
  /dev/sda1        40G   14G   24G  37% /
  ```
- **Analisis DevOps:**
  Kapasitas disk terpakai baru `37%` dengan sisa `24G`. Jika `Use%` mencapai 90%+, sistem berisiko mengalami *crash* saat Docker mencoba mengunduh image baru atau menulis snapshot container.

#### Command 8: `du -sh /var/log`
- **Tujuan:** Mengetahui total ukuran direktori log sistem.
- **Output:**
  ```text
  485M    /var/log
  ```
- **Analisis DevOps:**
  Ukuran `485MB` tergolong normal untuk server yang aktif. Jika folder log mencapai belasan Gigabyte, rotasi log (`logrotate`) wajib dikonfigurasi ulang atau log lama harus dipangkas (`journalctl --vacuum-size=200M`).

---

### 5. Network & Port Connectivity (Pemeriksaan Jaringan & Port)

#### Command 9: `ss -tulpn | grep -E ':(22|80|443|2375)'`
- **Tujuan:** Memverifikasi port-port penting (SSH, HTTP, HTTPS, Docker Daemon) yang sedang aktif mendengarkan koneksi (*LISTEN*).
- **Output:**
  ```text
  tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=680,fd=3))
  tcp   LISTEN 0      4096       127.0.0.1:2375      0.0.0.0:*    users:(("dockerd",pid=1245,fd=4))
  ```
- **Analisis DevOps:**
  Port SSH (`22`) aktif untuk remote akses. Docker API (`2375`) terikat aman pada IP lokal `127.0.0.1` (loopback), mencegah akses terbuka yang tidak aman dari jaringan publik internet.

#### Command 10: `curl -I --connect-timeout 5 https://google.com`
- **Tujuan:** Menguji konektivitas keluar (*egress connectivity*) dan resolusi DNS dari server.
- **Output:**
  ```text
  HTTP/2 200 
  date: Wed, 15 Oct 2026 12:12:05 GMT
  content-type: text/html; charset=ISO-8859-1
  ```
- **Analisis DevOps:**
  Server memiliki koneksi internet keluar yang lancar (HTTP 200) dengan waktu respons di bawah 5 detik. Server siap melakukan `docker pull` dari registry publik.

---

### 6. Logs & Error Tracing (Pelacakan Log Terfokus)

#### Command 11: `sudo journalctl -u docker.service --since "1 hour ago" -p err --no-pager`
- **Tujuan:** Memeriksa apakah ada pesan error fatal pada daemon Docker dalam 1 jam terakhir.
- **Output:**
  ```text
  -- No entries --
  ```
- **Analisis DevOps:**
  Tidak ditemukan log error dalam satu jam ke belakang. Status sistem stabil.

---

## 🚨 Bagian 2: Matriks Eskalasi & Tindakan Mitigasi (Next Actions Matrix)

Jika saat pengecekan di atas ditemukan kondisi abnormal, ikuti panduan mitigasi berikut:

| Kondisi Masalah | Indikator Gejala | Tindakan Pertama (Immediate Action) | Tindakan Lanjutan (Next Escalation) |
| :--- | :--- | :--- | :--- |
| **Disk Penuh (100% Full)** | `df -h` menunjukkan `Use% 100%`, Docker gagal start container baru. | Hapus image/container yatim: `docker system prune -af --volumes`. | Pangkas log sistem: `journalctl --vacuum-size=200M` dan cari file besar via `du -ahx / | sort -rh | head -n 10`. |
| **RAM Habis / OOM Kills** | `free -h` available < 50MB, Swap melonjak tajam. | Cari proses rakus: `ps aux --sort=-%mem | head -n 10`. | Restart service yang memicu leak: `systemctl restart <service>` atau batasi memori container di Docker Compose (`mem_limit`). |
| **Service Gagal / Crash** | `systemctl status` berwarna merah (`failed`). | Cek 50 baris log error: `journalctl -u docker.service -n 50 --no-pager`. | Validasi file konfigurasi (`/etc/docker/daemon.json`) dari typo sintaks JSON, lalu restart via `systemctl daemon-reload && systemctl restart docker`. |
| **Jaringan Terputus** | `curl` timeout, DNS lookup gagal. | Cek konfigurasi DNS di `/etc/resolv.conf` dan status interface via `ip a`. | Uji ping gateway lokal: `ping -c 3 <IP_GATEWAY>` dan periksa aturan firewall `iptables -L -n -v` atau `ufw status`. |
