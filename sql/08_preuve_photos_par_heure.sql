-- Preuve : nombre de stations enregistrées pour chaque heure de collecte
SELECT
  DATETIME_TRUNC(DATETIME(date_collecte, "Europe/Paris"), HOUR) AS heure_paris,
  COUNT(*) AS nb_stations
FROM `velocite-velib.velib.disponibilites`
GROUP BY heure_paris
ORDER BY heure_paris DESC
