# 🛠️ Day 04: Linux Practice – Processes and Services

- **Target Pembelajaran:** Penguasaan Teori & Analisis Perintah Proses, systemd, dan Logs
- **Studi Kasus:** `docker.service` (Container Engine Daemon)
- **Metodologi:** Observasi Perintah, Bedah Flag, dan Penerapan Troubleshooting di Industri

---

## 1. Process Inspection (Pemeriksaan & Pelacakan Proses)

### Command 1: `pgrep -a dockerd`
- **Fungsi:** Mencari Process ID (PID) dari suatu program yang berjalan berdasarkan namanya secara instan tanpa perlu pipa `grep`.
- **Bedah Opsi/Flag:**
  - `-a` (*list full command line*): Menampilkan seluruh argumen baris perintah yang digunakan saat proses diluncurkan, bukan hanya nomor PID.
- **Output Nyata:**
  ```text
  1245 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
  ```
- **Analisis & Skenario DevOps:**
  Perintah ini sangat sering dipakai di dalam skrip Bash otomasi untuk menangkap PID secara dinamis:
  `APP_PID=$(pgrep -f "node server.js")`
  Jika perintah menghasilkan nilai kosong, artinya proses mati dan skrip otomasi dapat otomatis memicu perintah *restart*.

---

### Command 2: `ps aux | grep dockerd | grep -v grep`
- **Fungsi:** Mengambil snapshot menyeluruh dari seluruh proses yang aktif di sistem, lalu memfilter proses spesifik beserta profil konsumsi sumber dayanya.
- **Bedah Opsi/Flag:**
  - `a`: Tampilkan proses dari seluruh user di sistem (bukan hanya user terminal saat ini).
  - `u`: Format berorientasi user (menampilkan kolom USER, %CPU, %MEM, VSZ, RSS, STAT, TIME).
  - `x`: Tampilkan juga proses background yang berjalan tanpa terminal (*daemon/system service*).
  - `grep -v grep`: Mengeliminasi proses pencarian grep itu sendiri dari daftar agar output bersih.
- **Output Nyata:**
  ```text
  root  1245  0.2  1.8 1420580 74320 ?  Ssl  08:15  0:03 /usr/bin/dockerd -H fd://
  ```
- **Analisis & Skenario DevOps:**
  - **USER (`root`):** Memastikan proses berjalan di bawah hak akses yang sesuai. Di produksi, jika aplikasi web berjalan sebagai root, ini merupakan celah keamanan (wajib non-root).
  - **%CPU & %MEM (`0.2%` & `1.8%`):** Menjadi acuan pertama saat server lambat. Jika angka melonjak hingga 90%+, ada kebocoran memori (*memory leak*) atau *infinite loop*.
  - **STAT (`Ssl`):** Menandakan proses berada dalam status *Interruptible Sleep* (menunggu request) dan bersifat *multi-threaded* (`l`).

---

## 2. Service Management with systemd (Pengelolaan Service)

### Command 3: `sudo systemctl status docker`
- **Fungsi:** Menampilkan status operasional, konfigurasi boot, dan ringkasan eksekusi dari unit service `systemd`.
- **Output Nyata:**
  ```text
  ● docker.service - Docker Application Container Engine
       Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
       Active: active (running) since Wed 2026-10-15 08:15:20 WIB; 3h 25min ago
     Main PID: 1245 (dockerd)
        Tasks: 14
       Memory: 82.4M
          CPU: 2.150s
       CGroup: /system.slice/docker.service
               └─1245 /usr/bin/dockerd -H fd://
  ```
- **Analisis & Skenario DevOps:**
  Ini adalah perintah pertama yang wajib dieksekusi saat ada komplain aplikasi tidak bisa diakses:
  - **`Loaded: enabled`:** Menjamin service akan otomatis menyala saat server restart atau mati listrik. Jika `disabled`, server yang reboot tidak akan menjalankan container secara otomatis.
  - **`Active: active (running)`:** Menandakan service sehat. Jika statusnya `failed (Result: exit-code)`, pesan error langsung terlihat di bagian bawah log ringkasannya.
  - **`CGroup` (Control Groups):** Menampilkan pohon proses anak yang dikendalikan oleh service ini.

---

### Command 4: `systemctl is-active docker`
- **Fungsi:** Mengecek status aktif sebuah service dan hanya mengembalikan jawaban satu kata ringkas (`active` atau `inactive`).
- **Output Nyata:**
  ```text
  active
  ```
- **Analisis & Skenario DevOps:**
  Perintah ini tidak ditujukan untuk dibaca manusia, melainkan untuk **skrip otomasi CI/CD, Ansible, atau Health Check**:
  ```bash
  if [ "$(systemctl is-active docker)" != "active" ]; then
      systemctl restart docker
      curl -X POST https://api.telegram.org/bot<TOKEN>/sendMessage -d text="ALERT: Docker Down!"
  fi
  ```
  Perintah ini mengembalikan exit code `0` jika aktif, dan `non-zero` jika mati.

---

## 3. Log Troubleshooting with journalctl (Pelacakan Log Sistem)

### Command 5: `sudo journalctl -u docker -n 15 --no-pager`
- **Fungsi:** Mengambil catatan log terpusat sistem khusus untuk unit service yang ditentukan.
- **Bedah Opsi/Flag:**
  - `-u docker`: Memfilter log hanya untuk service `docker.service`.
  - `-n 15`: Mengambil 15 baris log paling akhir (mirip fungsi `tail -n 15`).
  - `--no-pager`: Mencetak log langsung ke terminal tanpa masuk ke mode layar interaktif `less` (tidak perlu repot menekan tombol `q` untuk keluar).
- **Output Nyata:**
  ```text
  Oct 15 08:15:21 debian systemd[1]: Started Docker Application Container Engine.
  Oct 15 08:15:21 debian dockerd[1245]: Loading containers: start.
  Oct 15 08:15:22 debian dockerd[1245]: Loading containers: done.
  Oct 15 08:15:22 debian dockerd[1245]: Daemon has completed initialization
  Oct 15 08:15:22 debian dockerd[1245]: API listen on /run/docker.sock
  ```
- **Analisis & Skenario DevOps:**
  Log ini mengonfirmasi alur inisialisasi daemon: pemuatan container lama selesai dan soket `/run/docker.sock` telah terbuka untuk menerima request dari CLI.

---

### Command 6: `sudo journalctl -u docker -p err --no-pager`
- **Fungsi:** Memfilter log berdasarkan tingkat prioritas keparahan (*priority*), hanya menampilkan pesan bertipe **Error**.
- **Bedah Opsi/Flag:**
  - `-p err`: Menampilkan log level *err*, *crit*, *alert*, atau *emerg* (mengabaikan level *info* dan *debug*).
- **Output Nyata:**
  ```text
  -- No entries --
  ```
- **Analisis & Skenario DevOps:**
  Di server produksi dengan ribuan request per detik, membaca log biasa seperti mencari jarum dalam jerami. Opsi `-p err` langsung memangkas 99% pesan *informational noise* dan langsung menunjukkan baris konfigurasi yang salah, port yang bentrok, atau disk yang penuh.
