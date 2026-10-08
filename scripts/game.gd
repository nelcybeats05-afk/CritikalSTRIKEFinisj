extends Node3D

const WALK_SPEED := 7.0
const SPRINT_SPEED := 10.5
const GRAVITY := 24.0
const JUMP_SPEED := 8.0
const ARENA := 42.0

var player: CharacterBody3D
var head: Node3D
var camera: Camera3D
var weapon_mesh: Node3D
var ui: CanvasLayer
var hud: Label
var health_bar: Control
var shield := 50
var center_message: Label
var health := 100
var rifle_ammo := 30
var pistol_ammo := 12
var rifle_reserve := 120
var pistol_reserve := 48
var weapon := 0
var reload_timer := 0.0
var fire_timer := 0.0
var dash_cooldown := 0.0
var heal_cooldown := 0.0
var kills := 0
var wave := 1
var enemies: Array[CharacterBody3D] = []
var enemy_cooldowns: Dictionary = {}
var dead := false
var elapsed := 0.0
var gun_flash: OmniLight3D
var flash_timer := 0.0
var rng := RandomNumberGenerator.new()
var scoped := false
var grenade_held := false
var grenade_count := 3
var grenade_preview: MeshInstance3D
var grenade_radius: MeshInstance3D
var grenade_velocity := Vector3.ZERO
var grenade_body: Node3D
var grenade_fuse := 0.0
var smoke_effects: Array[Node3D] = []
var smoke_timers: Dictionary = {}
var knife_type := 0
var skin_index := 0
var paused_menu: Control
var status_label: Label
const SKINS := [Color("#34465e"), Color("#9a3f79"), Color("#5c46ad"), Color("#1d9caa"), Color("#b88d43")]
const SKIN_NAMES := ["STEEL", "ROSE", "NEBULA", "CYAN", "GOLD"]
const KNIVES := ["TACTICAL", "KARAMBIT", "TANTO"]

func _ready() -> void:
 rng.randomize()
 Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 build_world()
 build_player()
 build_ui()
 build_grenade_preview()
 spawn_wave()
 show_message("CRITIKALSTRIKE  |  TRAINING ARENA", 2.8)

func mat(color: Color, metallic := 0.0) -> StandardMaterial3D:
 var m := StandardMaterial3D.new()
 m.albedo_color = color
 m.metallic = metallic
 m.roughness = 0.65
 return m

func box_mesh(parent: Node3D, pos: Vector3, size: Vector3, color: Color, collision := false) -> Node3D:
 var root: Node3D
 if collision:
  var body := StaticBody3D.new()
  parent.add_child(body)
  body.position = pos
  var shape := CollisionShape3D.new()
  var s := BoxShape3D.new()
  s.size = size
  shape.shape = s
  body.add_child(shape)
  root = body
 else:
  root = Node3D.new()
  parent.add_child(root)
  root.position = pos
 var mesh := MeshInstance3D.new()
 var bm := BoxMesh.new()
 bm.size = size
 mesh.mesh = bm
 mesh.material_override = mat(color)
 root.add_child(mesh)
 return root

func build_world() -> void:
 var env := WorldEnvironment.new()
 var environment := Environment.new()
 environment.background_mode = Environment.BG_COLOR
 environment.background_color = Color("111827")
 environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 environment.ambient_light_color = Color("9aaec4")
 environment.ambient_light_energy = 0.75
 env.environment = environment
 add_child(env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-55, 35, 0)
 sun.light_energy = 1.5
 add_child(sun)
 box_mesh(self, Vector3(0,-0.5,0), Vector3(ARENA * 2,1,ARENA * 2), Color("283848"), true)
 for x in range(-40,41,8):
  box_mesh(self, Vector3(x,0.015,0), Vector3(0.06,0.03,82), Color("344a58"))
 for z in range(-40,41,8):
  box_mesh(self, Vector3(0,0.02,z), Vector3(82,0.03,0.06), Color("344a58"))
 for side in [-1,1]:
  box_mesh(self, Vector3(side * ARENA,3,0), Vector3(1,6,85), Color("182635"), true)
  box_mesh(self, Vector3(0,3,side * ARENA), Vector3(85,6,1), Color("182635"), true)
 for i in range(24):
  var x := rng.randf_range(-32,32)
  var z := rng.randf_range(-32,32)
  if Vector2(x,z).length() < 11:
   continue
  var height := rng.randf_range(1.8,5.5)
  var size := Vector3(rng.randf_range(2.5,6),height,rng.randf_range(2.5,6))
  box_mesh(self, Vector3(x,height / 2,z), size, Color("485b6b") if i % 3 else Color("b2684c"), true)
  box_mesh(self, Vector3(x,height + 0.08,z), Vector3(size.x + 0.2,0.16,size.z + 0.2), Color("29b6ad"))
 for i in range(4):
  box_mesh(self, Vector3(-17 + i * 11,0.08,-17), Vector3(5,0.16,0.2), Color("27c8b5"))

func build_player() -> void:
 player = CharacterBody3D.new()
 player.name = "Player"
 player.position = Vector3(0,2,12)
 add_child(player)
 var shape := CollisionShape3D.new()
 var capsule := CapsuleShape3D.new()
 capsule.radius = 0.38
 capsule.height = 1.8
 shape.shape = capsule
 player.add_child(shape)
 head = Node3D.new()
 head.position.y = 0.67
 player.add_child(head)
 camera = Camera3D.new()
 camera.current = true
 camera.fov = 80
 head.add_child(camera)
 weapon_mesh = Node3D.new()
 camera.add_child(weapon_mesh)
 weapon_mesh.position = Vector3(0.36,-0.35,-0.75)
 build_gun()
 gun_flash = OmniLight3D.new()
 gun_flash.light_color = Color("ffcb70")
 gun_flash.light_energy = 0
 gun_flash.omni_range = 3
 gun_flash.position = Vector3(0,0,-1.5)
 camera.add_child(gun_flash)

func build_gun() -> void:
 for c in weapon_mesh.get_children():
  c.queue_free()
 var accent := SKINS[skin_index]
 if weapon == 2:
  box_mesh(weapon_mesh, Vector3(0,-0.08,-0.04), Vector3(0.12,0.17,0.26), Color("#161c2b"))
  if knife_type == 1:
   var blade: Node3D = box_mesh(weapon_mesh, Vector3(-0.05,0.05,-0.31), Vector3(0.06,0.075,0.5), accent)
   blade.rotation.y = -0.32
   var ring := CSGTorus3D.new()
   ring.inner_radius = 0.065
   ring.outer_radius = 0.11
   ring.material = mat(accent,0.6)
   ring.position = Vector3(0,-0.09,0.12)
   ring.rotation.x = PI / 2.0
   weapon_mesh.add_child(ring)
  elif knife_type == 2:
   box_mesh(weapon_mesh, Vector3(0,0.04,-0.33), Vector3(0.075,0.07,0.5), accent)
   box_mesh(weapon_mesh, Vector3(0,0.04,-0.09), Vector3(0.19,0.035,0.06), Color("#202532"))
  else:
   box_mesh(weapon_mesh, Vector3(0,0.03,-0.33), Vector3(0.075,0.06,0.52), accent)
 elif weapon == 3:
  box_mesh(weapon_mesh, Vector3(0,0,-0.1), Vector3(0.16,0.19,0.42), Color("#28334a"))
  box_mesh(weapon_mesh, Vector3(0,0.02,-0.32), Vector3(0.12,0.12,0.2), accent)
 elif weapon == 0 or weapon == 1:
  box_mesh(weapon_mesh, Vector3.ZERO, Vector3(0.18,0.22,0.8), accent)
  box_mesh(weapon_mesh, Vector3(0,0.04,-0.53), Vector3(0.075,0.075,0.55), Color("#667688"))
  box_mesh(weapon_mesh, Vector3(0,-0.22,-0.1), Vector3(0.12,0.3,0.18), Color("#26313c"))
  box_mesh(weapon_mesh, Vector3(0,0.16,-0.12), Vector3(0.07,0.12,0.2), Color("#9ca5bf"))
 else:
  box_mesh(weapon_mesh, Vector3.ZERO, Vector3(0.14,0.18,0.48), accent)
  box_mesh(weapon_mesh, Vector3(0,-0.19,0.12), Vector3(0.12,0.28,0.14), Color("#465361"))
 weapon_mesh.position = Vector3(0.36,-0.35,-0.75)

func build_grenade_preview() -> void:
 grenade_preview = MeshInstance3D.new()
 add_child(grenade_preview)
 grenade_radius = MeshInstance3D.new()
 add_child(grenade_radius)
 grenade_preview.material_override = mat(Color("#82ddff"))
 grenade_radius.material_override = mat(Color("#75caff"))
 grenade_preview.visible = false
 grenade_radius.visible = false

func line_mesh(points: Array[Vector3]) -> ImmediateMesh:
 var mesh := ImmediateMesh.new()
 mesh.surface_begin(Mesh.PRIMITIVE_LINES)
 for i in range(points.size()-1):
  mesh.surface_add_vertex(points[i])
  mesh.surface_add_vertex(points[i+1])
 mesh.surface_end()
 return mesh

func trajectory() -> Array[Vector3]:
 var points: Array[Vector3] = []
 var origin := camera.global_position - camera.global_transform.basis.z * 0.6
 var velocity := -camera.global_transform.basis.z * 18.0 + Vector3.UP * 3.0
 var dt := 0.065
 var gravity := Vector3.DOWN * 18.0
 var exclude: Array[RID] = [player.get_rid()]
 for i in range(38):
  points.append(origin)
  var next := origin + velocity * dt + gravity * (0.5 * dt * dt)
  var query := PhysicsRayQueryParameters3D.create(origin,next)
  query.exclude = exclude
  var hit := get_world_3d().direct_space_state.intersect_ray(query)
  if not hit.is_empty():
   points.append(hit["position"])
   break
  origin = next
  velocity += gravity * dt
 return points

func update_grenade_preview() -> void:
 grenade_preview.visible = grenade_held and grenade_count > 0
 grenade_radius.visible = grenade_preview.visible
 if not grenade_preview.visible: return
 var pts := trajectory()
 grenade_preview.mesh = line_mesh(pts)
 var ring: Array[Vector3] = []
 var end := pts[pts.size()-1]
 for i in range(49):
  var a := TAU * float(i) / 48.0
  ring.append(end + Vector3(cos(a)*4.0,0.06,sin(a)*4.0))
 grenade_radius.mesh = line_mesh(ring)

func throw_grenade() -> void:
 if not grenade_held or grenade_count <= 0: return
 grenade_held = false
 grenade_count -= 1
 var pts := trajectory()
 grenade_body = Node3D.new()
 add_child(grenade_body)
 grenade_body.global_position = pts[0]
 var sphere := MeshInstance3D.new()
 var shape := SphereMesh.new()
 shape.radius = 0.16
 shape.height = 0.32
 sphere.mesh = shape
 sphere.material_override = mat(Color("#79baff"),0.6)
 grenade_body.add_child(sphere)
 grenade_velocity = -camera.global_transform.basis.z * 18.0 + Vector3.UP * 3.0
 grenade_fuse = 2.1
 show_message("GRENADE THROWN",0.7)

func update_grenade(delta: float) -> void:
 if not is_instance_valid(grenade_body): return
 grenade_fuse -= delta
 var start := grenade_body.global_position
 var next := start + grenade_velocity * delta + Vector3.DOWN * 9.0 * delta * delta
 var query := PhysicsRayQueryParameters3D.create(start,next)
 query.exclude = [player.get_rid()]
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty():
  grenade_body.global_position = hit["position"]
  grenade_velocity = grenade_velocity.bounce(hit["normal"]) * 0.42
 else:
  grenade_body.global_position = next
  grenade_velocity.y -= 18.0 * delta
 if grenade_fuse <= 0:
  var epicenter := grenade_body.global_position
  for enemy in enemies.duplicate():
   if is_instance_valid(enemy) and enemy.global_position.distance_to(epicenter) < 4.0:
    damage_enemy(enemy,65)
  var blast := MeshInstance3D.new()
  var sphere := SphereMesh.new()
  sphere.radius = 4.0
  sphere.height = 8.0
  blast.mesh = sphere
  var m := mat(Color(0.35,0.68,1.0,0.17))
  m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  blast.material_override = m
  add_child(blast)
  blast.global_position = epicenter
  get_tree().create_timer(0.25).timeout.connect(func():
   if is_instance_valid(blast):
    blast.queue_free()
  )
  grenade_body.queue_free()
  grenade_body = null

func damage_enemy(target: CharacterBody3D, amount: int) -> void:
 if not enemies.has(target): return
 var hp: int = int(target.get_meta("hp")) - amount
 target.set_meta("hp",hp)
 if hp <= 0:
  enemies.erase(target)
  enemy_cooldowns.erase(target)
  target.queue_free()
  kills += 1
  show_message("ELIMINATED +100",0.6)

func toggle_zoom(value: bool) -> void:
 scoped = value and weapon < 3
 camera.fov = 48 if scoped else 80
 weapon_mesh.position = Vector3(0.17,-0.28,-0.72) if scoped else Vector3(0.36,-0.35,-0.75)


func build_ui() -> void:
 ui = CanvasLayer.new()
 add_child(ui)
 var layer := Control.new()
 layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
 ui.add_child(layer)
 health_bar = Control.new()
 health_bar.set_script(load("res://scripts/health_bar.gd"))
 health_bar.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
 health_bar.position = Vector2(24, -148)
 layer.add_child(health_bar)
 hud = Label.new()
 hud.add_theme_font_size_override("font_size", 21)
 hud.add_theme_color_override("font_color", Color("e5f7fa"))
 hud.position = Vector2(24,20)
 layer.add_child(hud)
 var crosshair := Label.new()
 crosshair.text = "+"
 crosshair.add_theme_font_size_override("font_size", 30)
 crosshair.add_theme_color_override("font_color", Color("45f4d7"))
 crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 crosshair.position = Vector2(-9,-19)
 layer.add_child(crosshair)
 center_message = Label.new()
 center_message.add_theme_font_size_override("font_size", 30)
 center_message.add_theme_color_override("font_color", Color("48e8d4"))
 center_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 center_message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
 center_message.position = Vector2(-350,105)
 center_message.custom_minimum_size = Vector2(700,60)
 layer.add_child(center_message)
 var help := Label.new()
 help.text = "WASD Move  |  SHIFT Sprint  |  SPACE Jump  |  LMB Shoot  |  R Reload  |  1/2 Weapon  |  Q Dash  |  E Heal  |  ESC Mouse"
 help.add_theme_font_size_override("font_size", 14)
 help.add_theme_color_override("font_color", Color("a5bac9"))
 help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
 help.position = Vector2(20,-38)
 layer.add_child(help)
 help.text = "WASD Move | SHIFT Sprint | SPACE Jump | LMB Fire | RMB Zoom | R Reload | 1-4 Weapons | K Knife | P Skin | G Hold/Throw Grenade | Q Dash | E Heal | ESC Pause"
 status_label = Label.new()
 status_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
 status_label.position = Vector2(-450,-105)
 status_label.add_theme_font_size_override("font_size",20)
 status_label.add_theme_color_override("font_color",Color("#c4b5fd"))
 layer.add_child(status_label)
 build_pause_menu()

func show_message(message: String, seconds: float = 1.5) -> void:
 center_message.text = message
 get_tree().create_timer(seconds).timeout.connect(func():
  if is_instance_valid(center_message) and center_message.text == message:
   center_message.text = ""
 )

func spawn_wave() -> void:
 for i in range(3 + wave * 2):
  var enemy := CharacterBody3D.new()
  enemy.name = "Bot"
  var angle := rng.randf_range(0,TAU)
  var distance := rng.randf_range(19,34)
  enemy.position = Vector3(cos(angle) * distance,1.0,sin(angle) * distance)
  add_child(enemy)
  var collision := CollisionShape3D.new()
  var cap := CapsuleShape3D.new()
  cap.radius = 0.45
  cap.height = 1.9
  collision.shape = cap
  enemy.add_child(collision)
  box_mesh(enemy, Vector3(0,0.05,0), Vector3(0.8,1.4,0.5), Color("e45764"))
  box_mesh(enemy, Vector3(0,0.9,0), Vector3(0.58,0.48,0.54), Color("f5aa80"))
  box_mesh(enemy, Vector3(0,1.0,-0.28), Vector3(0.6,0.14,0.07), Color("ff4569"))
  enemy.set_meta("hp", 100)
  enemies.append(enemy)
  enemy_cooldowns[enemy] = rng.randf_range(0.6,1.8)
 show_message("WAVE %d  |  ELIMINATE HOSTILES" % wave, 2.5)

func build_pause_menu() -> void:
 paused_menu = PanelContainer.new()
 paused_menu.visible = false
 paused_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 paused_menu.position = Vector2(-190,-175)
 paused_menu.custom_minimum_size = Vector2(380,350)
 ui.add_child(paused_menu)
 var v := VBoxContainer.new()
 paused_menu.add_child(v)
 var title := Label.new()
 title.text = "CRITIKALSTRIKE  /  PAUSE"
 title.add_theme_font_size_override("font_size",25)
 v.add_child(title)
 for entry in ["WEITERSPIELEN", "SKIN WECHSELN", "MESSER WECHSELN", "ZUM HAUPTMENÜ"]:
  var btn := Button.new()
  btn.text = entry
  v.add_child(btn)
  btn.pressed.connect(func():
   match entry:
    "WEITERSPIELEN": set_paused(false)
    "SKIN WECHSELN": skin_index = (skin_index+1)%SKINS.size(); build_gun()
    "MESSER WECHSELN": knife_type = (knife_type+1)%KNIVES.size(); build_gun()
    "ZUM HAUPTMENÜ": get_tree().change_scene_to_file("res://scenes/menu.tscn")
  )

func set_paused(value: bool) -> void:
 paused_menu.visible = value
 Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not dead and not paused_menu.visible:
  player.rotate_y(-event.relative.x * 0.0025)
  head.rotate_x(-event.relative.y * 0.0025)
  head.rotation.x = clamp(head.rotation.x,-1.45,1.45)
 if event is InputEventKey and event.pressed and not event.echo:
  match event.keycode:
   KEY_ESCAPE:
    set_paused(not paused_menu.visible)
   KEY_R: reload()
   KEY_1: switch_weapon(0)
   KEY_2: switch_weapon(1)
  KEY_3: switch_weapon(2)
  KEY_4: switch_weapon(3)
  KEY_K: knife_type = (knife_type + 1) % KNIVES.size(); build_gun()
  KEY_P: skin_index = (skin_index + 1) % SKINS.size(); build_gun()
  KEY_G:
   if grenade_held: throw_grenade()
   elif grenade_count > 0: grenade_held = true
   KEY_Q: dash()
   KEY_E: heal()
   KEY_ENTER:
    if dead: get_tree().reload_current_scene()
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
  toggle_zoom(event.pressed)
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not paused_menu.visible:
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
 if paused_menu.visible: return
 elapsed += delta
 update_grenade_preview()
 update_grenade(delta)
 fire_timer = maxf(0,fire_timer - delta)
 reload_timer = maxf(0,reload_timer - delta)
 dash_cooldown = maxf(0,dash_cooldown - delta)
 heal_cooldown = maxf(0,heal_cooldown - delta)
 flash_timer = maxf(0,flash_timer - delta)
 gun_flash.light_energy = 3.0 if flash_timer > 0 else 0.0
 if dead:
  return
 var direction := Vector3.ZERO
 if Input.is_key_pressed(KEY_W): direction.z -= 1
 if Input.is_key_pressed(KEY_S): direction.z += 1
 if Input.is_key_pressed(KEY_A): direction.x -= 1
 if Input.is_key_pressed(KEY_D): direction.x += 1
 direction = (player.global_transform.basis * direction).normalized()
 var speed := SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
 player.velocity.x = direction.x * speed
 player.velocity.z = direction.z * speed
 if not player.is_on_floor(): player.velocity.y -= GRAVITY * delta
 elif Input.is_key_pressed(KEY_SPACE): player.velocity.y = JUMP_SPEED
 player.move_and_slide()
 if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not grenade_held:
  shoot()
 update_bots(delta)
 if enemies.is_empty():
  wave += 1
  spawn_wave()
 var ammo := rifle_ammo if weapon <= 1 else pistol_ammo
 var reserve := rifle_reserve if weapon <= 1 else pistol_reserve
 var weapon_name := ["KR-47", "MR-4", "HEAVY EAGLE", "KNIFE / GRENADE"][weapon]
 status_label.text = "SKIN: %s  |  KNIFE: %s  |  GRENADES: %d%s" % [SKIN_NAMES[skin_index],KNIVES[knife_type],grenade_count,"  |  AIM / THROW" if grenade_held else ""]
 health_bar.hp = health
 health_bar.shield = shield
 hud.text = "CRITIKALSTRIKE   /   ALPHA 1.0\n\nHP  %d / 100     KILLS  %d     WAVE  %d\n%s   %02d / %03d%s\n\nQ DASH  %s     E HEAL  %s" % [health,kills,wave,weapon_name,ammo,reserve,"  RELOADING" if reload_timer > 0 else "", "READY" if dash_cooldown == 0 else "%.1fs" % dash_cooldown,"READY" if heal_cooldown == 0 else "%.1fs" % heal_cooldown]

func shoot() -> void:
 if fire_timer > 0 or reload_timer > 0 or weapon == 3: return
 var ammo := rifle_ammo if weapon <= 1 else pistol_ammo
 if ammo <= 0:
  reload()
  return
 if weapon <= 1: rifle_ammo -= 1
 else: pistol_ammo -= 1
 fire_timer = 0.105 if weapon == 0 else (0.12 if weapon == 1 else 0.26)
 flash_timer = 0.045
 var from := camera.global_position
 var aim := -camera.global_transform.basis.z
 var spread := (0.003 if scoped else 0.012) if weapon <= 1 else (0.002 if scoped else 0.008)
 aim = (aim + camera.global_transform.basis.x * rng.randf_range(-spread,spread) + camera.global_transform.basis.y * rng.randf_range(-spread,spread)).normalized()
 var query := PhysicsRayQueryParameters3D.create(from,from + aim * 120)
 query.exclude = [player.get_rid()]
 var result := get_world_3d().direct_space_state.intersect_ray(query)
 if not result.is_empty():
  var target: Object = result["collider"]
  if target is CharacterBody3D and enemies.has(target):
   var damage := 32 if weapon == 0 else 42
   if result["position"].y > target.global_position.y + 0.65: damage *= 2
   damage_enemy(target,damage)

func reload() -> void:
 if reload_timer > 0 or weapon == 3: return
 if weapon <= 1:
  if rifle_ammo == 30 or rifle_reserve == 0: return
  var amount: int = mini(30 - rifle_ammo,rifle_reserve)
  rifle_reserve -= amount
  rifle_ammo += amount
 else:
  if pistol_ammo == 12 or pistol_reserve == 0: return
  var amount: int = mini(12 - pistol_ammo,pistol_reserve)
  pistol_reserve -= amount
  pistol_ammo += amount
 reload_timer = 1.5

func switch_weapon(index: int) -> void:
 if weapon == index: return
 weapon = index
 toggle_zoom(false)
 grenade_held = false
 reload_timer = 0
 build_gun()

func dash() -> void:
 if dash_cooldown > 0 or dead: return
 var direction := -camera.global_transform.basis.z
 direction.y = 0
 player.velocity.x = direction.normalized().x * 22.0
 player.velocity.z = direction.normalized().z * 22.0
 dash_cooldown = 7
 show_message("DASH ACTIVATED",0.7)

func heal() -> void:
 if heal_cooldown > 0 or health == 100 or dead: return
 health = mini(100,health + 40)
 heal_cooldown = 18
 show_message("+40 HP  HEAL",1)

func update_bots(delta: float) -> void:
 for enemy in enemies:
  if not is_instance_valid(enemy): continue
  var toward := player.global_position - enemy.global_position
  var distance := toward.length()
  if distance > 3:
   var move := toward.normalized() * 2.5
   enemy.velocity.x = move.x
   enemy.velocity.z = move.z
  else:
   enemy.velocity.x = 0
   enemy.velocity.z = 0
  if not enemy.is_on_floor(): enemy.velocity.y -= GRAVITY * delta
  enemy.move_and_slide()
  enemy_cooldowns[enemy] = float(enemy_cooldowns.get(enemy,1.0)) - delta
  if distance < 20 and enemy_cooldowns[enemy] <= 0:
   var query := PhysicsRayQueryParameters3D.create(enemy.global_position + Vector3(0,0.6,0),player.global_position + Vector3(0,0.6,0))
   query.exclude = [enemy.get_rid()]
   var hit := get_world_3d().direct_space_state.intersect_ray(query)
   if not hit.is_empty() and hit["collider"] == player:
    var incoming := rng.randi_range(3,7)
    var blocked: int = mini(shield, incoming)
    shield -= blocked
    health -= incoming - blocked
    if health <= 0:
     health = 0
     dead = true
     Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
     show_message("YOU DIED  |  PRESS ENTER TO RESTART",3600)
   enemy_cooldowns[enemy] = rng.randf_range(1.7,2.6)
