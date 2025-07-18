// index.js

// -----------------------------------------------------------------------------
// WICHTIG: Alle 'require'-Statements müssen am ANFANG der Datei stehen,
// bevor die Variablen verwendet werden!
// -----------------------------------------------------------------------------
const express = require('express');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// -----------------------------------------------------------------------------
// Initialisierung der Express-App und Middleware
// -----------------------------------------------------------------------------
const app = express();
app.use(express.text({ type: 'text/markdown', limit: '10mb' })); // Ermöglicht das Senden von Markdown als Text im Body

// -----------------------------------------------------------------------------
// Haupt-Route für die Konvertierung
// -----------------------------------------------------------------------------
app.post('/convert', (req, res) => {
    console.log('[/convert] Anfrage erhalten. Starte Konvertierung...');

    // --- NEU: Marp Front-Matter für das Theming ---
    // Dieser Block wird an den Anfang jeder Markdown-Datei gesetzt.
    const marpFrontMatter = `---
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
---

`; // Die Leerzeile am Ende ist wichtig für die korrekte Trennung.

    // Kombiniere den Front-Matter-Block mit dem empfangenen Markdown
    const fullMarkdownContent = marpFrontMatter + req.body;
    // -------------------------------------------------

    // Generiere eindeutige Dateinamen für temporäre Dateien
    const uniqueId = crypto.randomBytes(16).toString('hex');
    const inputPath = path.join('/tmp', `${uniqueId}.md`);
    const outputPath = path.join('/tmp', `${uniqueId}.pdf`);

    // Schreibe die empfangenen und modifizierten Markdown-Daten in eine temporäre Datei
    try {
        fs.writeFileSync(inputPath, fullMarkdownContent); // <-- Verwendet jetzt den kombinierten Inhalt
        console.log(`[/convert] Markdown-Datei gespeichert: ${inputPath}`);
    } catch (writeErr) {
        console.error(`[/convert] Fehler beim Schreiben der Markdown-Datei: ${writeErr.message}`);
        return res.status(500).send('Interner Serverfehler: Konnte Markdown-Datei nicht speichern.');
    }

    // Baue den Marp CLI Befehl zusammen
    const command = 'marp';
    const args = [
        inputPath,
        '--pdf', // Ausgabe als PDF
        '--allow-local-files', // Erlaubt Zugriff auf lokale Dateien (z.B. Bilder im gleichen Verzeichnis)
        '--no-stdin', // Verhindert, dass Marp auf stdin wartet
        // WICHTIG: Diese Engine-Argumente sind für Headless Chrome/Puppeteer auf Servern ohne GPU
        '--engine.args=--no-sandbox',
        '--engine.args=--disable-gpu',
        '--engine.args=--disable-dev-shm-usage', // Behebt Probleme mit Shared Memory in Docker
        '-o', // Ausgabe-Datei
        outputPath
    ];

    console.log(`[/convert] Führe Befehl aus: ${command} ${args.join(' ')}`);

    // Definieren der Umgebung für den spawned Prozess basierend auf 'container_env.txt'
    const marpProcessEnv = {
        ...process.env, // Übernimm alle Umgebungsvariablen des Node.js-Elternprozesses
        HOME: '/root', // Wichtig: Setze HOME auf /root
        PATH: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', // Expliziter PATH
        TERM: 'xterm',
        DEBIAN_FRONTEND: 'noninteractive'
    };

    console.log('[/convert] Spawning Marp with environment:', marpProcessEnv);

    // Starte den Marp-Prozess mit der definierten Umgebung und einem Timeout
    const marpProcess = spawn(command, args, {
        env: marpProcessEnv,
        timeout: 120000 // Erhöhter Timeout auf 120 Sekunden (2 Minuten)
    });

    // Event-Listener für Standard-Output (Konsole) von Marp
    marpProcess.stdout.on('data', (data) => {
        console.log(`[Marp STDOUT]: ${data.toString().trim()}`);
    });

    // Event-Listener für Standard-Fehlerausgabe von Marp
    marpProcess.stderr.on('data', (data) => {
        console.error(`[Marp STDERR]: ${data.toString().trim()}`);
    });

    // Event-Listener für Fehler beim Starten des Marp-Prozesses selbst
    marpProcess.on('error', (err) => {
        console.error(`[/convert] Fehler beim Starten des Marp-Prozesses: ${err.message}`);
        cleanupFiles(inputPath, outputPath);
        if (!res.headersSent) {
            res.status(500).send(`Interner Serverfehler: Konnte Marp-Prozess nicht starten. ${err.message}`);
        }
    });

    // Event-Listener für Timeout
    marpProcess.on('timeout', () => {
        console.error('[/convert] Marp-Prozess hat den Timeout überschritten. Wird beendet.');
        marpProcess.kill('SIGTERM');
        cleanupFiles(inputPath, outputPath);
        if (!res.headersSent) {
            res.status(504).send('Gateway Timeout: Konvertierung hat zu lange gedauert.');
        }
    });

    // Event-Listener, wenn der Marp-Prozess beendet ist
    marpProcess.on('close', (code) => {
        console.log(`[/convert] Marp-Prozess beendet mit Code: ${code}`);

        if (code === 0) {
            // Erfolg: PDF-Datei an den Client senden
            console.log(`[/convert] Sende PDF-Datei: ${outputPath}`);
            res.download(outputPath, 'presentation.pdf', (err) => {
                if (err) {
                    console.error(`[/convert] Fehler beim Senden der PDF-Datei: ${err.message}`);
                    if (!res.headersSent) {
                        res.status(500).send('Fehler beim Senden der generierten PDF.');
                    }
                } else {
                    console.log('[/convert] PDF-Datei erfolgreich gesendet.');
                }
                cleanupFiles(inputPath, outputPath);
            });
        } else {
            // Fehler: Marp-Prozess ist mit einem Fehlercode beendet
            console.error(`[/convert] Marp-Prozess fehlgeschlagen mit Code: ${code}.`);
            cleanupFiles(inputPath, outputPath);
            if (!res.headersSent) {
                res.status(500).send(`Konvertierungsfehler: Marp-Prozess beendet mit Code ${code}.`);
            }
        }
    });
});

// -----------------------------------------------------------------------------
// Hilfsfunktion zum Aufräumen der temporären Dateien
// -----------------------------------------------------------------------------
function cleanupFiles(mdPath, pdfPath) {
    fs.unlink(mdPath, (err) => {
        if (err && err.code !== 'ENOENT') {
            console.error(`[/cleanup] Fehler beim Löschen von ${mdPath}: ${err.message}`);
        } else {
            console.log(`[/cleanup] ${mdPath} gelöscht.`);
        }
    });
    fs.unlink(pdfPath, (err) => {
        if (err && err.code !== 'ENOENT') {
            console.error(`[/cleanup] Fehler beim Löschen von ${pdfPath}: ${err.message}`);
        } else {
            console.log(`[/cleanup] ${pdfPath} gelöscht.`);
        }
    });
}

// -----------------------------------------------------------------------------
// Server starten
// -----------------------------------------------------------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Marp service lauscht auf Port ${PORT}`);
});
