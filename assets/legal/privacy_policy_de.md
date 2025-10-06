# Datenschutzerklärung für Lifeline

**Gültig ab:** 2. Oktober 2025

Vielen Dank, dass Sie Lifeline nutzen! Ihre Privatsphäre ist uns sehr wichtig. Diese Datenschutzerklärung erklärt, welche Daten wir sammeln, wie wir sie verwenden, wie wir sie schützen und welche Rechte Sie bezüglich Ihrer persönlichen Informationen haben.

## 1. Informationen, die wir sammeln

### 1.1 Kontoinformationen
Wenn Sie ein Konto erstellen, sammeln wir:

- **E-Mail-Adresse** - zur Kontoidentifikation und Kommunikation
- **Anzeigename** - zur Personalisierung Ihrer Erfahrung
- **Benutzer-ID (UID)** - eine eindeutige, von Firebase generierte Kennung
- **Profilfoto** (optional) - falls Sie eines hochladen
- **Land/Region** (optional) - für Lokalisierungseinstellungen
- **Sprachpräferenz** - für die App-Lokalisierung

Wenn Sie sich mit Google oder Apple anmelden:
- Wir erhalten Ihre E-Mail, Ihren Namen und Ihr Profilfoto von diesen Diensten
- Wir haben keinen Zugriff auf Ihr Google/Apple-Kontopasswort

### 1.2 Erinnerungsinhalte
Wir speichern die Inhalte, die Sie in Lifeline erstellen:

- **Textdaten:** Titel, Beschreibungen, Reflexionsnotizen, KVT-Schritte, emotionale Bewertungen
- **Mediendateien:** Fotos, Videos und Audionotizen
- **Zeitstempel:** Daten, wann Erinnerungen aufgetreten sind und erstellt wurden
- **Musikdaten:** Verknüpfte Spotify-Track-Informationen (Titel, Künstler, Album)
- **Standort-Tags** (falls Sie diese hinzufügen)
- **Wetterdaten** (falls in Ihre Erinnerungen integriert)
- **Personen-Tags** (Verbindungen zwischen Erinnerungen und Personen)

### 1.3 Verschlüsselte Inhalte
Wenn Sie die Ende-zu-Ende-Verschlüsselung mit einem Master-Passwort aktivieren:

- Sensible Felder werden auf Ihrem Gerät verschlüsselt, bevor sie an unsere Server gesendet werden
- Wir können auf Ihre verschlüsselten Inhalte nicht zugreifen oder diese lesen
- Verschlüsselte Inhalte umfassen Felder, die Sie als „privat" markieren
- **Wichtig:** Wir können verschlüsselte Daten nicht wiederherstellen, wenn Sie Ihr Master-Passwort vergessen

### 1.4 Geräte- und Nutzungsdaten
Wir sammeln automatisch:

- **Geräteinformationen:** Gerätemodell, Betriebssystemversion, eindeutige Gerätekennungen
- **App-Nutzungsdaten:** verwendete Funktionen, besuchte Bildschirme, App-Leistungsmetriken
- **Absturzberichte:** technische Daten, wenn die App abstürzt oder auf Fehler stößt
- **Analysedaten:** anonymisierte Nutzungsmuster zur Verbesserung der App

Diese Daten werden gesammelt durch:
- Firebase Analytics
- Firebase Crashlytics
- Firebase Performance Monitoring

### 1.5 Lokale Daten
Auf Ihrem Gerät gespeicherte Daten:

- **Isar-Datenbank:** lokaler Cache Ihrer Erinnerungen für Offline-Zugriff und schnellere Leistung
- **Mediendateien:** Fotos, Videos und Audiodateien in App-spezifischen Verzeichnissen gespeichert
- **Miniaturansichten:** komprimierte Versionen von Bildern für schnelle Anzeige
- **Einstellungen:** App-Einstellungen und Konfiguration

### 1.6 Benachrichtigungsdaten
Wenn Sie Benachrichtigungen aktivieren:

- **Erinnerungszeitpläne:** Daten und Zeiten für Reflexionsaufforderungen
- **Push-Benachrichtigungs-Token:** um Benachrichtigungen an Ihr Gerät zu senden

### 1.7 Abonnementinformationen
Für Premium-Abonnenten:

- **Kaufbelege:** Transaktions-IDs vom App Store oder Google Play
- **Abonnementstatus:** aktiv, abgelaufen oder gekündigt
- **Kaufdatum und Verlängerungsdatum**

Wir sammeln oder speichern Ihre Zahlungskarteninformationen nicht. Alle Zahlungen werden von Apple oder Google verarbeitet.

## 2. Wie wir Ihre Informationen verwenden

Wir verwenden Ihre Daten, um:

### 2.1 Den Dienst bereitzustellen
- Ihre Erinnerungen über Geräte hinweg zu speichern und zu synchronisieren
- Ihre Inhalte in der Zeitleisten-Visualisierung anzuzeigen
- Mediendateien zu verarbeiten und zu komprimieren
- Such- und Organisationsfunktionen zu ermöglichen
- Erinnerungen und Benachrichtigungen zu senden

### 2.2 Den Dienst zu verbessern
- App-Nutzungsmuster zu analysieren
- Fehler und Abstürze zu identifizieren und zu beheben
- Leistung und Ladezeiten zu optimieren
- Neue Funktionen basierend auf Benutzerbedürfnissen zu entwickeln

### 2.3 Mit Ihnen zu kommunizieren
- Wichtige Kontobenachrichtigungen zu senden
- Auf Ihre Supportanfragen zu antworten
- Sie über Richtlinienänderungen zu informieren
- Informationen über neue Funktionen bereitzustellen (wenn Sie zustimmen)

### 2.4 Sicherheit zu gewährleisten
- Betrug oder Missbrauch zu erkennen und zu verhindern
- Unsere Nutzungsbedingungen durchzusetzen
- Vor unbefugtem Zugriff zu schützen

### 2.5 Rechtlichen Verpflichtungen nachzukommen
- Auf rechtliche Anfragen und Gerichtsbeschlüsse zu reagieren
- Geltende Gesetze und Vorschriften einzuhalten

## 3. Datenspeicherung und Sicherheit

### 3.1 Cloud-Speicher
Ihre Daten werden auf Firebase-Servern gespeichert, die von Google Cloud Platform betrieben werden:

- **Standort:** Multi-Region-Speicher für Zuverlässigkeit
- **Sicherheit:** Branchenübliche Verschlüsselung während der Übertragung (TLS) und im Ruhezustand
- **Zugriffskontrolle:** Strenge Firestore-Sicherheitsregeln stellen sicher, dass nur Sie auf Ihre Daten zugreifen können
- **Backups:** Automatische Backups für Notfallwiederherstellung

### 3.2 Ende-zu-Ende-Verschlüsselung
Wenn Sie die Verschlüsselung aktivieren:

- Ihr Master-Passwort wird verwendet, um Verschlüsselungsschlüssel zu generieren
- Die Verschlüsselung wird auf Ihrem Gerät durchgeführt, bevor Daten an Server gesendet werden
- Wir verwenden AES-256-Verschlüsselung mit sicherer Schlüsselableitung (PBKDF2)
- Nur Sie können Ihre sensiblen Daten entschlüsseln

### 3.3 Biometrische Authentifizierung
Wenn Sie Face ID oder Touch ID aktivieren:

- Biometrische Daten verlassen niemals Ihr Gerät
- Wir haben keinen Zugriff auf Ihre Fingerabdrücke oder Gesichtsdaten
- Biometrie wird nur verwendet, um die App lokal zu entsperren

### 3.4 Sicherheitsmaßnahmen
Wir implementieren mehrere Sicherheitsebenen:

- Firebase App Check zur Verhinderung unbefugten API-Zugriffs
- SSL/TLS-Verschlüsselung für alle Netzwerkkommunikationen
- Regelmäßige Sicherheitsaudits und Updates
- Ratenbegrenzung zur Verhinderung von Missbrauch

## 4. Datenweitergabe und Dienste von Drittanbietern

### 4.1 Wir verkaufen Ihre Daten nicht
Wir werden Ihre persönlichen Informationen niemals an Dritte zu Marketingzwecken verkaufen, vermieten oder handeln.

### 4.2 Von uns verwendete Drittanbieterdienste

**Firebase (Google Cloud)**
- Zweck: Authentifizierung, Datenbank, Speicher, Analyse, Absturzberichte
- Geteilte Daten: Kontoinformationen, Erinnerungsinhalte, Nutzungsdaten
- Datenschutzrichtlinie: https://firebase.google.com/support/privacy

**Spotify**
- Zweck: Suche nach Musiktiteln zur Verknüpfung mit Erinnerungen
- Geteilte Daten: Nur Suchanfragen (keine persönlichen Daten)
- Datenschutzrichtlinie: https://www.spotify.com/privacy

**Apple App Store / Google Play**
- Zweck: Zahlungsabwicklung für Premium-Abonnements
- Geteilte Daten: Kaufinformationen
- Datenschutzrichtlinien: Apple und Google

**Bildverarbeitungsdienste**
- Zweck: Bilder komprimieren und Miniaturansichten erstellen
- Verarbeitung: Lokal auf Ihrem Gerät durchgeführt
- Keine Daten werden mit externen Diensten geteilt

### 4.3 Wann wir Daten weitergeben können

Wir können Ihre Informationen nur unter diesen begrenzten Umständen weitergeben:

- **Mit Ihrer Zustimmung:** Wenn Sie die Weitergabe ausdrücklich autorisieren
- **Rechtliche Anforderungen:** Zur Einhaltung von Gesetzen, Gerichtsbeschlüssen oder rechtlichen Verfahren
- **Sicherheit:** Zum Schutz der Rechte, des Eigentums oder der Sicherheit der Benutzer
- **Unternehmensübertragungen:** Im Falle von Fusion, Übernahme oder Verkauf (mit Benachrichtigung an Sie)

## 5. Datenaufbewahrung

### 5.1 Aktive Konten
Wir bewahren Ihre Daten auf, solange Ihr Konto aktiv ist, um den Dienst bereitzustellen.

### 5.2 Nach Kontolöschung
Wenn Sie Ihr Konto löschen:

- **Sofort:** Ihre Daten werden zur Löschung markiert und sind für Sie nicht mehr zugänglich
- **Innerhalb von 30 Tagen:** Dauerhaft von aktiven Servern gelöscht
- **Innerhalb von 90 Tagen:** Aus allen Backups entfernt
- **Anonymisierte Analysen:** Können unbegrenzt zur Serviceverbesserung aufbewahrt werden

### 5.3 Rechtliche Aufbewahrung
Wir können bestimmte Daten länger aufbewahren, wenn dies gesetzlich vorgeschrieben ist oder zur Beilegung von Streitigkeiten erforderlich ist.

## 6. Ihre Rechte und Wahlmöglichkeiten

### 6.1 Zugriff und Export
Sie können:

- Alle Ihre Daten in der App anzeigen
- Ihre Erinnerungen und Mediendateien exportieren
- Eine Kopie Ihrer persönlichen Daten anfordern

### 6.2 Korrektur und Aktualisierung
Sie können aktualisieren:

- Anzeigename
- E-Mail-Adresse
- Profilfoto
- Sprach- und Länderpräferenzen

### 6.3 Löschung
Sie können:

- Einzelne Erinnerungen löschen
- Ihr gesamtes Konto löschen (löscht alle Daten dauerhaft)
- Datenlöschung durch Kontaktaufnahme mit uns anfordern

### 6.4 Opt-Out-Optionen
Sie können deaktivieren:

- **Benachrichtigungen:** In App-Einstellungen oder Geräteeinstellungen
- **Analysen:** Durch Aktivierung der Verschlüsselung (begrenzt einige Analysen)
- **Biometrisches Entsperren:** In App-Sicherheitseinstellungen

### 6.5 Do Not Track
Wir respektieren Do Not Track-Signale. Wenn Ihr Browser DNT sendet, werden wir Ihre Aktivität nicht verfolgen.

## 7. Datenschutz von Kindern

Lifeline ist für Benutzer ab 13 Jahren gedacht. Wir sammeln wissentlich keine persönlichen Informationen von Kindern unter 13 Jahren. Wenn wir feststellen, dass wir Daten von einem Kind unter 13 Jahren gesammelt haben, werden wir diese sofort löschen.

Wenn Sie ein Elternteil oder Erziehungsberechtigter sind und glauben, dass Ihr Kind uns persönliche Informationen zur Verfügung gestellt hat, kontaktieren Sie uns bitte.

## 8. Internationale Datenübertragungen

Ihre Daten können auf Server übertragen und dort gespeichert werden, die sich außerhalb Ihres Wohnsitzlandes befinden. Durch die Nutzung von Lifeline stimmen Sie diesen Übertragungen zu. Wir stellen sicher, dass angemessene Schutzmaßnahmen zum Schutz Ihrer Daten vorhanden sind.

## 9. DSGVO-Rechte (für EU-Nutzer)

Wenn Sie sich in der Europäischen Union befinden, haben Sie zusätzliche Rechte gemäß der Datenschutz-Grundverordnung (DSGVO):

### 9.1 Ihre Rechte
- **Auskunftsrecht:** Kopien Ihrer personenbezogenen Daten anfordern
- **Recht auf Berichtigung:** Ungenaue oder unvollständige Daten korrigieren
- **Recht auf Löschung:** Löschung Ihrer Daten anfordern („Recht auf Vergessenwerden")
- **Recht auf Einschränkung der Verarbeitung:** Einschränkung der Verwendung Ihrer Daten
- **Recht auf Datenübertragbarkeit:** Ihre Daten in einem portablen Format erhalten
- **Widerspruchsrecht:** Widerspruch gegen die Verarbeitung Ihrer Daten
- **Recht auf Widerruf der Einwilligung:** Einwilligung jederzeit widerrufen

### 9.2 Rechtsgrundlage für die Verarbeitung
Wir verarbeiten Ihre Daten auf Grundlage von:

- **Einwilligung:** Sie stimmen unseren Datenpraktiken zu
- **Vertrag:** Erforderlich zur Bereitstellung des Dienstes
- **Berechtigte Interessen:** Verbesserung und Sicherung des Dienstes

### 9.3 Datenschutzbeauftragter
Für DSGVO-bezogene Anfragen kontaktieren Sie uns unter: founder@theplacewelive.org

## 10. CCPA-Rechte (für kalifornische Nutzer)

Wenn Sie in Kalifornien wohnen, haben Sie Rechte gemäß dem California Consumer Privacy Act (CCPA):

- **Recht auf Auskunft:** Welche persönlichen Informationen wir sammeln und wie wir sie verwenden
- **Recht auf Löschung:** Löschung Ihrer persönlichen Informationen anfordern
- **Recht auf Opt-out:** Opt-out vom Verkauf persönlicher Informationen (wir verkaufen keine Daten)
- **Recht auf Nichtdiskriminierung:** Gleicher Service unabhängig von Datenschutzentscheidungen

## 11. Datensicherheitsvorfälle

Im Falle einer Datenschutzverletzung, die Ihre persönlichen Informationen betrifft:

- Wir werden Sie innerhalb von 72 Stunden nach Entdeckung der Verletzung benachrichtigen
- Wir werden Details darüber geben, welche Daten betroffen waren
- Wir werden Schritte beschreiben, die wir unternehmen, um die Verletzung zu beheben
- Wir werden Maßnahmen empfehlen, die Sie zum Schutz ergreifen können

## 12. Änderungen dieser Datenschutzerklärung

Wir können diese Datenschutzerklärung von Zeit zu Zeit aktualisieren. Wir werden Sie über wesentliche Änderungen informieren durch:

- Veröffentlichung der aktualisierten Richtlinie in der App
- Versenden einer E-Mail-Benachrichtigung an Ihre registrierte E-Mail
- Anzeige einer In-App-Benachrichtigung

Ihre fortgesetzte Nutzung von Lifeline nach Änderungen zeigt die Annahme der aktualisierten Richtlinie an.

## 13. Kontakt

Wenn Sie Fragen, Bedenken oder Anfragen bezüglich dieser Datenschutzerklärung oder Ihrer Daten haben, kontaktieren Sie uns bitte:

**E-Mail:** founder@theplacewelive.org

**Antwortzeit:** Wir bemühen uns, alle Anfragen innerhalb von 7 Werktagen zu beantworten.

## 14. Transparenzbericht

Wir sind der Transparenz verpflichtet. Auf Anfrage können wir Informationen bereitstellen über:

- Anzahl der von Behörden erhaltenen Datenanfragen
- Arten der angeforderten Daten
- Unsere Antworten auf solche Anfragen

---

*Diese Datenschutzerklärung wurde zuletzt am 2. Oktober 2025 aktualisiert. Frühere Versionen sind auf Anfrage erhältlich.*

**Durch die Nutzung von Lifeline bestätigen Sie, dass Sie diese Datenschutzerklärung gelesen und verstanden haben und unseren Datenpraktiken wie beschrieben zustimmen.**
