-- Vue utilisée par le dashboard Data Studio
CREATE OR REPLACE VIEW `velocite-velib.velib.vue_dashboard` AS
SELECT
  d.*,
  s.name, s.stationCode, s.capacity, s.accepte_cb,
  DATETIME(d.date_collecte, "Europe/Paris") AS date_collecte_paris,
  EXTRACT(HOUR FROM DATETIME(d.date_collecte, "Europe/Paris")) AS heure,
  IF(SAFE_CAST(s.stationCode AS INT64) < 21000,
     CONCAT("Paris ", CAST(DIV(SAFE_CAST(s.stationCode AS INT64), 1000) AS STRING)),
     "Hors Paris") AS zone,
  GREATEST(s.capacity - d.num_bikes_available - d.num_docks_available, 0) AS places_hors_service,
  CAST(d.station_vide AS INT64) AS est_vide,
  CAST(d.station_pleine AS INT64) AS est_pleine,
  CONCAT(CAST(s.lat AS STRING), ",", CAST(s.lon AS STRING)) AS coordonnees
FROM `velocite-velib.velib.disponibilites` AS d
JOIN `velocite-velib.velib.stations` AS s ON d.station_id = s.station_id
