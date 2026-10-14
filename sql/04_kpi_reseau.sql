-- Requête 4 : état du réseau lors de la dernière collecte
SELECT
  SUM(d.num_bikes_available) AS velos_disponibles,
  SUM(d.nb_mecaniques) AS velos_mecaniques,
  SUM(d.nb_electriques) AS velos_electriques,
  SUM(GREATEST(s.capacity - d.num_bikes_available - d.num_docks_available, 0)) AS places_hors_service
FROM `velocite-velib.velib.disponibilites` AS d
JOIN `velocite-velib.velib.stations` AS s ON d.station_id = s.station_id
WHERE d.date_collecte = (SELECT MAX(date_collecte) FROM `velocite-velib.velib.disponibilites`)
