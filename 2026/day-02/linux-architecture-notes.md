# 🐧 Day 02: Linux Architecture, Processes, and systemd Notes

## 1. Komponen Inti Linux
- **Hardware:** Sumber daya fisik (CPU, Memori/RAM, Storage, Kartu Jaringan).
- **Kernel:** Inti OS yang mengontrol hardware, alokasi memori, scheduling CPU, dan keamanan perangkat.
- **Shell:** Antarmuka CLI (seperti Bash) tempat user memasukkan perintah untuk diteruskan ke Kernel.
- **User Space:** Area terisolasi tempat aplikasi pengguna (Web Server, Database, Docker container) berjalan.

## 2. Pemahaman Proses & Statusnya
Setiap program yang berjalan di Linux memiliki identitas unik bernama **PID** (Process ID) dan diciptakan oleh proses induknya (**PPID**).

### Status Proses (Process States):
1. **Running (R):** Proses sedang aktif menggunakan CPU atau berada di antrian eksekusi.
2. **Sleeping (S / D):** Proses menunggu event luar (I/O, database response, atau timer sleep).
3. **Stopped (T):** Proses di-pause secara manual (misal sinyal `SIGSTOP` atau `Ctrl+Z`).
4. **Zombie (Z):** Proses yang sudah selesai dieksekusi tetapi parent process belum membaca status baliknya, sehingga masih terdaftar di tabel proses.

## 3. Apa itu `systemd` dan Mengapa Penting?
`systemd` adalah *init system* modern pada Linux yang berjalan sebagai **PID 1**. 
Fungsi utamanya:
- Mengatur proses *booting* sistem operasi secara paralel dan cepat.
- Mengelola *daemon/service* latar belakang (start, stop, restart, enable on boot).
- Memantau log sistem terpusat melalui `journalctl`.

## 4. 5 Perintah Harian DevOps untuk Manajemen Proses
1. `ps aux`: Menampilkan seluruh proses yang berjalan di sistem beserta user, PID, %CPU, dan %RAM.
2. `top` / `htop`: Monitoring real-time utilisasi prosesor dan memori secara interaktif.
3. `sudo systemctl status <nama-service>`: Memeriksa status kesehatan service (aktif/gagal/inactive).
4. `sudo journalctl -u <nama-service> -f`: Melihat log real-time dari service tertentu untuk investigasi error.
5. `kill -9 <PID>`: Mengirim sinyal `SIGKILL` untuk mematikan paksa proses yang hang atau *unresponsive*.
