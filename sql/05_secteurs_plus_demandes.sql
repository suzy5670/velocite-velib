-- Requête 5 : secteurs les plus demandés (départs nets estimés entre deux photos)
WITH variations AS (
  SELECT
    station_id,
    num_bikes_available
      - LAG(num_bikes_available) OVER (PARTITION BY station_id ORDER BY date_collecte) AS variation
  FROM `velocite-velib.velib.disponibilites`
),
zones AS (
  SELECT
    station_id,
    IF(SAFE_CAST(stationCode AS INT64) < 21000,
       CONCAT("Paris ", CAST(DIV(SAFE_CAST(stationCode AS INT64), 1000) AS STRING)),
       "Hors Paris") AS zone
  FROM `velocite-velib.velib.stations`
)
SELECT
  z.zone,
  SUM(IF(v.variation < 0, -v.variation, 0)) AS departs_estimes,
  SUM(IF(v.variation > 0, v.variation, 0)) AS arrivees_estimees
FROM variations AS v
JOIN zones AS z ON v.station_id = z.station_id
GROUP BY z.zone
ORDER BY departs_estimes DESC
LIMIT 10%%writefile sql/05_secteurs_plus_demandes.sql
-- Requête 5 : secteurs les plus demandés (départs nets estimés entre deux photos)
WITH variations AS (
  SELECT
    station_id,
    num_bikes_available
      - LAG(num_bikes_available) OVER (PARTITION BY station_id ORDER BY date_collecte) AS variation
  FROM `velocite-velib.velib.disponibilites`
),
zones AS (
  SELECT
    station_id,
    IF(SAFE_CAST(stationCode AS INT64) < 21000,
       CONCAT("Paris ", CAST(DIV(SAFE_CAST(stationCode AS INT64), 1000) AS STRING)),
       "Hors Paris") AS zone
  FROM `velocite-velib.velib.stations`
)
SELECT
  z.zone,
  SUM(IF(v.variation < 0, -v.variation, 0)) AS departs_estimes,
  SUM(IF(v.variation > 0, v.variation, 0)) AS arrivees_estimees
FROM variations AS v
JOIN zones AS z ON v.station_id = z.station_id
GROUP BY z.zone
ORDER BY departs_estimes DESC
LIMIT 10%%writefile sql/05_secteurs_plus_demandes.sql
-- Requête 5 : secteurs les plus demandés (départs nets estimés entre deux photos)
WITH variations AS (
  SELECT
    station_id,
    num_bikes_available
      - LAG(num_bikes_available) OVER (PARTITION BY station_id ORDER BY date_collecte) AS variation
  FROM `velocite-velib.velib.disponibilites`
),
zones AS (
  SELECT
    station_id,
    IF(SAFE_CAST(stationCode AS INT64) < 21000,
       CONCAT("Paris ", CAST(DIV(SAFE_CAST(stationCode AS INT64), 1000) AS STRING)),
       "Hors Paris") AS zone
  FROM `velocite-velib.velib.stations`
)
SELECT
  z.zone,
  SUM(IF(v.variation < 0, -v.variation, 0)) AS departs_estimes,
  SUM(IF(v.variation > 0, v.variation, 0)) AS arrivees_estimees
FROM variations AS v
JOIN zones AS z ON v.station_id = z.station_id
GROUP BY z.zone
ORDER BY departs_estimes DESC
LIMIT 10
