# 📘 BUKU PANDUAN & ROADMAP 90 HARI DEVOPS ENGINEER (PRODUCTION-READY)

> **Pemilik Portofolio:** Naufal Fadhiil  
> **Target:** Junior / Associate DevOps Engineer (Production & Job-Ready)  
> **Metode:** Hands-on Daily Tasks, Proof of Work di GitHub, dan Troubleshooting Riil.

---

## 🧭 Peta Jalan Kurikulum (Roadmap Table)

Kurikulum 90 hari ini dibagi ke dalam 5 fase terstruktur dari fondasi OS hingga orkestrasi cloud skala produksi:

| Fase | Rentang Hari | Fokus Utama | Output & Kompetensi yang Dibangun |
| :--- | :--- | :--- | :--- |
| **Fase 1** | **Day 01 – 21** | Linux, Networking & Bash Scripting | Fondasi OS, manajemen proses/systemd, troubleshotting memori/CPU, otomasi backup & log parsing via Bash. |
| **Fase 2** | **Day 22 – 37** | Git/GitHub & Docker Containerization | Branching strategy industri, Dockerfile best practices, multi-stage build, container networking & volumes. |
| **Fase 3** | **Day 38 – 49** | CI/CD Pipelines & Otomasi | GitHub Actions, Jenkins, automated testing, container security scanning (Trivy), automated deployment. |
| **Fase 4** | **Day 50 – 75** | Cloud (AWS), IaC (Terraform) & Config Mgmt | Arsitektur cloud (EC2, VPC, S3, IAM), Infrastructure as Code (Terraform), server provisioning (Ansible). |
| **Fase 5** | **Day 76 – 90** | Kubernetes, Observability & Capstone Project | K8s Pods, Services, Ingress, Helm, monitoring Prometheus & Grafana, serta final end-to-end production project. |

---

## 🎯 Checklist Harian Pembelajaran (Daily Progress Tracker)

Ganti `[ ]` menjadi `[x]` setiap kali kamu selesai mempraktikkan materi dan melakukan commit ke GitHub.

### 🐧 FASE 1: Linux Fundamentals, Networking & Shell Scripting (Day 01 - 21)

#### Modul 1.1: Fondasi Linux & Manajemen Sistem (Day 01 - 13)
- [x] **Day 01:** Perumusan Rencana Belajar DevOps & Blueprint Karier (`learning-plan.md`)
- [x] **Day 02:** Arsitektur Linux, Siklus Hidup Proses, dan Pengenalan `systemd` (PID 1)
- [x] **Day 03:** Praktik Perintah Dasar & Menengah Linux (Navigasi, Filtering `grep`/`awk`/`sed`)
- [x] **Day 04:** Manajemen Proses & Service (`ps`, `top`, `systemctl start/stop/status`)
- [x] **Day 05:** Troubleshooting Kritis: Analisis Beban CPU, Memori (RAM), Disk I/O, dan System Logs
- [x] **Day 06:** Operasi Berkas Teks & Manipulasi Konfigurasi di Linux (Vim, Nano, Stream Editor)
- [ ] **Day 07:** Hierarki File System Linux (`/etc`, `/var`, `/proc`, `/dev`) & Skenario Kasus Nyata
- [ ] **Day 08:** Cloud Server Setup: Instalasi Nginx, Web Server Hosting, dan Pengujian Port
- [ ] **Day 09:** Manajemen User, Group, dan Hak Akses `sudo` (User & Group Administration)
- [ ] **Day 10:** Keamanan Berkas: Izin File Linux (Permissions `chmod`, Octal vs Symbolic)
- [ ] **Day 11:** Kepemilikan Berkas: Manajemen Owner & Group (`chown`, `chgrp`)
- [ ] **Day 12:** Hari Review, Evaluasi, dan Rangkuman Materi Linux Hari 01–11
- [ ] **Day 13:** Linux Volume Management (LVM): Pembuatan Partition, Physical Volume, Volume Group & Resize

#### Modul 1.2: Jaringan Komputer untuk DevOps (Day 14 - 15)
- [ ] **Day 14:** Fondasi Jaringan: Model OSI, Protokol TCP/UDP, Diagnosa CLI (`netstat`, `ss`, `curl`, `ping`)
- [ ] **Day 15:** Konsep Inti Jaringan: DNS Lookup, Alamat IP Publik/Privat, Subnetting, dan Port Forwarding

#### Modul 1.3: Otomasi dengan Shell/Bash Scripting (Day 16 - 21)
- [ ] **Day 16:** Dasar Skrip Bash: Shebang (`#!/bin/bash`), Variabel, dan Input Parameter
- [ ] **Day 17:** Kontrol Alur: Conditional Logic (`if-else`), Loops (`for`, `while`), dan Error Handling
- [ ] **Day 18:** Konsep Lanjutan Bash: Penggunaan Fungsi (Functions) dan Modular Scripting
- [ ] **Day 19:** Mini Project 1: Skrip Otomasi Backup Data, Log Rotation, dan Penjadwalan Cronjob (`crontab`)
- [ ] **Day 20:** Mini Project 2: Log Analyzer & Security Report Generator (Deteksi Error & Serangan HTTP)
- [ ] **Day 21:** Pembuatan Bash Scripting Cheat Sheet & Rangkuman Otomasi Linux

---

### 🐙 FASE 2: Git, GitHub & Docker Containerization (Day 22 - 37)

#### Modul 2.1: Version Control System Tingkat Lanjut (Day 22 - 28)
- [ ] **Day 22:** Fondasi Git: Konsep Distributed VCS, Git Lifecycle (`working tree`, `stage`, `repository`)
- [ ] **Day 23:** Kolaborasi Git: Branching, Remote Repository, dan Pull Request (PR) Workflow
- [ ] **Day 24:** Operasi Lanjutan: Git Merge vs Rebase, Git Stash, dan Cherry-pick
- [ ] **Day 25:** Disaster Recovery: Git Reset (Soft/Mixed/Hard) vs Git Revert & Conflict Resolution
- [ ] **Day 26:** GitHub CLI (`gh`): Mengelola Repo, Issue, dan PR langsung dari Terminal Linux
- [ ] **Day 27:** Membangun Profil GitHub Profesional & Dokumentasi Portofolio README
- [ ] **Day 28:** Hari Review dan Refleksi: Konsolidasi Skill Linux, Bash & Git (Day 01–27)

#### Modul 2.2: Docker Containerization (Day 29 - 37)
- [ ] **Day 29:** Pengenalan Container: Arsitektur Docker Engine vs Virtual Machine
- [ ] **Day 30:** Siklus Hidup Container: Perintah `run`, `stop`, `exec`, `logs`, dan `rm`
- [ ] **Day 31:** Dockerfile Deep-Dive: Sintaks `FROM`, `RUN`, `COPY`, `ENV`, `EXPOSE`, `CMD` vs `ENTRYPOINT`
- [ ] **Day 32:** Docker Storage & Networking: Named Volume, Bind Mount, dan Docker Bridge Network
- [ ] **Day 33:** Docker Compose: Konfigurasi Multi-Container (App + Database) dengan YAML
- [ ] **Day 34:** Praktik Docker Compose: Studi Kasus Arsitektur Full-Stack (Frontend, Backend, PostgreSQL)
- [ ] **Day 35:** Optimasi Image: Multi-Stage Builds untuk Memperkecil Ukuran Image & Keamanan Non-Root User
- [ ] **Day 36:** Mini Project 3: Dockerize Aplikasi Produksi Mandiri & Push ke Registry (Docker Hub)
- [ ] **Day 37:** Docker Cheat Sheet & Checklist Troubleshooting Container

---

### ⚙️ FASE 3: CI/CD Pipelines & Otomasi Deployment (Day 38 - 49)

- [ ] **Day 38:** Konsep Inti CI/CD: Continuous Integration, Delivery, dan Deployment
- [ ] **Day 39:** Pengenalan GitHub Actions: Workflow, Triggers, Jobs, Runners, dan Steps
- [ ] **Day 40:** Pembuatan Pipeline CI Pertama: Otomasi Linting dan Unit Testing Aplikasi
- [ ] **Day 41:** Manajemen Rahasia (Secrets Management) yang Aman di GitHub Actions
- [ ] **Day 42:** Automated Docker Build & Push Pipeline ke Container Registry
- [ ] **Day 43:** DevSecOps: Integrasi Pemindaian Keamanan Kode (SAST) dan Vulnerability Scan Container (Trivy)
- [ ] **Day 44:** Pengenalan Jenkins: Instalasi Server Jenkins di Linux via Docker
- [ ] **Day 45:** Jenkins Pipeline as Code: Penulisan `Jenkinsfile` (Declarative vs Scripted)
- [ ] **Day 46:** Integrasi Webhook GitHub ke Jenkins untuk Trigger Otomatis
- [ ] **Day 47:** Otomasi Deployment ke Remote Server Linux via SSH Action
- [ ] **Day 48:** Strategi Deployment: Rolling Update, Blue-Green, dan Canary Deployment
- [ ] **Day 49:** Mini Project 4: Full End-to-End CI/CD Pipeline (Commit ➔ Test ➔ Build ➔ Security Scan ➔ Deploy)

---

### ☁️ FASE 4: Cloud (AWS), IaC (Terraform) & Ansible (Day 50 - 75)

#### Modul 4.1: Cloud Computing (AWS Fundamentals) (Day 50 - 62)
- [ ] **Day 50:** Pengenalan Cloud: Model Layanan (IaaS, PaaS, SaaS) & Setup AWS Free Tier / Cloud Console
- [ ] **Day 51:** AWS Identity and Access Management (IAM): Users, Roles, Groups, dan Least-Privilege Policies
- [ ] **Day 52:** AWS EC2: Provisioning Virtual Server Linux, SSH Key Pair, dan Security Groups
- [ ] **Day 53:** Storage Cloud: AWS S3 (Bucket Policy, Versioning, dan Lifecycle Rules)
- [ ] **Day 54:** AWS Networking (VPC): Subnet Publik/Privat, Internet Gateway, dan Route Tables
- [ ] **Day 55:** Elastic Load Balancer (ALB) & Auto Scaling Group untuk Menghadapi Lonjakan Traffic
- [ ] **Day 56:** Database Cloud Terkelola: AWS RDS (PostgreSQL/MySQL) vs Self-Hosted DB
- [ ] **Day 57:** DNS & Domain Routing: Konfigurasi AWS Route 53 dan SSL Certificate (ACM)
- [ ] **Day 58:** Arsitektur Serverless: AWS Lambda dan API Gateway
- [ ] **Day 59:** Mini Project 5: Menjalankan Aplikasi Web Tahan Banting di atas Arsitektur Cloud AWS
- [ ] **Day 60:** AWS CloudWatch: Pembuatan Alarm Utilisasi Server & Notifikasi SNS
- [ ] **Day 61:** Keamanan Cloud: AWS WAF, Security Best Practices, dan Cost Optimization
- [ ] **Day 62:** Hari Evaluasi & Rangkuman Praktik Cloud AWS

#### Modul 4.2: Infrastructure as Code (Terraform) (Day 63 - 69)
- [ ] **Day 63:** Pengenalan IaC: Mengapa Terraform? Deklaratif vs Imperatif
- [ ] **Day 64:** Dasar Terraform: Providers, Resources, Variables, dan Output
- [ ] **Day 65:** Manajemen State: `terraform.tfstate`, State Locking dengan S3 & DynamoDB
- [ ] **Day 66:** Terraform Execution Lifecycle: `init`, `plan`, `apply`, dan `destroy`
- [ ] **Day 67:** Modularisasi: Membuat Reusable Terraform Modules untuk Berbagai Environment (Staging/Prod)
- [ ] **Day 68:** Mini Project 6: Provisioning Lengkap Infrastruktur Cloud (VPC + EC2 + S3) via Terraform
- [ ] **Day 69:** Terraform Best Practices & Keamanan State File

#### Modul 4.3: Configuration Management (Ansible) (Day 70 - 75)
- [ ] **Day 70:** Pengenalan Ansible: Arsitektur Agentless via SSH
- [ ] **Day 71:** Inventory Files & Pengujian Ad-Hoc Commands ke Banyak Server Sekaligus
- [ ] **Day 72:** Menulis Ansible Playbooks menggunakan YAML
- [ ] **Day 73:** Ansible Handlers, Variables, dan Templates (Jinja2)
- [ ] **Day 74:** Ansible Roles: Menata Skrip Konfigurasi Server Skala Perusahaan
- [ ] **Day 75:** Mini Project 7: Otomasi Setup Server Linux Baru (Hardening SSH, Install Docker, Nginx) dengan 1 Perintah

---

### 🚢 FASE 5: Kubernetes, Observability & Capstone Project (Day 76 - 90)

#### Modul 5.1: Container Orchestration (Kubernetes) (Day 76 - 82)
- [ ] **Day 76:** Pengenalan Kubernetes (K8s): Arsitektur Control Plane (API Server, etcd) & Worker Node (Kubelet)
- [ ] **Day 77:** Setup Lingkungan Lokal: Minikube / K3s dan Interaksi via `kubectl`
- [ ] **Day 78:** K8s Workloads: Pods, ReplicaSet, dan Deployment (Scaling & Self-Healing)
- [ ] **Day 79:** K8s Networking: ClusterIP, NodePort, LoadBalancer, dan Ingress Controller
- [ ] **Day 80:** Manajemen Konfigurasi: ConfigMaps dan Secrets
- [ ] **Day 81:** K8s Persistent Storage: Persistent Volumes (PV) dan Persistent Volume Claims (PVC)
- [ ] **Day 82:** Package Manager K8s: Pengenalan Helm Charts dan Deployment Aplikasi Terpaket

#### Modul 5.2: Monitoring, Logging & Observability (Day 83 - 86)
- [ ] **Day 83:** Tiga Pilar Observabilitas: Metrics, Logs, dan Traces
- [ ] **Day 84:** Setup Prometheus: Mengumpulkan Metrik Server & Container Menggunakan Exporter
- [ ] **Day 85:** Setup Grafana: Membuat Visualisasi Dashboard Monitoring CPU, RAM, Disk, dan Request HTTP
- [ ] **Day 86:** Alertmanager: Konfigurasi Notifikasi Otomatis ke Telegram/Discord/Slack Saat Server Down

#### Modul 5.3: Final Capstone Project & Kesiapan Kerja (Day 87 - 90)
- [ ] **Day 87:** Capstone Project Bagian 1: Perancangan Arsitektur Sistem, Infrastruktur via Terraform
- [ ] **Day 88:** Capstone Project Bagian 2: Pipeline CI/CD Otomatis, Testing, dan Containerization
- [ ] **Day 89:** Capstone Project Bagian 3: Deployment ke Cluster Kubernetes + Monitoring Prometheus/Grafana
- [ ] **Day 90:** Grand Finale: Dokumentasi Lengkap Proyek, Pembuatan Video Demo, dan Rangkuman Portofolio LinkedIn/GitHub!

---

## 💡 3 Kaidah Emas Belajar:
1. **Jangan Lewatkan 1 Hari Pun Tanpa Mengetik Sendiri:** Jangan hanya membaca atau menonton video; selalu jalankan dan uji setiap baris perintah di terminal.
2. **Dokumentasikan Error:** Ketika menemui error, catat pesan error-nya dan cara penyelesaiannya. Kemampuan memecahkan error adalah nilai utama seorang DevOps Engineer.
3. **Commit & Push Tiap Selesai 1 Hari:** Pastikan riwayat kontribusi GitHub-mu berwarna hijau dan mencerminkan dedikasi belajar yang konsisten!
