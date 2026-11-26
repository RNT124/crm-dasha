-- ════════════════════════════════════════════════════════════════════
-- schema_showrooms.sql — Módulo "Showrooms Ozia" (solo Dasha)
-- YA APLICADO en el Supabase "Dasha-CRM". Se guarda aquí como respaldo.
-- Mercadería entregada a cada showroom + reportes de ventas de cada uno.
-- ════════════════════════════════════════════════════════════════════
create table public.showrooms (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  empresa text,
  formato_ingreso text not null default 'sistema',   -- sistema | bohoo | cd
  formato_venta text not null default 'mensual',     -- mensual | fascino | bohoo
  comision_pct numeric,
  alquiler_mensual numeric,
  activo boolean not null default true,
  orden integer default 0,
  notas text,
  creado_en timestamptz not null default now()
);
create table public.showroom_productos (          -- catálogo maestro de Ozia (modelo + color)
  id uuid primary key default gen_random_uuid(),
  clave text not null unique,
  nombre text not null,
  categoria text,
  color text,
  costo numeric,
  creado_en timestamptz not null default now()
);
create table public.showroom_ingresos (           -- cada Excel de mercadería entregada
  id uuid primary key default gen_random_uuid(),
  showroom_id uuid not null references public.showrooms(id) on delete cascade,
  fecha date not null default current_date,
  archivo text,
  unidades integer not null default 0,
  usuario text,
  creado_en timestamptz not null default now()
);
create table public.showroom_items (              -- cada código entregado a un showroom
  id uuid primary key default gen_random_uuid(),
  showroom_id uuid not null references public.showrooms(id) on delete cascade,
  ingreso_id uuid references public.showroom_ingresos(id) on delete cascade,
  producto_id uuid references public.showroom_productos(id) on delete set null,
  codigo text,
  codigo_norm text,
  descripcion text,
  precio numeric,
  cantidad integer not null default 1,
  retiradas integer not null default 0,
  fecha_ingreso date not null default current_date,
  creado_en timestamptz not null default now()
);
create index showroom_items_codigo_idx on public.showroom_items (showroom_id, codigo_norm);
create table public.showroom_reportes (           -- cada Excel de ventas del showroom
  id uuid primary key default gen_random_uuid(),
  showroom_id uuid not null references public.showrooms(id) on delete cascade,
  desde date,
  hasta date,
  archivo text,
  unidades integer not null default 0,
  total_ventas numeric not null default 0,
  comision_pct numeric,
  comision_monto numeric not null default 0,
  alquiler numeric not null default 0,
  total_depositar numeric not null default 0,
  usuario text,
  creado_en timestamptz not null default now()
);
create table public.showroom_ventas (             -- cada prenda vendida en el showroom
  id uuid primary key default gen_random_uuid(),
  reporte_id uuid not null references public.showroom_reportes(id) on delete cascade,
  showroom_id uuid not null references public.showrooms(id) on delete cascade,
  item_id uuid references public.showroom_items(id) on delete set null,
  producto_id uuid references public.showroom_productos(id) on delete set null,
  fecha date,
  codigo text,
  codigo_norm text,
  descripcion text,
  precio_lista numeric,
  precio_venta numeric not null default 0,
  cantidad integer not null default 1,
  comision numeric not null default 0,
  neto numeric not null default 0,
  tipo_pago text,
  devolucion boolean not null default false,
  creado_en timestamptz not null default now()
);
create index showroom_ventas_sr_idx on public.showroom_ventas (showroom_id, fecha);
create index showroom_ventas_item_idx on public.showroom_ventas (item_id);

alter table public.showrooms disable row level security;
alter table public.showroom_productos disable row level security;
alter table public.showroom_ingresos disable row level security;
alter table public.showroom_items disable row level security;
alter table public.showroom_reportes disable row level security;
alter table public.showroom_ventas disable row level security;
grant all on public.showrooms, public.showroom_productos, public.showroom_ingresos, public.showroom_items, public.showroom_reportes, public.showroom_ventas to anon, authenticated, service_role;

insert into public.showrooms (nombre, empresa, formato_ingreso, formato_venta, comision_pct, alquiler_mensual, orden, notas) values
 ('Miraflores', null, 'sistema', 'mensual', 15, 960, 1, 'Comisión y alquiler tomados del reporte de octubre'),
 ('Surco', 'Caminos', 'sistema', 'mensual', 25, 1240, 2, 'Reporte llega como "Caminos". Comisión y alquiler del reporte 21/09-20/10'),
 ('Polo', null, 'sistema', 'mensual', 25, null, 3, 'Comisión del reporte 07/09-06/10. Alquiler: completar'),
 ('Bohoo', 'RB Group', 'bohoo', 'bohoo', 20, null, 4, 'Comisión 20% (RB Group) según reporte ene-feb. Alquiler: completar'),
 ('Jockey', 'Fascino S.A.C.', 'cd', 'fascino', 30, null, 5, 'Supuesto: reporte Fascino "OZIA" (30%). Confirmar'),
 ('Conquistadores', 'Fascino S.A.C.', 'cd', 'fascino', 20, null, 6, 'Supuesto: reporte Fascino "TWINS" (20%). Confirmar');
