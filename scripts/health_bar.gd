extends Control
var hp: float = 100.0:
 set(value):
  hp = clampf(value,0,100)
  queue_redraw()
var shield: float = 50.0:
 set(value):
  shield = clampf(value,0,50)
  queue_redraw()
func _ready() -> void:
 custom_minimum_size = Vector2(355,100)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var dark := Color("#151c34")
 var border := Color("#776ab2")
 var lilac := Color("#bd91ed")
 draw_rect(Rect2(18,17,316,63),Color("#080b19",0.65))
 draw_rect(Rect2(21,16,309,55),border)
 draw_rect(Rect2(24,19,303,49),dark)
 draw_rect(Rect2(78,29,233,27),Color("#252d4e"))
 draw_rect(Rect2(79,30,231*hp/100.0,25),Color("#a751b4"))
 draw_rect(Rect2(79,30,231*hp/100.0,6),Color("#e4a1e9"))
 draw_rect(Rect2(79,52,231*hp/100.0,3),Color("#773c95"))
 draw_circle(Vector2(47,43),35,Color("#0d1226"))
 draw_circle(Vector2(47,42),31,border)
 draw_circle(Vector2(47,42),27,dark)
 var heart := PackedVector2Array([Vector2(47,60),Vector2(29,44),Vector2(29,36),Vector2(35,31),Vector2(42,33),Vector2(47,38),Vector2(52,33),Vector2(59,31),Vector2(65,36),Vector2(65,44)])
 draw_colored_polygon(heart,lilac)
 draw_rect(Rect2(79,76,231,7),Color("#18233e"))
 draw_rect(Rect2(79,76,231*shield/50.0,7),Color("#6fcbf7"))
