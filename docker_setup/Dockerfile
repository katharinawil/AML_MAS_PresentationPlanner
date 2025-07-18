# Nimm das offizielle n8n-Image als Basis
FROM n8nio/n8n

# Wechsle zum root-Benutzer, um globale Pakete zu installieren
USER root

# KORRIGIERT: Installiere Chromium und Schriften mit dem 'apk'-Paketmanager für Alpine Linux
RUN apk add --no-cache chromium nss freetype font-noto

# Installiere die Marp CLI
RUN npm install -g @marp-team/marp-cli

# Wechsle wieder zurück zum 'node'-Benutzer, unter dem n8n läuft
USER node
