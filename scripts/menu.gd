extends Control

const BG := Color("#0e1426")
const PANEL := Color("#252744")
const ACCENT := Color("#a78bfa")

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var bg := ColorRect.new()
 bg.color = BG
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(bg)
 var side := ColorRect.new()
 side.color = PANEL
 side.anchor_right = 0.46
 side.anchor_bottom = 1.0
 side.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(side)
 var center := CenterContainer.new()
 center.anchor_left = 0.02
 center.anchor_right = 0.44
 center.anchor_bottom = 1.0
 add_child(center)
 var v := VBoxContainer.new()
 v.add_theme_constant_override("separation", 14)
 v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 center.add_child(v)
 var title := Label.new()
 title.text = "CRITIKAL\nSTRIKE"
 title.add_theme_font_size_override("font_size", 52)
 title.add_theme_color_override("font_color", Color("#e7dcff"))
 v.add_child(title)
 var sub := Label.new()
 sub.text = "TACTICAL FPS  •  TRAINING ALPHA 1.3"
 sub.add_theme_font_size_override("font_size", 15)
 sub.add_theme_color_override("font_color", ACCENT)
 v.add_child(sub)
 for entry in ["SPIELEN / TRAINING", "STEUERUNG", "BEENDEN"]:
  var b := Button.new()
  b.text = entry
  b.custom_minimum_size = Vector2(0, 56)
  b.add_theme_font_size_override("font_size", 18)
  v.add_child(b)
  b.pressed.connect(_menu_action.bind(entry))
 var right := CenterContainer.new()
 right.anchor_left = 0.47
 right.anchor_right = 1.0
 right.anchor_bottom = 1.0
 add_child(right)
 var info := Label.new()
 info.text = "DISTRICT-01 / TRAINING\n\n3D COMBAT  •  3 WEAPONS\n3 KNIVES  •  5 SKINS\nGRENADE TRAJECTORY  •  BOTS\n\nPRESS PLAY TO DEPLOY"
 info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 info.add_theme_font_size_override("font_size", 21)
 info.add_theme_color_override("font_color", Color("#c4b5fd"))
 right.add_child(info)

func _menu_action(entry: String) -> void:
 match entry:
  "SPIELEN / TRAINING": get_tree().change_scene_to_file("res://scenes/main.tscn")
  "STEUERUNG": _show_controls()
  "BEENDEN": get_tree().quit()

func _show_controls() -> void:
 var popup := AcceptDialog.new()
 popup.title = "CritikalSTRIKE - Steuerung"
 popup.dialog_text = "WASD Bewegen | Maus Zielen | Shift Sprint | Leertaste Springen\n1 KR-47 | 2 MR-4 | 3 Heavy Eagle | 4 Messer\nLinksklick Schießen | Rechtsklick Zoom | R Nachladen\nK Messer wechseln | P Skin wechseln | G Granate ausrüsten\nLinksklick Granate werfen | Q Dash | E Heilung | ESC Pause"
 add_child(popup)
 popup.popup_centered(Vector2i(720, 260))
 popup.confirmed.connect(popup.queue_free)
