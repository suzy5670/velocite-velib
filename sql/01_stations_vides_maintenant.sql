-- Requête 1 : stations vides lors de la dernière collecte, les plus grandes d'abord
SELECT s.name, s.stationCode, s.capacity, d.date_collecte
FROM `velocite-velib.velib.disponibilites` AS d
JOIN `velocite-velib.velib.stations` AS s ON d.station_id = s.station_id
WHERE d.station_vide
  AND d.date_collecte = (SELECT MAX(date_collecte) FROM `velocite-velib.velib.disponibilites`)
ORDER BY s.capacity DESC
