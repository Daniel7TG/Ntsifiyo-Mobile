"""Login compartido por los scripts de pre-poblado de build
(export_dictionary.py, export_games.py).

Las credenciales SIEMPRE se leen de variables de entorno — nunca se piden
por línea de comandos (quedarían en el historial del shell) ni se escriben
en ningún script. Configúralas antes de correr los scripts:

    export JNATRJO_CI_USERNAME=...
    export JNATRJO_CI_PASSWORD=...

Requiere: pip install requests
"""

import os

import requests


def login(api_base, role="visitor"):
    """Inicia sesión con las credenciales de CI y devuelve el JWT.

    role: "visitor" (default) sirve para el diccionario y para explorar
    juegos por tema/tipo. "admin" hace falta para /api/games (el listado
    completo con paginación y gameTopic por juego) — confirmado en vivo que
    ese endpoint responde 403 para visitante mientras que
    /api/games/topic/{topic} y /api/activities/start/game/{id} sí funcionan
    con ambos roles.
    """
    username = os.environ.get("JNATRJO_CI_USERNAME")
    password = os.environ.get("JNATRJO_CI_PASSWORD")
    if not username or not password:
        raise SystemExit(
            "Faltan credenciales de CI: exporta JNATRJO_CI_USERNAME y "
            "JNATRJO_CI_PASSWORD antes de correr este script. No las pases "
            "como argumento de línea de comandos ni las escribas en el "
            "código — solo como variables de entorno."
        )

    endpoint = "/api/auth/login/admin" if role == "admin" else "/api/auth/login/visitor"
    resp = requests.post(
        f"{api_base}{endpoint}",
        json={"username": username, "password": password, "grade": None},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()["jwtToken"]
