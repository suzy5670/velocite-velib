-- Preuve : historique des exécutions automatiques
SELECT
  DATETIME(date_execution, "Europe/Paris") AS execution_paris,
  statut, nb_lignes, message
FROM `velocite-velib.velib.journal_executions`
ORDER BY date_execution DESC
