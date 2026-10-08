# CritikalSTRIKE – Alpha 1.3 (Godot 4.4.1)

Eigenständiger 3D-FPS-Trainingsprototyp. Keine Original-Assets aus Counter-Strike oder Valorant.

## Windows direkt spielen
GitHub → Actions → Build Windows Game → letzter erfolgreicher Lauf → Artifacts → `CritikalSTRIKE-Windows` herunterladen. ZIP entpacken; `CritikalSTRIKE.exe` starten. Die `.pck`-Datei muss neben der EXE bleiben. Godot muss auf dem Spieler-PC nicht installiert sein.

## GitHub-Repository
Alle Dateien **inklusive verstecktem `.github/workflows/windows.yml`** in das Repository hochladen. Unter Actions den Workflow starten. Dieser prüft den Godot-Import, exportiert EXE + PCK und veröffentlicht beides als Artefakt.

## Steuerung
- WASD: bewegen; Maus: umsehen; Shift: sprinten; Leertaste: springen
- Linksklick: schießen / Granate werfen / Messerangriff; Rechtsklick: Zoom (bei Schusswaffen)
- 1: KR-47; 2: MR-4; 3: Heavy Eagle; 4: Messer
- R: nachladen; K: Messerform wechseln; P: Skinfarbe wechseln
- G: Granate in Hand nehmen / wegstecken (Flugbahn + Radius sichtbar); Linksklick: werfen
- Q: Dash; E: Heilung; Esc: Pausenmenü

## Implementiert
- Responsives dunkelblau-lila Menü und skalierbares Fenster
- Prozedurale 3D-Trainingsarena mit Gebäuden, Deckungen, Lichtern und Trainingswellen
- Drei Waffenprototypen, eigene Magazine, Hitscan-Schaden, Zoom, Nachladen
- Drei vereinfachte Messerformen (einschließlich Karambit), Nahkampfangriff, fünf Material-Skins
- Sichtbare 3D-Granate in der Hand, hellblaue Flugbahn, Radiusvorschau, geworfene Granate, Explosion
- Einfache Bots mit Sichtlinienprüfung und reduziertem Schaden
- Herz-HP-HUD und Schild, Dash, Heilung, Pause

## Noch nicht enthalten
- Online-Multiplayer, Kaufmenü, Bombe, echtes Matchmaking, hochwertige animierte Modelle, professionelle Soundbibliothek und detaillierte 3D-Messermodelle
- Dies ist kein fertig produzierter AAA-Shooter.

## Teststatus
Dateistruktur, YAML, GDScript-Einrückung und Projektverweise können lokal geprüft werden. **Ein tatsächlicher Godot-Start und Windows-Spieltest waren in dieser Umgebung nicht möglich.** Der GitHub-Workflow ist die verbindliche Exportprüfung; nach dem Download sollte ein Spieltest durchgeführt werden.
