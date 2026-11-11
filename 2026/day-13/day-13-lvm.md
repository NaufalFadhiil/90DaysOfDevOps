# 💾 Day 13: Linux Volume Management (LVM) Challenge

- **Target Pembelajaran:** Penguasaan Arsitektur Logical Volume Manager (PV, VG, LV), Pembuatan Virtual Block Device via Loopback, dan Ekspansi Filesystem Daring (*Online Resizing* tanpa Downtime).
- **Studi Kasus:** Skalabilitas Storage Dinamis untuk Aplikasi Enterprise (`/mnt/app-data`).
- **Lingkungan Uji:** Debian GNU/Linux 13 (Kernel 6.12.x, x86_64).
- **Standar Industri:** Zero-Downtime Storage Scaling, Online Filesystem Extension, Storage Pool Abstraction, Disaster Prevention.

---

## 🧭 Bagian 1: Arsitektur 3 Lapis LVM (Theory to Practice)

LVM (*Logical Volume Manager*) memisahkan pengelolaan sistem berkas dari disk fisik statis melalui tiga lapisan abstraksi:
1. **Physical Volume (PV):** Disk fisik, partisi, atau loop device yang diinisialisasi agar dapat dibaca oleh LVM.
2. **Volume Group (VG):** Kumpulan satu atau lebih PV yang membentuk satu *pool* kapasitas penyimpanan bersama.
3. **Logical Volume (LV):** Partisi virtual yang dipotong dari VG, memiliki ukuran fleksibel, dan dapat diperbesar atau diperkecil sewaktu-waktu.

```text
[ Virtual Disk (/tmp/disk1.img) ]
                 │
                 ▼
     [ Loop Device (/dev/loop0) ]
                 │
                 ▼
    [ Physical Volume (PV): /dev/loop0 ] (1.00 GiB)
                 │
                 ▼
    [ Volume Group (VG): devops-vg ] (1020.00 MiB)
                 │
                 ▼
  [ Logical Volume (LV): app-data ] (500 MiB ➔ 700 MiB)
                 │
                 ▼
  [ Ext4 Filesystem Mount: /mnt/app-data ]
```

---

## 🛠️ Bagian 2: Eksekusi Hands-on & Bukti Terminal Nyata

### 1. Penyediaan Virtual Disk via Loop Device
Simulasi media penyimpanan fisik 1 GiB menggunakan alokasi byte nol (`/dev/zero`):
```bash
sudo dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
sudo losetup -fP /tmp/disk1.img
sudo losetup -a
```
**Output Nyata Terminal:**
```text
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 0.799101 s, 1.3 GB/s
/dev/loop0: [0042]:978 (/tmp/disk1.img)
```

---

### 2. Inisialisasi Physical Volume (PV)
Mendaftarkan block device `/dev/loop0` ke dalam subsistem LVM:
```bash
sudo pvcreate /dev/loop0
sudo pvs
```
**Output Nyata Terminal:**
```text
  Physical volume "/dev/loop0" successfully created.

  PV         VG Fmt  Attr PSize PFree
  /dev/loop0    lvm2 ---  1.00g 1.00g
```

---

### 3. Pembuatan Volume Group (VG)
Menggabungkan PV ke dalam storage pool bernama `devops-vg`:
```bash
sudo vgcreate devops-vg /dev/loop0
sudo vgs
```
**Output Nyata Terminal:**
```text
  Volume group "devops-vg" successfully created

  VG        #PV #LV #SN Attr   VSize    VFree   
  devops-vg   1   0   0 wz--n- 1020.00m 1020.00m
```

---

### 4. Pembuatan Logical Volume (LV), Pemformatan & Mount
Memotong alokasi 500 MiB untuk LV `app-data`, membuat filesystem Ext4, dan me-mount ke `/mnt/app-data`:
```bash
sudo lvcreate -L 500M -n app-data devops-vg
sudo mkfs.ext4 /dev/devops-vg/app-data
sudo mkdir -p /mnt/app-data
sudo mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```
**Output Nyata Terminal:**
```text
Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data  459M  139K  430M   1% /mnt/app-data
```

---

### 5. Ekspansi Kapasitas Daring (Online Resizing tanpa Downtime)
Menambahkan 200 MiB ke Logical Volume dan mengekspansi filesystem secara langsung saat sistem sedang aktif:
```bash
# 1. Menambah ukuran Logical Volume
sudo lvextend -L +200M /dev/devops-vg/app-data

# 2. Resize filesystem Ext4 pada volume yang sedang di-mount
sudo resize2fs /dev/devops-vg/app-data

# 3. Verifikasi kapasitas baru
df -h /mnt/app-data
```
**Output Nyata Terminal:**
```text
  Size of logical volume devops-vg/app-data changed from 500.00 MiB (125 extents) to 700.00 MiB (175 extents).
  Logical volume devops-vg/app-data successfully resized.

resize2fs 1.47.2 (1-Jan-2025)
Filesystem at /dev/devops-vg/app-data is mounted on /mnt/app-data; on-line resizing required
old_desc_blocks = 4, new_desc_blocks = 6
The filesystem on /dev/devops-vg/app-data is now 716800 (1k) blocks long.

Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data  646M  139K  609M   1% /mnt/app-data
```
> 🚀 **Pencapaian Kritis:** Kapasitas filesystem berhasil meningkat dari **459M** menjadi **646M** secara instan dengan status *on-line resizing required* tanpa perlu `umount` atau menghentikan service aplikasi!

---

## 🏢 Bagian 3: Relevansi Industri bagi DevOps & SRE

1. **Pencegahan Disk Full Incident:**
   Database atau log server yang kehabisan disk space dapat menyebabkan *database crash* atau *data corruption*. Dengan LVM, storage engineer dapat menyuntikkan storage baru atau memperbesar LV secara langsung saat beban kerja puncak.
2. **Pemisahan Logis antar Workload:**
   Memungkinkan pembagian resource disk secara dinamis untuk `/var/log`, `/var/lib/docker`, atau persistent volume container tanpa batasan partisi MBR/GPT fisik yang kaku.
3. **Fleksibilitas Ext4 vs XFS:**
   - Pada **Ext4**: Perluasan ukuran filesystem dilakukan menggunakan `resize2fs <lv_path>`.
   - Pada **XFS**: Perluasan ukuran filesystem dilakukan menggunakan `xfs_growfs <mount_point>`.

---

## 📋 Bagian 4: Ringkasan Perintah Utama (Command Toolkit)

- `sudo losetup -fP <image>` : Menghubungkan berkas citra disk ke loop device kosong berikutnya.
- `sudo pvcreate <device>` : Menginisialisasi perangkat mentah menjadi Physical Volume LVM.
- `sudo vgcreate <vg_name> <pv_path>` : Membuat Volume Group dari satu atau lebih PV.
- `sudo lvcreate -L <size> -n <lv_name> <vg_name>` : Mengalokasikan Logical Volume dengan ukuran tertentu.
- `sudo lvextend -L +<size> <lv_path>` : Memperbesar kapasitas Logical Volume.
- `sudo resize2fs <lv_path>` : Memperluas filesystem Ext4 secara online mengikuti ukuran LV baru.
- `pvs`, `vgs`, `lvs` : Menampilkan ringkasan status PV, VG, dan LV.

---

## 💡 Bagian 5: Pelajaran Kunci (Key Takeaways)

1. **Ekspansi Tanpa Downtime Adalah Nyata:** LVM menghilangkan kebutuhan maintenance window hanya untuk menambah kapasitas disk; kernel Linux mampu me-refresh tabel blok Ext4 secara langsung (*online resizing*).
2. **Dua Langkah Wajib Saat Extend:** Memperbesar Logical Volume (`lvextend`) hanya menambah wadah virtualnya; filesystem di dalamnya tetap harus di-resize (`resize2fs` atau `xfs_growfs`) agar kapasitas tambahan dapat terbaca oleh sistem operasi.
3. **Simulasi Praktis via Loop Device:** Tidak tersedianya hard disk fisik ekstra bukan halangan untuk belajar storage tingkat lanjut; berkas citra disk dengan utilitas `losetup` adalah standar terbaik untuk simulasi lab arsitektur storage.
