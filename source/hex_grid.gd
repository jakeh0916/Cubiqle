class_name HexGrid extends Resource

const FROM_HEXAGON_COORDS := Basis(Vector3(sqrt(3) / 2, 0.5, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))
const TO_HEXAGON_COORDS   := Basis(Vector3(2 / sqrt(3), -1 / sqrt(3), 0), Vector3(0, 1, 0), Vector3(0, 0, 1))

@export var m_hexagon_side_length: int
@export var m_vertex_to_tile_anchors_map: Dictionary

#---------------------------------------------------------------------------------------------#
func _init(hexagon_side_length: int = 3) -> void:
	if hexagon_side_length < 1:
		hexagon_side_length = 1
	
	m_hexagon_side_length = hexagon_side_length
	
	var num_vertices_per_side := hexagon_side_length - 1
	for vertex_i in range(-num_vertices_per_side, num_vertices_per_side + 1):
		for vertex_j in range(-num_vertices_per_side, num_vertices_per_side + 1):
			var vertex := Vector2i(vertex_i, vertex_j)
			
			# Skip vertices outside of the hexagon.
			if not is_vertex_in_hexagon(vertex):
				continue
			
			# Add vertex and its initial connected tile anchors.
			var tile_anchors := Tile.get_default_tile_anchors(vertex)
			m_vertex_to_tile_anchors_map[vertex] = tile_anchors

#---------------------------------------------------------------------------------------------#
func get_hexagon_side_length() -> int:
	return m_hexagon_side_length

#---------------------------------------------------------------------------------------------#
func get_vertex_to_tile_anchors_map() -> Dictionary:
	return m_vertex_to_tile_anchors_map

#---------------------------------------------------------------------------------------------#
func get_tile_information() -> Dictionary:
	var tile_information := {} # Tile corner positions -> tile type.
	
	for vertex in m_vertex_to_tile_anchors_map.keys():
		for tile_anchor in m_vertex_to_tile_anchors_map[vertex]:
			var tile_corner_positions := Tile.get_tile_corner_positions(vertex, tile_anchor)
			tile_information[tile_corner_positions] = Tile.get_tile_type_from_anchor(tile_anchor)
	
	return tile_information

#---------------------------------------------------------------------------------------------#
func is_vertex_in_hexagon(vertex: Vector2i) -> bool:
	return (absi(vertex.x) < m_hexagon_side_length and
			absi(vertex.y) < m_hexagon_side_length and
			absi(vertex.x + vertex.y) < m_hexagon_side_length)

#---------------------------------------------------------------------------------------------#
func is_vertex_rotatable(vertex: Vector2i) -> bool:
	if not is_vertex_in_hexagon(vertex):
		return false
	
	var tile_anchors := m_vertex_to_tile_anchors_map[vertex] as Array[Tile.Anchor]
	return tile_anchors.size() == 3 and (
		(tile_anchors.has(Tile.Anchor.A4) and tile_anchors.has(Tile.Anchor.B1) and tile_anchors.has(Tile.Anchor.C2)) or
		(tile_anchors.has(Tile.Anchor.A2) and tile_anchors.has(Tile.Anchor.B3) and tile_anchors.has(Tile.Anchor.C4)))

#---------------------------------------------------------------------------------------------#
func rotate_vertex(vertex: Vector2i) -> void:
	if not is_vertex_rotatable(vertex):
		return
	
	var tile_anchors := m_vertex_to_tile_anchors_map[vertex] as Array[Tile.Anchor]
	
	# We need to update the tile anchors for all adjacent vertices (up, up right, down right, etc.).
	var u  := Vector2i(vertex.x, vertex.y + 1)
	var ur := Vector2i(vertex.x + 1, vertex.y)
	var dr := Vector2i(vertex.x + 1, vertex.y - 1)
	var d  := Vector2i(vertex.x, vertex.y - 1)
	var dl := Vector2i(vertex.x - 1, vertex.y)
	var ul := Vector2i(vertex.x - 1, vertex.y + 1)
	
	if tile_anchors.size() == 3 and tile_anchors.has(Tile.Anchor.A4) and tile_anchors.has(Tile.Anchor.B1) and tile_anchors.has(Tile.Anchor.C2):
		m_vertex_to_tile_anchors_map[vertex] = [ Tile.Anchor.A2, Tile.Anchor.B3, Tile.Anchor.C4 ] as Array[Tile.Anchor]
		
		if m_vertex_to_tile_anchors_map.has(u):  _replace_tile_anchors(u,  [ Tile.Anchor.A2 ], [ Tile.Anchor.C1, Tile.Anchor.B2 ])
		if m_vertex_to_tile_anchors_map.has(ur): _replace_tile_anchors(ur, [ Tile.Anchor.A3, Tile.Anchor.B2 ], [ Tile.Anchor.C2 ])
		if m_vertex_to_tile_anchors_map.has(dr): _replace_tile_anchors(dr, [ Tile.Anchor.B3 ], [ Tile.Anchor.A3, Tile.Anchor.C3 ])
		if m_vertex_to_tile_anchors_map.has(d):  _replace_tile_anchors(d,  [ Tile.Anchor.B4, Tile.Anchor.C3 ], [ Tile.Anchor.A4 ])
		if m_vertex_to_tile_anchors_map.has(dl): _replace_tile_anchors(dl, [ Tile.Anchor.C4 ], [ Tile.Anchor.A1, Tile.Anchor.B4 ])
		if m_vertex_to_tile_anchors_map.has(ul): _replace_tile_anchors(ul, [ Tile.Anchor.A1, Tile.Anchor.C1 ], [ Tile.Anchor.B1 ])
	
	if tile_anchors.size() == 3 and tile_anchors.has(Tile.Anchor.A2) and tile_anchors.has(Tile.Anchor.B3) and tile_anchors.has(Tile.Anchor.C4):
		m_vertex_to_tile_anchors_map[vertex] = [ Tile.Anchor.A4, Tile.Anchor.B1, Tile.Anchor.C2 ] as Array[Tile.Anchor]
		
		if m_vertex_to_tile_anchors_map.has(u):  _replace_tile_anchors(u,  [ Tile.Anchor.C1, Tile.Anchor.B2 ], [ Tile.Anchor.A2 ])
		if m_vertex_to_tile_anchors_map.has(ur): _replace_tile_anchors(ur, [ Tile.Anchor.C2 ], [ Tile.Anchor.A3, Tile.Anchor.B2 ])
		if m_vertex_to_tile_anchors_map.has(dr): _replace_tile_anchors(dr, [ Tile.Anchor.A3, Tile.Anchor.C3 ], [ Tile.Anchor.B3 ])
		if m_vertex_to_tile_anchors_map.has(d):  _replace_tile_anchors(d,  [ Tile.Anchor.A4 ], [ Tile.Anchor.B4, Tile.Anchor.C3 ])
		if m_vertex_to_tile_anchors_map.has(dl): _replace_tile_anchors(dl, [ Tile.Anchor.A1, Tile.Anchor.B4 ], [ Tile.Anchor.C4 ])
		if m_vertex_to_tile_anchors_map.has(ul): _replace_tile_anchors(ul, [ Tile.Anchor.B1 ], [ Tile.Anchor.A1, Tile.Anchor.C1 ])

#---------------------------------------------------------------------------------------------#
func rotate_grid(rotation_degrees: int) -> void:
	if not (rotation_degrees == 60 or rotation_degrees == 120 or
			rotation_degrees == -60 or rotation_degrees == -120):
		
		print("hex_grid.rotate_grid: unsupported rotation degrees.")
		return
	
	var rotation_radians := deg_to_rad(rotation_degrees)
	var rotated_vertex_to_tile_anchors_map := {}
	for vertex in m_vertex_to_tile_anchors_map:
		var rotated_vertex = FROM_HEXAGON_COORDS * Vector3(vertex.x, vertex.y, 0)
		rotated_vertex = Vector2(rotated_vertex.x, -1 * rotated_vertex.y)
		rotated_vertex = rotated_vertex.rotated(rotation_radians)
		rotated_vertex = TO_HEXAGON_COORDS * Vector3(rotated_vertex.x, -1 * rotated_vertex.y, 0)
		rotated_vertex = Vector2i(roundi(rotated_vertex.x), roundi(rotated_vertex.y))
		
		var rotated_tile_anchors: Array[Tile.Anchor] = []
		for tile_anchor in m_vertex_to_tile_anchors_map[vertex]:
			if rotation_degrees == 60:
				rotated_tile_anchors.push_back(Tile.ANCHOR_ROTATIONS_CW[tile_anchor])
			elif rotation_degrees == 120:
				rotated_tile_anchors.push_back(Tile.ANCHOR_ROTATIONS_CW[Tile.ANCHOR_ROTATIONS_CW[tile_anchor]])
			elif rotation_degrees == -60:
				rotated_tile_anchors.push_back(Tile.ANCHOR_ROTATIONS_CCW[tile_anchor])
			elif rotation_degrees == -120:
				rotated_tile_anchors.push_back(Tile.ANCHOR_ROTATIONS_CCW[Tile.ANCHOR_ROTATIONS_CCW[tile_anchor]])
		
		rotated_vertex_to_tile_anchors_map[rotated_vertex] = rotated_tile_anchors
	m_vertex_to_tile_anchors_map = rotated_vertex_to_tile_anchors_map

#---------------------------------------------------------------------------------------------#
func _replace_tile_anchors(vertex: Vector2i, to_remove: Array[Tile.Anchor], to_add: Array[Tile.Anchor]) -> void:
	var tile_anchors := m_vertex_to_tile_anchors_map[vertex] as Array[Tile.Anchor]
	
	var found_all_to_remove := true
	for tile_anchor_to_remove in to_remove:
		found_all_to_remove = found_all_to_remove and tile_anchors.has(tile_anchor_to_remove)
	
	if not found_all_to_remove:
		push_error("_replace_tile_anchors: Failed to find all tile anchors to remove!")
	
	for tile_anchor_to_remove in to_remove:
		tile_anchors.erase(tile_anchor_to_remove)
	
	tile_anchors.append_array(to_add)
