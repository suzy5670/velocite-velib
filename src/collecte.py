"""Collecte des disponibilités Vélib' et envoi vers BigQuery."""
import logging
from pathlib import Path

import pandas as pd
import pandas_gbq
import requests

PROJET = "velocite-velib"
DATASET = "velib"
URL_INFO = "https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_information.json"
URL_STATUS = "https://velib-metropole-opendata.smovengo.cloud/opendata/Velib_Metropole/station_status.json"


DOSSIER_LOGS = Path(__file__).resolve().parent.parent / "logs"
DOSSIER_LOGS.mkdir(exist_ok=True)
logging.basicConfig(
    filename=DOSSIER_LOGS / "collecte.log",
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    encoding="utf-8",
)


def appeler_api(url):
    """Appelle l'API et renvoie les stations sous forme de DataFrame."""
    reponse = requests.get(url, timeout=30)
    reponse.raise_for_status()
    return pd.DataFrame(reponse.json()["data"]["stations"])


def preparer_stations(df_info):
    """Table stations : infos fixes de chaque station."""
    df_info["accepte_cb"] = df_info["rental_methods"].notna()
    colonnes = ["station_id", "stationCode", "name", "lat", "lon", "capacity", "accepte_cb"]
    return df_info[colonnes].drop_duplicates(subset="station_id")


def preparer_disponibilites(df_status, df_stations):
    """Table disponibilites : une photo de chaque station par heure."""
    df = df_status.copy()
    df["nb_mecaniques"] = df["num_bikes_available_types"].str[0].str["mechanical"]
    df["nb_electriques"] = df["num_bikes_available_types"].str[1].str["ebike"]

    df["last_reported"] = pd.to_datetime(df["last_reported"], unit="s", utc=True)
    df["date_collecte"] = pd.Timestamp.now(tz="UTC")
    # Clé unique : station + heure de collecte (ex. 213688169_2026101309)
    df["cle"] = df["station_id"].astype(str) + "_" + df["date_collecte"].dt.strftime("%Y%m%d%H")

    df = df.merge(df_stations[["station_id", "capacity"]], on="station_id", how="left")
    df = df[(df["capacity"] > 0) & (df["is_installed"] == 1)]
    df["taux_remplissage"] = df["num_bikes_available"] / df["capacity"]
    df["station_vide"] = df["num_bikes_available"] == 0
    df["station_pleine"] = df["num_docks_available"] == 0

    colonnes = ["cle", "station_id", "num_bikes_available", "num_docks_available",
                "nb_mecaniques", "nb_electriques", "is_renting", "is_returning",
                "last_reported", "date_collecte", "taux_remplissage",
                "station_vide", "station_pleine"]
    return df[colonnes].drop_duplicates(subset="cle")


def retirer_deja_presentes(df):
    """Anti-doublons : on retire les lignes dont la clé est déjà dans BigQuery."""
    requete = f"SELECT cle FROM `{PROJET}.{DATASET}.disponibilites`"
    try:
        deja = pandas_gbq.read_gbq(requete, project_id=PROJET)
    except Exception:
        logging.info("Table disponibilites absente : première collecte")
        return df
    return df[~df["cle"].isin(deja["cle"])]


def ecrire_journal(statut, nb_lignes, message):
    """Trace de chaque exécution dans la table journal_executions."""
    journal = pd.DataFrame([{
        "date_execution": pd.Timestamp.now(tz="UTC"),
        "statut": statut,
        "nb_lignes": nb_lignes,
        "message": message,
    }])
    pandas_gbq.to_gbq(journal, f"{DATASET}.journal_executions", project_id=PROJET, if_exists="append")


def main():
    logging.info("Début de la collecte")
    try:
        df_stations = preparer_stations(appeler_api(URL_INFO))
        df_dispo = preparer_disponibilites(appeler_api(URL_STATUS), df_stations)
        nb_recues = len(df_dispo)
        df_dispo = retirer_deja_presentes(df_dispo)

        pandas_gbq.to_gbq(df_stations, f"{DATASET}.stations", project_id=PROJET, if_exists="replace")
        if len(df_dispo) > 0:
            pandas_gbq.to_gbq(df_dispo, f"{DATASET}.disponibilites", project_id=PROJET, if_exists="append")

        message = f"{nb_recues} lignes reçues, {len(df_dispo)} nouvelles envoyées"
        logging.info(message)
        ecrire_journal("OK", len(df_dispo), message)
    except Exception as erreur:
        logging.error(f"Échec de la collecte : {erreur}")
        try:
            ecrire_journal("ERREUR", 0, str(erreur))
        except Exception:
            pass
        raise


if __name__ == "__main__":
    main()
