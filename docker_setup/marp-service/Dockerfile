# Nimm ein offizielles Node.js Image
FROM node:18-slim

# Installiere die System-Abhängigkeiten für Chromium und Marp CLI
# Viele dieser Pakete sind notwendig, damit Chromium/Puppeteer in einer Headless-Umgebung
# ohne eine physikalische GPU korrekt funktioniert.
# --no-install-recommends reduziert die Größe des Images.
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    # Font-Pakete für die korrekte Darstellung (oft für PDFs wichtig)
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    # Bibliotheken, die Chromium/Puppeteer für Rendering benötigt
    libgbm-dev \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgconf-2-4 \
    libnss3 \
    libasound2 \
    libxss1 \
    libxi6 \
    libxtst6 \
    libnspr4 \
    libdbus-glib-1-2 \
    libfontconfig1 \
    libfreetype6 \
    libharfbuzz0b \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    # Pakete entfernt, die "no installation candidate" Fehler verursachen
    # libjpeg-turbo8 \
    # libwebp6 \
    # Aufräumen des APT-Caches, um das Image schlank zu halten
    && rm -rf /var/lib/apt/lists/*

# Installiere Marp CLI global, damit der 'marp'-Befehl im PATH liegt
RUN npm install -g @marp-team/marp-cli

# Setze das Arbeitsverzeichnis im Container
WORKDIR /usr/src/app

# Kopiere die package.json und installiere die *lokalen* Abhängigkeiten (Express)
# Marp CLI wurde bereits global installiert, daher muss es nicht mehr hier sein.
COPY package.json ./
RUN npm install

# Kopiere den restlichen App-Code
COPY index.js ./

# Setze Umgebungsvariablen, damit Puppeteer den installierten Browser findet
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Exponiere den Port
EXPOSE 3000

# Starte den Server
CMD [ "npm", "start" ]
