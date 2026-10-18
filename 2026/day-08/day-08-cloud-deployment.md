# 🌐 Day 08: Cloud Server Setup – Nginx & Docker Web Deployment

- **Target Pembelajaran:** Penguasaan Web Server Deployment, Analisis Log Akses, dan Migrasi ke Container Docker
- **Studi Kasus:** Web Server Infrastructure (`nginx.service` & `nginx:alpine` Container)
- **Lingkungan Uji:** Debian GNU/Linux 13 (Kernel 6.12.x, x86_64)
- **Standar Industri:** Port Binding, Isolation, Log Auditing, Containerized Architecture

---

## 🧭 Bagian 1: Native Web Server Deployment (Nginx on Host OS)

Pada tahap awal, web server dideploy secara langsung (*bare-metal*) di sistem operasi host menggunakan package manager Linux.

### Command 1: `sudo systemctl status nginx`
- **Fungsi:** Memeriksa status kesehatan unit service Nginx, proses master, dan alokasi worker process.
- **Output Nyata:**
  ```text
  ● nginx.service - A high performance web server and a reverse proxy server
       Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
       Active: active (running) since Sun 2026-10-18 11:37:27 WIB; 14s ago
     Main PID: 5303 (nginx)
        Tasks: 17 (limit: 28195)
       Memory: 10.8M (peak: 27.7M)
          CPU: 120ms
       CGroup: /system.slice/nginx.service
               ├─5303 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
               ├─5305 "nginx: worker process"
               ├─5306 "nginx: worker process"
               ...
               └─5320 "nginx: worker process"
  ```
- **Analisis & Skenario DevOps:**
  - **Master vs Worker Architecture:** Nginx menggunakan 1 *Master Process* (PID `5303`) yang bertugas membaca konfigurasi dan mengikat port, serta melahirkan 16 *Worker Processes* (PID `5305` - `5320`).
  - **CPU Auto-Tuning:** Jumlah worker process yang tercipta otomatis menyesuaikan dengan 16 CPU threads Intel Core i5 pada host Linux. Ini memaksimalkan kemampuan *concurrency* untuk menangani ribuan request secara non-blocking (*event-driven*).

---

### Command 2: `ss -tulpn | grep :80`
- **Fungsi:** Menginspeksi socket jaringan untuk memastikan port 80 (HTTP) berstatus `LISTEN` dan siap menerima koneksi.
- **Output Nyata:**
  ```text
  tcp   LISTEN 0      511         0.0.0.0:80         0.0.0.0:*
  tcp   LISTEN 0      511            [::]:80            [::]:*
  ```
- **Analisis & Skenario DevOps:**
  - `0.0.0.0:80` menunjukkan port terbuka di seluruh antarmuka IPv4, dan `[::]:80` untuk IPv6.
  - Nilai `511` merupakan ukuran *backlog queue* (antrean koneksi TCP yang belum di-accept oleh worker).

---

### Command 3: `curl -I http://localhost`
- **Fungsi:** Mengirim HTTP request tipe `HEAD` untuk menguji respon status code dan metadata header web server tanpa mengunduh konten body.
- **Output Nyata:**
  ```text
  HTTP/1.1 200 OK
  Server: nginx
  Date: Sun, 18 Oct 2026 05:04:06 GMT
  Content-Type: text/html
  Content-Length: 615
  Connection: keep-alive
  ```
- **Analisis & Skenario DevOps:**
  - Kode status `200 OK` memvalidasi bahwa web server sehat dan berhasil menyajikan file HTML default dari `/var/www/html/index.nginx-debian.html`.
  - Header `Server: nginx` membuktikan request dijawab langsung oleh Nginx host.

---

### Command 4: `sudo tail -n 20 /var/log/nginx/access.log | tee nginx-logs.txt`
- **Fungsi:** Mengekstrak catatan riwayat akses trafik dari pengguna dan menyimpannya ke berkas arsip `nginx-logs.txt`.
- **Output Nyata:**
  ```text
  ::1 - - [18/Oct/2026:12:04:06 +0700] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1"
  ::1 - - [18/Oct/2026:12:05:27 +0700] "GET / HTTP/1.1" 200 615 "-" "curl/8.14.1"
  ::1 - - [18/Oct/2026:12:05:38 +0700] "GET / HTTP/1.1" 200 615 "-" "curl/8.14.1"
  ::1 - - [18/Oct/2026:12:05:43 +0700] "GET /test-halaman-devops HTTP/1.1" 404 146 "-" "curl/8.14.1"
  ::1 - - [18/Oct/2026:12:05:52 +0700] "GET /api/health HTTP/1.1" 404 146 "-" "curl/8.14.1"
  ```
- **Bedah Format Log Standar (Combined Log Format):**
  1. `::1`: Alamat IP klien (IPv6 Loopback / Localhost).
  2. `[18/Oct/2026:12:05:43 +0700]`: Stempel waktu (Timestamp) request masuk.
  3. `"GET /test-halaman-devops HTTP/1.1"`: Method HTTP, URI target, dan versi protokol.
  4. `404`: HTTP Status Code (`200` = Sukses, `404` = Endpoint tidak ditemukan).
  5. `146`: Ukuran respons body dalam satuan byte.
  6. `"curl/8.14.1"`: Identitas User-Agent yang melakukan request.

---

## 🐳 Bagian 2: Containerized Web Deployment (Docker Nginx)

Untuk menghindari benturan dependensi pada sistem operasi host dan mempermudah replikasi server, aplikasi web dimodernisasi dengan kontainerisasi Docker.

### 1. File Konfigurasi Landing Page (`index.html`)
Dibuat halaman khusus dengan penanda lingkungan dan metadata charset UTF-8:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>DevOps Day 08 - Naufal Fadhiil</title>
    <style>
        body { font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #0f172a; color: #f8fafc; }
        h1 { color: #38bdf8; }
        .box { background-color: #1e293b; display: inline-block; padding: 25px 40px; border-radius: 12px; border: 1px solid #334155; }
    </style>
</head>
<body>
    <div class="box">
        <h1>🚀 DevOps Server Deployment - Day 08</h1>
        <p>Aplikasi web berhasil di-deploy menggunakan <strong>Docker Containerized Nginx</strong>.</p>
        <p>Host: Debian GNU/Linux 13 | Engineer: Naufal Fadhiil</p>
    </div>
</body>
</html>
```

---

### 2. Eksekusi Deployment Container

#### Command 5: `docker run -d --name web-html -p 8080:80 -v $(pwd)/index.html:/usr/share/nginx/html/index.html:ro nginx:alpine`
- **Fungsi:** Meluncurkan container Nginx berbasis Alpine Linux secara terisolasi.
- **Bedah Opsi/Flag:**
  - `-d` (*detached*): Menjalankan container di latar belakang (*background*).
  - `--name web-html`: Memberikan identitas container agar mudah dikelola tanpa mengingat Container ID.
  - `-p 8080:80`: Meneruskan trafik dari port `8080` (Host OS) ke port `80` (Internal Container).
  - `-v $(pwd)/index.html:...:ro`: Melakukan *bind mount* berkas HTML lokal ke direktori web root Nginx dalam mode *Read-Only* (`:ro`) demi keamanan data.
  - `nginx:alpine`: Menggunakan image minimalis berbasis Alpine (~40MB) untuk efisiensi resource dan memangkas celah keamanan (*vulnerability footprint*).

---

### 3. Telemetri & Observabilitas Container

#### Command 6: `docker logs web-html`
- **Fungsi:** Mengambil stream log `stdout`/`stderr` langsung dari dalam container Nginx.
- **Output Nyata:**
  ```text
  /docker-entrypoint.sh: Configuration complete; ready for start up
  2026/10/18 05:11:33 [notice] 1#1: using the "epoll" event method
  2026/10/18 05:11:33 [notice] 1#1: OS: Linux 6.12.107+deb13-amd64
  2026/10/18 05:11:33 [notice] 1#1: start worker process 30
  ...
  172.17.0.1 - - [18/Oct/2026:05:22:33 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
  ```
- **Analisis & Skenario DevOps:**
  - **Docker Bridge Gateway (`172.17.0.1`):** Nginx container mencatat alamat IP sumber request adalah `172.17.0.1`, bukan `127.0.0.1`. Ini adalah IP gateway dari antarmuka virtual bridge `docker0`. Trafik dari host dialihkan menggunakan aturan *iptables/NAT (Network Address Translation)*.
  - **Linux Epoll Engine:** Nginx di dalam container menggunakan subsistem I/O event `epoll` bawaan kernel Linux host untuk skalabilitas konkurensi tinggi.

---

## 📊 Bagian 3: Matriks Perbandingan Arsitektur

| Parameter Evaluasi | Native Nginx (Host OS) | Containerized Nginx (Docker) |
| :--- | :--- | :--- |
| **Port Listening** | Port `80` (Standard HTTP) | Port `8080` (Host) dipetakan ke Port `80` (Container) |
| **Lokasi Log** | File statis di host: `/var/log/nginx/access.log` | Stream terpusat: `docker logs` (`stdout`/`stderr`) |
| **Isolasi Lingkungan** | Terikat dengan pustaka distro Debian host | Terisolasi penuh dalam filesystem Alpine Linux |
| **Pembaruan Web** | Salin manual ke `/var/www/html/` | *Bind mount volume* (`-v`) atau rebuild image |
| **Portabilitas** | Memerlukan instalasi ulang per server | Dapat dijalankan identik di AWS, GCP, maupun lokal |

---

## 💡 Bagian 4: Ringkasan & Pelajaran Kunci (Key Takeaways)

1. **Pemahaman Lifecycle Web Server:** Mengetahui cara Nginx membagi kerja antara *Master Process* dan *Worker Process* berdasarkan jumlah core CPU host.
2. **Keterampilan Log Auditing:** Mampu membaca pola log akses HTTP, mendeteksi status code sukses (`200 OK`) dan error (`404 Not Found`), serta mengidentifikasi User-Agent untuk pelacakan trafik.
3. **Praktek Terbaik Containerization:** Mempelajari teknik *port mapping* dan *volume binding* read-only (`:ro`) untuk menyajikan konten dinamis tanpa mengorbankan keamanan container.
