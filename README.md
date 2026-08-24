# 📚 LMS Pesantren Mahasiswa Ar Royyan

Aplikasi Sistem Informasi & Learning Management System (LMS) berbasis Web SPA Mobile-First untuk **Pesantren Mahasiswa Ar Royyan**.

---

## 🌟 Fitur Utama
1. **Multi-Role Switcher (Santri, Ustadz, Admin/Pengasuh)**:
   - **Santri**: Beranda Jadwal Dirosah, Presensi Mandiri/QR, Ujian CBT Interaktif, Upload Syahriyah, Kitab & Audio Dirosah, Rekap Nilai KHS & KRS.
   - **Ustadz**: Pengampu Dirosah, Upload Kitab/Materi, Rekap Presensi Santri.
   - **Admin / Pengasuh**: Dashboard Verifikasi Pembayaran Syahriyah (Approve/Reject), Kelola Santri, Pengumuman.

2. **Computer Based Test (CBT) Simulator**:
   - Fitur ujian online interaktif dengan timer hitung mundur, navigasi soal, pilihan ganda, dan hitung skor/kelulusan otomatis (*Mumtaz* / *Lulus*).

3. **Manajemen Presensi & Keuangan (Syahriyah)**:
   - Modul presensi mandiri dengan status (Hadir, Izin, Sakit, Alpa).
   - Form upload struk transfer pembayaran syahriyah dengan simulasi approval admin real-time.

4. **Integrasi Supabase (Dual Mode: Demo Mode & Live DB)**:
   - Aplikasi berjalan langsung tanpa hambatan dalam **Demo Mode**.
   - Dilengkapi skema database SQL produksi di [`supabase/schema.sql`](supabase/schema.sql) untuk integrasi Supabase RLS & Auth.

---

## 🛠️ Tech Stack
- **Frontend**: HTML5, Tailwind CSS v3, Lucide Icons, Vanilla JavaScript Engine.
- **Backend / Database**: Supabase (PostgreSQL, Row Level Security, Auth).
- **Deployment**: Vercel & GitHub (`fariqsalafy/lms-ar-royyan`).

---

## 🚀 Live Demo
🔗 **[https://lms-ar-royyan.vercel.app](https://lms-ar-royyan.vercel.app)**
