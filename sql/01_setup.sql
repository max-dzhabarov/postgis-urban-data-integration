CREATE EXTENSION IF NOT EXISTS postgis;

DROP SCHEMA IF EXISTS demo_agr CASCADE;
CREATE SCHEMA demo_agr;

-- 1. Основной табличный реестр АГР.
CREATE TABLE demo_agr.agr_register (
    source_id bigint PRIMARY KEY,
    document_number text,
    object_name text,
    decision_date date,
    status text
);

-- 2. Основной пространственный источник.
CREATE TABLE demo_agr.agr_geometry (
    source_id bigint PRIMARY KEY,
    document_number text,
    geom geometry(MultiPolygon, 3857) NOT NULL
);

-- 3. Разрешения на строительство: номера АГР отсутствуют.
CREATE TABLE demo_agr.construction_permits (
    source_id bigint PRIMARY KEY,
    permit_number text NOT NULL,
    geom geometry(MultiPolygon, 3857) NOT NULL
);

-- 4. Объекты, введённые в эксплуатацию: номера АГР отсутствуют.
CREATE TABLE demo_agr.commissioned_objects (
    source_id bigint PRIMARY KEY,
    commissioning_number text NOT NULL,
    geom geometry(MultiPolygon, 3857) NOT NULL
);

-- 5. Ручные дополнения для отсутствующей геометрии.
CREATE TABLE demo_agr.manual_geometry_additions (
    source_id bigint PRIMARY KEY,
    document_number text,
    note text,
    geom geometry(MultiPolygon, 3857) NOT NULL
);

-- 6–7. Разовые дополнительные табличные источники.
CREATE TABLE demo_agr.supplementary_registry_a (
    source_id bigint PRIMARY KEY,
    document_number text,
    object_name text,
    note text
);

CREATE TABLE demo_agr.supplementary_registry_b (
    source_id bigint PRIMARY KEY,
    document_number text,
    object_name text,
    note text
);

CREATE INDEX agr_geometry_geom_gix
    ON demo_agr.agr_geometry USING gist (geom);
CREATE INDEX construction_permits_geom_gix
    ON demo_agr.construction_permits USING gist (geom);
CREATE INDEX commissioned_objects_geom_gix
    ON demo_agr.commissioned_objects USING gist (geom);
CREATE INDEX manual_geometry_additions_geom_gix
    ON demo_agr.manual_geometry_additions USING gist (geom);
