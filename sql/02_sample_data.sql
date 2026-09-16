TRUNCATE TABLE
    demo_agr.agr_register,
    demo_agr.agr_geometry,
    demo_agr.construction_permits,
    demo_agr.commissioned_objects,
    demo_agr.manual_geometry_additions,
    demo_agr.supplementary_registry_a,
    demo_agr.supplementary_registry_b;

INSERT INTO demo_agr.agr_register
    (source_id, document_number, object_name, decision_date, status)
VALUES
    (1, ' АГР-001 ', 'Жилой комплекс «Север»', DATE '2025-02-14', 'Согласовано'),
    (2, 'агр-002', 'Общественный центр', DATE '2025-03-10', 'На рассмотрении'),
    (3, NULL, 'Запись без номера', DATE '2025-03-12', 'Черновик');

INSERT INTO demo_agr.agr_geometry (source_id, document_number, geom)
VALUES
    (1, 'АГР-001', ST_Multi(ST_GeomFromText('POLYGON((0 0, 80 0, 80 60, 0 60, 0 0))', 3857)));

INSERT INTO demo_agr.construction_permits
    (source_id, permit_number, geom)
VALUES
    (1, 'РС-101', ST_Multi(ST_GeomFromText('POLYGON((10 10, 50 10, 50 40, 10 40, 10 10))', 3857))),
    (2, 'РС-102', ST_Multi(ST_GeomFromText('POLYGON((120 10, 170 10, 170 50, 120 50, 120 10))', 3857)));

INSERT INTO demo_agr.commissioned_objects
    (source_id, commissioning_number, geom)
VALUES
    (1, 'РВ-201', ST_Multi(ST_GeomFromText('POLYGON((20 20, 45 20, 45 45, 20 45, 20 20))', 3857)));

INSERT INTO demo_agr.manual_geometry_additions
    (source_id, document_number, note, geom)
VALUES
    (1, ' АГР-002 ', 'Геометрия добавлена вручную',
     ST_Multi(ST_GeomFromText('POLYGON((100 0, 180 0, 180 60, 100 60, 100 0))', 3857)));

INSERT INTO demo_agr.supplementary_registry_a
    (source_id, document_number, object_name, note)
VALUES
    (1, 'АГР-003', 'Школа', 'Разовая выгрузка A');

INSERT INTO demo_agr.supplementary_registry_b
    (source_id, document_number, object_name, note)
VALUES
    (1, ' агр-004 ', 'Поликлиника', 'Разовая выгрузка B');
