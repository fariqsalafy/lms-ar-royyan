create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  role text not null check (role in ('admin','ustadz','santri','wali')),
  full_name text not null,
  phone text,
  nis text unique,
  kelas_id uuid,
  avatar_url text,
  created_at timestamptz default now()
);

create table if not exists kelas (
  id uuid primary key default gen_random_uuid(),
  nama text not null,
  tingkat text,
  wali_kelas_id uuid references profiles(id),
  created_at timestamptz default now()
);

create table if not exists mata_pelajaran (
  id uuid primary key default gen_random_uuid(),
  kode text not null unique,
  nama text not null,
  semester text not null,
  sks int default 2,
  ustadz_id uuid references profiles(id),
  kelas_id uuid references kelas(id),
  created_at timestamptz default now()
);

create table if not exists presensi (
  id uuid primary key default gen_random_uuid(),
  santri_id uuid references profiles(id),
  mata_pelajaran_id uuid references mata_pelajaran(id),
  tanggal date not null default now(),
  jam_masuk time,
  status text not null check (status in ('hadir','izin','sakit','alpa')),
  keterangan text,
  offline_id text,
  created_at timestamptz default now(),
  unique (santri_id, mata_pelajaran_id, tanggal)
);

create index on presensi (santri_id, tanggal desc);
create index on presensi (mata_pelajaran_id, tanggal desc);

create table if not exists tagihan (
  id uuid primary key default gen_random_uuid(),
  santri_id uuid references profiles(id),
  jenis text not null,
  periode text,
  nominal int not null,
  jatuh_tempo date not null,
  status text default 'belum_bayar' check (status in ('belum_bayar','menunggu_verifikasi','lunas','batal')),
  created_at timestamptz default now()
);

create table if not exists pembayaran (
  id uuid primary key default gen_random_uuid(),
  tagihan_id uuid references tagihan(id),
  nominal int not null,
  metode text,
  bukti_url text,
  catatan_admin text,
  verified_by uuid references profiles(id),
  verified_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists ujian (
  id uuid primary key default gen_random_uuid(),
  mata_pelajaran_id uuid references mata_pelajaran(id),
  judul text not null,
  tipe text check (tipe in ('UTS','UAS','Kuis','Tryout')),
  soal_json jsonb not null,
  durasi_menit int not null,
  mulai timestamptz not null,
  selesai timestamptz not null,
  acak_soal boolean default true,
  acak_opsi boolean default true,
  created_at timestamptz default now()
);

create table if not exists percobaan_ujian (
  id uuid primary key default gen_random_uuid(),
  ujian_id uuid references ujian(id),
  santri_id uuid references profiles(id),
  jawaban_json jsonb,
  nilai int,
  status text default 'berlangsung' check (status in ('berlangsung','selesai','batal')),
  mulai_pada timestamptz default now(),
  selesai_pada timestamptz,
  unique (ujian_id, santri_id)
);

create table if not exists krs (
  id uuid primary key default gen_random_uuid(),
  santri_id uuid references profiles(id),
  mata_pelajaran_id uuid references mata_pelajaran(id),
  semester text not null,
  status text default 'aktif' check (status in ('aktif','batal','lulus','gagal')),
  created_at timestamptz default now(),
  unique (santri_id, mata_pelajaran_id, semester)
);

create table if not exists khs (
  id uuid primary key default gen_random_uuid(),
  santri_id uuid references profiles(id),
  semester text not null,
  ips numeric(3,2),
  ipk numeric(3,2),
  status text default 'proses',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (santri_id, semester)
);

alter table profiles enable row level security;
alter table presensi enable row level security;
alter table tagihan enable row level security;
alter table pembayaran enable row level security;
alter table ujian enable row level security;
alter table percobaan_ujian enable row level security;
alter table krs enable row level security;
alter table khs enable row level security;
EOF