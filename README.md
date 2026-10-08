# CritikalSTRIKE v1.2 — 3D Training Prototype

Godot 4.4.1 / GDScript / Windows. Eigenständige Low-Poly-3D-Trainingsarena, **kein vollständiger Multiplayer-Shooter**.

## Start
1. ZIP entpacken, `project.godot` in Godot 4.4.1 importieren.
2. Mit F5 starten, im Menü SPIELEN / TRAINING wählen.
3. GitHub: Inhalt des entpackten Ordners ins Repository hochladen; unter Actions den Windows-Workflow starten. Das Build-Artefakt herunterladen und entpacken.

## Steuerung
- WASD bewegen, Maus umsehen, Shift schneller laufen, Space springen.
- Linke Maustaste schießen, rechte Maustaste zielen/Zoom, R nachladen.
- 1 KR-47, 2 MR-4, 3 Heavy Eagle, 4 Messer; K Messertyp wechseln.
- P Waffenskin wechseln (5 Farbvarianten); G Granate in die Hand nehmen und erneut G zum Werfen. Hellblaue Flugkurve und Radiusvorschau.
- Q Dash, E Heilung, Esc Pausenmenü; Enter Neustart nach Tod.

## Umfang / Einschränkungen
- Eigene prozedurale Low-Poly-3D-Waffen und drei Messerformen, keine geschützten Original-Assets.
- Farb-Skins statt aufwendiger Textur-Skins; einfache Gegner-KI mit verringerter Geschwindigkeit/Schaden und Feuerfrequenz.
- Granatenflugbahn ist eine Schätzung und kann bei Abprallern von der tatsächlichen Flugbahn abweichen.
- Noch kein echtes 5v5, LAN/Online, Bombenmodus, Accountsystem oder hochwertige Animationen.
- Projektdateien statisch geprüft; **Godot-Laufzeittest und Windows-Export hier nicht ausgeführt**. Falls GitHub Actions Fehler meldet, Build-Log prüfen.


## Windows herunterladen (GitHub Actions)
Actions > Build Windows Game > Run workflow. Nach erfolgreichem Lauf unter Artifacts `CritikalSTRIKE-Windows` herunterladen, ZIP entpacken und `CritikalSTRIKE.exe` starten. Die `.pck` muss neben der `.exe` bleiben. Der Workflow meldet einen Fehler, wenn die EXE oder PCK fehlt.
