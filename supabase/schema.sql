-- =====================================================================
-- SKEMA DATABASE SUPABASE — LMS PESANTREN MAHASISWA AR ROYYAN
-- =====================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUM TYPES
CREATE TYPE user_role AS ENUM ('santri', 'ustadz', 'admin');
CREATE TYPE attendance_status AS ENUM ('hadir', 'izin', 'sakit', 'alpa');
CREATE TYPE payment_status AS ENUM ('belum_bayar', 'menunggu_verifikasi', 'lunas', 'ditolak');
CREATE TYPE exam_status AS ENUM ('draft', 'berlangsung', 'selesai');

-- 3. PROFILES TABLE (Linked with Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nis_nip VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role user_role DEFAULT 'santri'::user_role NOT NULL,
    avatar_url TEXT,
    phone VARCHAR(20),
    angkatan VARCHAR(10),
    kamar VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. DIROSAH COURSES / KITAB
CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(150) NOT NULL,
    kitab_name VARCHAR(150),
    ustadz_id UUID REFERENCES public.profiles(id),
    hari VARCHAR(20) NOT NULL,
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    ruangan VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ATTENDANCE RECORDS
CREATE TABLE public.attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    santri_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    tanggal DATE DEFAULT CURRENT_DATE NOT NULL,
    status attendance_status DEFAULT 'hadir'::attendance_status NOT NULL,
    keterangan TEXT,
    file_bukti_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(course_id, santri_id, tanggal)
);

-- 6. PAYMENTS (SYAHRIYAH / IURAN)
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    bulan_tahun VARCHAR(20) NOT NULL, -- e.g. "Agustus 2026"
    nominal NUMERIC(12, 2) NOT NULL,
    status payment_status DEFAULT 'belum_bayar'::payment_status NOT NULL,
    bukti_transfer_url TEXT,
    tanggal_upload TIMESTAMPTZ,
    tanggal_verifikasi TIMESTAMPTZ,
    verified_by UUID REFERENCES public.profiles(id),
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. EXAMS (CBT)
CREATE TABLE public.exams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(150) NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 60,
    waktu_mulai TIMESTAMPTZ NOT NULL,
    waktu_selesai TIMESTAMPTZ NOT NULL,
    passing_grade INT DEFAULT 70,
    questions JSONB NOT NULL DEFAULT '[]'::jsonb, -- Store list of questions
    status exam_status DEFAULT 'draft'::exam_status NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. EXAM SUBMISSIONS (CBT)
CREATE TABLE public.exam_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    exam_id UUID REFERENCES public.exams(id) ON DELETE CASCADE NOT NULL,
    santri_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    answers JSONB DEFAULT '{}'::jsonb,
    score NUMERIC(5, 2),
    is_passed BOOLEAN DEFAULT FALSE,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(exam_id, santri_id)
);

-- 9. LEARNING MATERIALS (FILE & AUDIO)
CREATE TABLE public.materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    file_type VARCHAR(20) NOT NULL, -- 'pdf', 'audio', 'video', 'link'
    file_url TEXT NOT NULL,
    uploaded_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.materials ENABLE ROW LEVEL SECURITY;

-- Allow users to read all profiles & courses
CREATE POLICY "Public Profiles Read" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Public Courses Read" ON public.courses FOR SELECT USING (true);

-- Attendance policies
CREATE POLICY "Santri View Own Attendance" ON public.attendance FOR SELECT USING (auth.uid() = santri_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('ustadz', 'admin')));
CREATE POLICY "Santri Insert Own Attendance" ON public.attendance FOR INSERT WITH CHECK (auth.uid() = santri_id);

-- Payment policies
CREATE POLICY "Santri View Own Payments" ON public.payments FOR SELECT USING (auth.uid() = santri_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Santri Insert Own Payments" ON public.payments FOR INSERT WITH CHECK (auth.uid() = santri_id);
CREATE POLICY "Admin Update Payments" ON public.payments FOR UPDATE USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- Materials policies
CREATE POLICY "All View Materials" ON public.materials FOR SELECT USING (true);

-- Seed Initial Admin/Ustadz/Santri Data for Testing
-- (Dapat diaktifkan langsung di Supabase SQL Editor)
