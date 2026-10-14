-- Contrôle qualité : vérifie qu'il n'y a aucun doublon
-- Si nb_lignes = nb_cles_uniques, chaque photo (station + heure) est unique
SELECT
  COUNT(*) AS nb_lignes,
  COUNT(DISTINCT cle) AS nb_cles_uniques
FROM `velocite-velib.velib.disponibilites`
