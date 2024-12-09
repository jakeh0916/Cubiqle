class_name HexGridController extends Node2D

@export var TILE_A_COLOR := Color("#689074")
@export var TILE_B_COLOR := Color("#A2B3B4")
@export var TILE_C_COLOR := Color("#4A5859")
@export var TILE_TEXTURE := preload("res://texture/tile.svg") as CompressedTexture2D

@onready var m_user_hex_grid_owner   := $UserHexGridOwner
@onready var m_target_hex_grid_owner := $TargetHexGridOwner

var m_user_hex_grid   := HexGrid.new(3)
var m_target_hex_grid := HexGrid.new(3)

var m_vertex_to_tile_sprite_map := {}

var m_queued_vertex_rotation = null
var m_queued_vertex_rotation_pivot = null
var m_queued_grid_rotation = null


#---------------------------------------------------------------------------------------------#
func _ready() -> void:
	# DEBUG: Load scenario.
	var scenario = preload("res://debug_scenario.tres") as HexGridScenario
	_load_scenario(scenario)
	
	_draw_user_hex_grid()
	_draw_target_hex_grid()

#---------------------------------------------------------------------------------------------#
func _process(_delta: float) -> void:
	_reposition_user_hex_grid()
	_reposition_target_hex_grid()
	
	if Input.is_action_just_pressed("q"):
		_queue_grid_rotation(-60)
	if Input.is_action_just_pressed("e"):
		_queue_grid_rotation(60)
	if Input.is_action_just_pressed("DEBUG_1"):
		var scenario := HexGridScenario.new()
		scenario.user_hex_grid = m_user_hex_grid.duplicate()
		ResourceSaver.save(scenario, "res://exported_scenario.tres")

#---------------------------------------------------------------------------------------------#
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click(event.position)

#---------------------------------------------------------------------------------------------#
# DEBUG: load a debug scenario.
func _load_scenario(scenario: HexGridScenario) -> void:
	m_user_hex_grid = scenario.user_hex_grid
	m_target_hex_grid = scenario.target_hex_grid
	get_parent().get_node("HexGridInterface/Footer/BestMovesSection/BestCount").text = "%d" % scenario.best_move_count
	get_parent().get_node("HexGridInterface/Footer/MovesSection/MoveCount").text = "0"

#---------------------------------------------------------------------------------------------#
# DEBUG: update move count and check if done.
func _made_move() -> void:
	get_parent().get_node("HexGridInterface/Footer/MovesSection/MoveCount").text = \
		"%s" % (get_parent().get_node("HexGridInterface/Footer/MovesSection/MoveCount").text.to_int() + 1)
	if m_user_hex_grid.get_tile_information() == m_target_hex_grid.get_tile_information():
		get_parent().win_game()

#=============================================================================================#
# Drawing User & Target Hex Grids
#=============================================================================================#

#---------------------------------------------------------------------------------------------#
func _clear_user_hex_grid() -> void:
	m_vertex_to_tile_sprite_map.clear()
	for user_hex_grid_child in m_user_hex_grid_owner.get_children():
		user_hex_grid_child.queue_free()

#---------------------------------------------------------------------------------------------#
func _draw_user_hex_grid() -> void:
	_clear_user_hex_grid()
	
	var tile_information = m_user_hex_grid.get_tile_information()
	for tile_corner_positions in tile_information.keys():
		var tile_origin_in_hex := 0.25 * Vector2(
			tile_corner_positions[0] + tile_corner_positions[1] +
			tile_corner_positions[2] + tile_corner_positions[3])
		
		var tile_sprite := Sprite2D.new()
		tile_sprite.texture = TILE_TEXTURE
		
		var tile_type := tile_information[tile_corner_positions] as Tile.Type
		if tile_type == Tile.Type.A:
			tile_sprite.rotation_degrees = 0.0
			tile_sprite.modulate = TILE_A_COLOR
		if tile_type == Tile.Type.B:
			tile_sprite.rotation_degrees = 120.0
			tile_sprite.modulate = TILE_B_COLOR
		if tile_type == Tile.Type.C:
			tile_sprite.rotation_degrees = 240.0
			tile_sprite.modulate = TILE_C_COLOR
		
		var tile_origin_in_screen = HexGrid.FROM_HEXAGON_COORDS * Vector3(tile_origin_in_hex.x, tile_origin_in_hex.y, 0.0)
		tile_sprite.position = TILE_TEXTURE.get_height() * Vector2(tile_origin_in_screen.x, -1 * tile_origin_in_screen.y)
		
		for tile_corner_idx in range(4):
			if not m_vertex_to_tile_sprite_map.has(tile_corner_positions[tile_corner_idx]):
				m_vertex_to_tile_sprite_map[tile_corner_positions[tile_corner_idx]] = []
			m_vertex_to_tile_sprite_map[tile_corner_positions[tile_corner_idx]].push_back(tile_sprite)
		
		m_user_hex_grid_owner.add_child(tile_sprite)

#---------------------------------------------------------------------------------------------#
func _clear_target_hex_grid() -> void:
	for target_hex_grid_child in m_target_hex_grid_owner.get_children():
		target_hex_grid_child.queue_free()

#---------------------------------------------------------------------------------------------#
func _draw_target_hex_grid() -> void:
	_clear_target_hex_grid()
	
	var tile_information = m_target_hex_grid.get_tile_information()
	for tile_corner_positions in tile_information.keys():
		var tile_origin_in_hex := 0.25 * Vector2(
			tile_corner_positions[0] + tile_corner_positions[1] +
			tile_corner_positions[2] + tile_corner_positions[3])
		
		var tile_sprite := Sprite2D.new()
		tile_sprite.texture = TILE_TEXTURE
		
		var tile_type := tile_information[tile_corner_positions] as Tile.Type
		if tile_type == Tile.Type.A:
			tile_sprite.rotation_degrees = 0.0
			tile_sprite.modulate = TILE_A_COLOR
		if tile_type == Tile.Type.B:
			tile_sprite.rotation_degrees = 120.0
			tile_sprite.modulate = TILE_B_COLOR
		if tile_type == Tile.Type.C:
			tile_sprite.rotation_degrees = 240.0
			tile_sprite.modulate = TILE_C_COLOR
		
		var tile_origin_in_screen = HexGrid.FROM_HEXAGON_COORDS * Vector3(tile_origin_in_hex.x, tile_origin_in_hex.y, 0.0)
		tile_sprite.position = TILE_TEXTURE.get_height() * Vector2(tile_origin_in_screen.x, -1 * tile_origin_in_screen.y)
		
		m_target_hex_grid_owner.add_child(tile_sprite)

#---------------------------------------------------------------------------------------------#
func _reposition_user_hex_grid() -> void:
	# Move user hex grid to the center of the screen.
	var screen_size := get_viewport().get_visible_rect().size
	m_user_hex_grid_owner.position = screen_size * 0.5
	
	# Scale the user hex grid to fit between UI elements.
	var hex_grid_height_px := 2.0 * m_user_hex_grid.get_hexagon_side_length() * TILE_TEXTURE.get_height()
	var hex_grid_scale := (0.575 * screen_size.y) / hex_grid_height_px
	m_user_hex_grid_owner.scale = Vector2(hex_grid_scale, hex_grid_scale)

#---------------------------------------------------------------------------------------------#
func _reposition_target_hex_grid() -> void:
	m_target_hex_grid_owner.position = get_parent().get_node("HexGridInterface/Footer/TARGET_HEX_GRID_PLACEHOLDER").get_screen_position()
	
	var screen_size := get_viewport().get_visible_rect().size
	var hex_grid_height_px := 2.0 * m_target_hex_grid.get_hexagon_side_length() * TILE_TEXTURE.get_height()
	var hex_grid_scale := (0.16 * screen_size.y) / hex_grid_height_px
	m_target_hex_grid_owner.scale = Vector2(hex_grid_scale, hex_grid_scale)

#=============================================================================================#
# User Hex Grid Input Handling
#=============================================================================================#

#---------------------------------------------------------------------------------------------#
func _handle_click(mouse_position: Vector2) -> void:
	mouse_position -= m_user_hex_grid_owner.position
	mouse_position /= m_user_hex_grid_owner.scale
	
	mouse_position = Vector2(mouse_position.x, -1 * mouse_position.y) / TILE_TEXTURE.get_height()
	
	var mouse_position_in_hex = HexGrid.TO_HEXAGON_COORDS * Vector3(mouse_position.x, mouse_position.y, 0)
	var vertex := Vector2i(roundi(mouse_position_in_hex.x), roundi(mouse_position_in_hex.y))
	
	if m_user_hex_grid.is_vertex_rotatable(vertex):
		_queue_vertex_rotation(vertex)

#---------------------------------------------------------------------------------------------#
func _queue_vertex_rotation(vertex: Vector2i) -> void:
	if not m_queued_vertex_rotation == null or not m_queued_grid_rotation == null:
		return
	
	m_queued_vertex_rotation = vertex
	
	# Create a temporary pivot node for the selected tiles to rotate around.
	m_queued_vertex_rotation_pivot = Node2D.new()
	var pivot_position = HexGrid.FROM_HEXAGON_COORDS * Vector3(vertex.x, vertex.y, 0.0)
	pivot_position = TILE_TEXTURE.get_height() * Vector2(pivot_position.x, -1 * pivot_position.y)
	m_queued_vertex_rotation_pivot.position = pivot_position
	m_user_hex_grid_owner.add_child(m_queued_vertex_rotation_pivot)
	
	# Reparent selected tiles to the temporary pivot node.
	for connected_tile in m_vertex_to_tile_sprite_map[vertex]:
		connected_tile.reparent(m_queued_vertex_rotation_pivot)
		
		var next_color := Color.BLACK
		match connected_tile.modulate:
			TILE_A_COLOR: next_color = TILE_C_COLOR
			TILE_B_COLOR: next_color = TILE_A_COLOR
			TILE_C_COLOR: next_color = TILE_B_COLOR
		
		# Tween the tile colors from current -> next color.
		var tile_color_tween = get_tree().create_tween()
		tile_color_tween.set_ease(Tween.EASE_IN_OUT)
		tile_color_tween.set_trans(Tween.TRANS_QUART)
		tile_color_tween.tween_property(connected_tile, "modulate", next_color, 0.5)
	
	# Tween the pivot for a 60 degree rotation.
	var pivot_rotation_tween = get_tree().create_tween()
	pivot_rotation_tween.set_ease(Tween.EASE_IN_OUT)
	pivot_rotation_tween.set_trans(Tween.TRANS_CUBIC)
	pivot_rotation_tween.tween_property(m_queued_vertex_rotation_pivot, "rotation_degrees", 60.0, 0.6)
	pivot_rotation_tween.tween_callback(_finish_vertex_rotation)

#---------------------------------------------------------------------------------------------#
func _finish_vertex_rotation() -> void:
	if m_queued_vertex_rotation == null:
		return
	
	m_user_hex_grid.rotate_vertex(m_queued_vertex_rotation)
	
	m_queued_vertex_rotation = null
	m_queued_vertex_rotation_pivot = null
	
	_draw_user_hex_grid()
	
	_made_move()

#---------------------------------------------------------------------------------------------#
func _queue_grid_rotation(degrees: int) -> void:
	if not m_queued_grid_rotation == null or not m_queued_vertex_rotation == null:
		return
	
	m_queued_grid_rotation = degrees
	
	# Tween all hex grid tiles from current -> next colors.
	for tile_sprite in m_user_hex_grid_owner.get_children():
		var next_color := Color.BLACK
		if degrees == 60 or degrees == -120:
			match tile_sprite.modulate:
				TILE_A_COLOR: next_color = TILE_C_COLOR
				TILE_B_COLOR: next_color = TILE_A_COLOR
				TILE_C_COLOR: next_color = TILE_B_COLOR
		elif degrees == -60 or degrees == 120:
			match tile_sprite.modulate:
				TILE_A_COLOR: next_color = TILE_B_COLOR
				TILE_B_COLOR: next_color = TILE_C_COLOR
				TILE_C_COLOR: next_color = TILE_A_COLOR
		
		var tile_color_tween = get_tree().create_tween()
		tile_color_tween.set_ease(Tween.EASE_IN_OUT)
		tile_color_tween.set_trans(Tween.TRANS_QUART)
		tile_color_tween.tween_property(tile_sprite, "modulate", next_color, 0.8)
	
	# Tween the hex grid rotation.
	var grid_rotation_tween = get_tree().create_tween()
	grid_rotation_tween.set_ease(Tween.EASE_IN_OUT)
	grid_rotation_tween.set_trans(Tween.TRANS_CUBIC)
	grid_rotation_tween.tween_property(m_user_hex_grid_owner, "rotation_degrees", m_queued_grid_rotation, 0.9)
	grid_rotation_tween.tween_callback(_finish_grid_rotation)

#---------------------------------------------------------------------------------------------#
func _finish_grid_rotation() -> void:
	if m_queued_grid_rotation == null:
		return
	
	m_user_hex_grid.rotate_grid(m_queued_grid_rotation)
	
	m_user_hex_grid_owner.rotation_degrees = 0
	m_queued_grid_rotation = null
	
	_draw_user_hex_grid()
	
	_made_move()

#---------------------------------------------------------------------------------------------#
func _on_rotate_cw_pressed():
	_queue_grid_rotation(60)

#---------------------------------------------------------------------------------------------#
func _on_rotate_ccw_pressed():
	_queue_grid_rotation(-60)
