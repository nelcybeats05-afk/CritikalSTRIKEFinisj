extends Control
func _ready() -> void:
 var bg := ColorRect.new()
 bg.color = Color("#101528")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 var side := ColorRect.new()
 side.color = Color("#252344")
 side.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 side.anchor_left = 0.0
 side.anchor_right = 0.43
 add_child(side)
 var v := VBoxContainer.new()
 v.set_anchors_preset(Control.PRESET_CENTER_LEFT)
 v.position = Vector2(65,145)
 v.custom_minimum_size = Vector2(420,420)
 add_child(v)
 var title := Label.new()
 title.text = "CRITIKAL\nSTRIKE"
 title.add_theme_font_size_override("font_size",56)
 title.add_theme_color_override("font_color",Color("#e8dcff"))
 v.add_child(title)
 var subtitle := Label.new()
 subtitle.text = "TACTICAL SHOOTER  /  3D TRAINING BUILD"
 subtitle.add_theme_color_override("font_color",Color("#b3a9d4"))
 v.add_child(subtitle)
 for item in ["SPIELEN  /  TRAINING", "WAFFEN & SKINS (IM SPIEL: P)", "MESSER (IM SPIEL: K)", "BEENDEN"]:
  var button := Button.new()
  button.text = item
  button.custom_minimum_size = Vector2(390,57)
  v.add_child(button)
  button.pressed.connect(func():
   if item.begins_with("SPIELEN"): get_tree().change_scene_to_file("res://scenes/main.tscn")
   elif item == "BEENDEN": get_tree().quit()
   else: button.text = "IM TRAINING VERFÜGBAR"
  )
 var hint := Label.new()
 hint.text = "DARK NAVY  /  PURPLE  /  STEEL     •     VERSION 1.2"
 hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
 hint.position = Vector2(-470,-60)
 hint.add_theme_color_override("font_color",Color("#9f9ac4"))
 add_child(hint)
