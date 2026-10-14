-- Requête 3 : top 10 des stations le plus souvent vides
SELECT
  s.station_id, s.name, s.stationCode,
  COUNT(*) AS nb_photos,
  COUNTIF(d.station_vide) AS nb_fois_vide,
  ROUND(100 * COUNTIF(d.station_vide) / COUNT(*), 1) AS pct_temps_vide
FROM `velocite-velib.velib.disponibilites` AS d
JOIN `velocite-velib.velib.stations` AS s ON d.station_id = s.station_id
GROUP BY s.station_id, s.name, s.stationCode
ORDER BY pct_temps_vide DESC, nb_fois_vide DESC
LIMIT 10
