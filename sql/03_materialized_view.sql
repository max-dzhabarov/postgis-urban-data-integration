DROP MATERIALIZED VIEW IF EXISTS demo_agr.mv_consolidated_agr;

CREATE MATERIALIZED VIEW demo_agr.mv_consolidated_agr AS
WITH normalized_register AS (
    SELECT
        upper(regexp_replace(btrim(document_number), '\s+', '', 'g')) AS agr_key,
        object_name,
        decision_date,
        status,
        1 AS source_priority
    FROM demo_agr.agr_register
    WHERE NULLIF(btrim(document_number), '') IS NOT NULL
),
normalized_supplementary AS (
    SELECT
        upper(regexp_replace(btrim(document_number), '\s+', '', 'g')) AS agr_key,
        object_name,
        NULL::date AS decision_date,
        note AS status,
        2 AS source_priority
    FROM demo_agr.supplementary_registry_a
    WHERE NULLIF(btrim(document_number), '') IS NOT NULL

    UNION ALL

    SELECT
        upper(regexp_replace(btrim(document_number), '\s+', '', 'g')) AS agr_key,
        object_name,
        NULL::date AS decision_date,
        note AS status,
        3 AS source_priority
    FROM demo_agr.supplementary_registry_b
    WHERE NULLIF(btrim(document_number), '') IS NOT NULL
),
all_records AS (
    SELECT * FROM normalized_register
    UNION ALL
    SELECT * FROM normalized_supplementary
),
deduplicated AS (
    SELECT DISTINCT ON (agr_key)
        agr_key,
        object_name,
        decision_date,
        status
    FROM all_records
    ORDER BY agr_key, source_priority
),
normalized_geometry AS (
    SELECT
        upper(regexp_replace(btrim(document_number), '\s+', '', 'g')) AS agr_key,
        geom,
        1 AS geometry_priority
    FROM demo_agr.agr_geometry
    WHERE NULLIF(btrim(document_number), '') IS NOT NULL

    UNION ALL

    SELECT
        upper(regexp_replace(btrim(document_number), '\s+', '', 'g')) AS agr_key,
        geom,
        2 AS geometry_priority
    FROM demo_agr.manual_geometry_additions
    WHERE NULLIF(btrim(document_number), '') IS NOT NULL
),
preferred_geometry AS (
    SELECT DISTINCT ON (agr_key)
        agr_key,
        geom,
        CASE geometry_priority
            WHEN 1 THEN 'main_source'
            ELSE 'manual_addition'
        END AS geometry_source
    FROM normalized_geometry
    ORDER BY agr_key, geometry_priority
)
SELECT
    row_number() OVER (ORDER BY d.agr_key)::bigint AS id,
    d.agr_key,
    d.object_name,
    d.decision_date,
    d.status,
    g.geometry_source,
    permits.permit_numbers,
    commissioned.commissioning_numbers,
    g.geom
FROM deduplicated AS d
LEFT JOIN preferred_geometry AS g USING (agr_key)
LEFT JOIN LATERAL (
    SELECT string_agg(DISTINCT p.permit_number, ', ' ORDER BY p.permit_number)
        AS permit_numbers
    FROM demo_agr.construction_permits AS p
    WHERE g.geom IS NOT NULL
      AND ST_Intersects(g.geom, p.geom)
) AS permits ON true
LEFT JOIN LATERAL (
    SELECT string_agg(
        DISTINCT c.commissioning_number,
        ', ' ORDER BY c.commissioning_number
    ) AS commissioning_numbers
    FROM demo_agr.commissioned_objects AS c
    WHERE g.geom IS NOT NULL
      AND ST_Intersects(g.geom, c.geom)
) AS commissioned ON true
WITH DATA;

CREATE UNIQUE INDEX mv_consolidated_agr_id_uidx
    ON demo_agr.mv_consolidated_agr (id);

CREATE UNIQUE INDEX mv_consolidated_agr_key_uidx
    ON demo_agr.mv_consolidated_agr (agr_key);

CREATE INDEX mv_consolidated_agr_geom_gix
    ON demo_agr.mv_consolidated_agr USING gist (geom);
