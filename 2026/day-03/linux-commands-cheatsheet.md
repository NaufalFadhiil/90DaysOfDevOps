# 🐧 Day 03: Linux Commands with simple explanation

### `Linux Commands for DevOps`

## 1. File System & Navigasi
1. `pwd` – Mengetahui direktori kerja saat ini (Print Working Directory).
2. `ls -la` – Melihat daftar semua file termasuk file tersembunyi (dotfiles) beserta hak akses dan ukurannya.
3. `mkdir -p dir1/dir2` – Membuat direktori bertingkat sekaligus tanpa error.
4. `cp -r sumber/ tujuan/` – Menyalin file atau folder secara rekursif.
5. `mv file.txt /tujuan/` – Memindahkan atau mengganti nama file/folder.
6. `rm -rf /path/folder` – Menghapus file/folder secara paksa dan rekursif (hati-hati dalam menggunakannya!).

## 2. Process & Resource Monitoring (Troubleshooting Server)
1. `ps aux` – Menampilkan snapshot semua proses yang sedang berjalan di sistem.
2. `top` / `htop` – Task manager interaktif real-time untuk memantau penggunaan CPU dan RAM.
3. `kill -9 <PID>` – Menghentikan paksa proses bermasalah berdasarkan nomor PID-nya.
4. `systemctl status <service>` – Memeriksa kondisi apakah service (Nginx/Docker) sedang aktif atau gagal.
5. `systemctl restart <service>` – Merestart service daemon latar belakang.
6. `journalctl -u <service> -n 50 -f` – Memantau 50 baris terakhir log service secara live/streaming.

## 3. Networking & Konektivitas (Paling Sering Ditanyakan Interview)
1. `ip addr show` (atau `ip a`) – Menampilkan antarmuka jaringan dan IP address server.
2. `ping -c 4 google.com` – Menguji apakah server memiliki koneksi internet/mencapai host tujuan.
3. `curl -I https://example.com` – Menginspeksi response header HTTP dari sebuah API atau web service.
4. `ss -tulnp` (atau `netstat -tulnp`) – Menampilkan semua port yang sedang LISTENING dan aplikasi apa yang menggunakannya.
5. `dig example.com` (atau `nslookup`) – Mendiagnosis query DNS dan pemetaan domain ke IP.

## 4. Manipulasi Teks, Pencarian & Log Parsing
1. `cat /etc/os-release` – Menampilkan isi keseluruhan berkas teks ke terminal.
2. `tail -n 100 -f /var/log/syslog` – Memantau baris-baris terbaru dari file log secara dinamis.
3. `grep -rn "ERROR" /var/log/` – Mencari kata kunci "ERROR" secara rekursif di seluruh file dalam direktori.
4. `find /var/www -name "*.conf"` – Mencari file berdasarkan nama atau pola tertentu di hierarki folder.
5. `wc -l access.log` – Menghitung jumlah total baris dalam suatu berkas teks.

## 5. Disk & Info Sistem
1. `df -h` – Menampilkan sisa kapasitas disk storage dalam format yang mudah dibaca (GB/MB).
2. `du -sh *` – Menghitung ukuran penggunaan disk dari masing-masing folder saat ini.
3. `free -m` – Menampilkan kapasitas dan utilisasi memori RAM (total, used, free, available) dalam satuan MB.
