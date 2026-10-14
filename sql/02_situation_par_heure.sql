-- Requête 2 : situation moyenne par heure (heure de Paris)
SELECT
  EXTRACT(HOUR FROM DATETIME(date_collecte, "Europe/Paris")) AS heure,
  ROUND(100 * AVG(taux_remplissage), 1) AS taux_remplissage_moyen_pct,
  ROUND(100 * COUNTIF(station_vide) / COUNT(*), 1) AS pct_stations_vides,
  ROUND(100 * COUNTIF(station_pleine) / COUNT(*), 1) AS pct_stations_pleines
FROM `velocite-velib.velib.disponibilites`
GROUP BY heure
ORDER BY heure
