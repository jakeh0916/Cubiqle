class_name Tile

enum Type {
	A, B, C
}

enum Anchor {
	#   _- A2 -_  
	# A1        A3
	#   -_ A4 _-  
	A1, A2, A3, A4,
	
	#     _- B2   
	#   B1   |    
	#    |   B3   
	#   B4 _-     
	B1, B2, B3, B4,
	
	#   C1 -_     
	#    |   C2   
	#   C4   |    
	#     -_ C3   
	C1, C2, C3, C4
}

# Map of tile anchors before -> after a 60 degree clockwise rotation of the grid.
const ANCHOR_ROTATIONS_CW = {
	Tile.Anchor.A1 : Tile.Anchor.C1,
	Tile.Anchor.A2 : Tile.Anchor.C2,
	Tile.Anchor.A3 : Tile.Anchor.C3,
	Tile.Anchor.A4 : Tile.Anchor.C4,
	Tile.Anchor.B1 : Tile.Anchor.A2,
	Tile.Anchor.B2 : Tile.Anchor.A3,
	Tile.Anchor.B3 : Tile.Anchor.A4,
	Tile.Anchor.B4 : Tile.Anchor.A1,
	Tile.Anchor.C1 : Tile.Anchor.B2,
	Tile.Anchor.C2 : Tile.Anchor.B3,
	Tile.Anchor.C3 : Tile.Anchor.B4,
	Tile.Anchor.C4 : Tile.Anchor.B1,
}

# Map of tile anchors before -> after a 60 degree counter-clockwise rotation of the grid.
const ANCHOR_ROTATIONS_CCW = {
	Tile.Anchor.C1 : Tile.Anchor.A1,
	Tile.Anchor.C2 : Tile.Anchor.A2,
	Tile.Anchor.C3 : Tile.Anchor.A3,
	Tile.Anchor.C4 : Tile.Anchor.A4,
	Tile.Anchor.A2 : Tile.Anchor.B1,
	Tile.Anchor.A3 : Tile.Anchor.B2,
	Tile.Anchor.A4 : Tile.Anchor.B3,
	Tile.Anchor.A1 : Tile.Anchor.B4,
	Tile.Anchor.B2 : Tile.Anchor.C1,
	Tile.Anchor.B3 : Tile.Anchor.C2,
	Tile.Anchor.B4 : Tile.Anchor.C3,
	Tile.Anchor.B1 : Tile.Anchor.C4,
}

#---------------------------------------------------------------------------------------------#
static func get_tile_type_from_anchor(tile_anchor) -> Tile.Type:
	if tile_anchor <= Tile.Anchor.A4:
		return Tile.Type.A
	elif tile_anchor <= Tile.Anchor.B4:
		return Tile.Type.B
	else:
		return Tile.Type.C

#---------------------------------------------------------------------------------------------#
static func get_default_tile_anchors(vertex: Vector2i) -> Array[Tile.Anchor]:
	var i := vertex.x
	var j := vertex.y
	
	# Vertex is in the center of the hexagon.
	if i == 0 and j == 0:
		return [ Tile.Anchor.A2, Tile.Anchor.B3, Tile.Anchor.C4 ]
	
	# Vertex is on the center -> top line.
	elif i == 0 and j > 0:
		return [ Tile.Anchor.B2, Tile.Anchor.B3, Tile.Anchor.C1, Tile.Anchor.C4 ]
	
	# Vertex is on the center -> bottom-left line.
	elif i < 0 and j == 0:
		return [ Tile.Anchor.A1, Tile.Anchor.A2, Tile.Anchor.B3, Tile.Anchor.B4 ]
	
	# Vertex is on the center -> bottom-right line.
	elif i > 0 and j == -1 * i:
		return [ Tile.Anchor.A2, Tile.Anchor.A3, Tile.Anchor.C3, Tile.Anchor.C4]
	
	# Vertex is in the bottom section.
	elif (i <= 0 and j < 0) or (i > 0 and j < -1 * i):
		return [ Tile.Anchor.A1, Tile.Anchor.A2, Tile.Anchor.A3, Tile.Anchor.A4 ]
	
	# Vertex is in the top left section.
	elif i < 0 and j > 0:
		return [ Tile.Anchor.B1, Tile.Anchor.B2, Tile.Anchor.B3, Tile.Anchor.B4 ]
	
	# Vertex is in the top right section.
	elif i > 0 and j > -1 * i:
		return [ Tile.Anchor.C1, Tile.Anchor.C2, Tile.Anchor.C3, Tile.Anchor.C4 ]
	
	return []

#---------------------------------------------------------------------------------------------#
static func get_tile_corner_positions(vertex: Vector2i, tile_anchor: Tile.Anchor) -> Array[Vector2i]:
	var i := vertex.x
	var j := vertex.y
	
	match tile_anchor:
		Tile.Anchor.A1: return [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i + 2, j - 1), Vector2i(i + 1, j - 1) ]
		Tile.Anchor.A2: return [Vector2i(i - 1, j), Vector2i(i, j), Vector2i(i + 1, j - 1), Vector2i(i, j - 1) ]
		Tile.Anchor.A3: return [Vector2i(i - 2, j + 1), Vector2i(i - 1, j + 1), Vector2i(i, j), Vector2i(i - 1, j) ]
		Tile.Anchor.A4: return [Vector2i(i - 1, j + 1), Vector2i(i, j + 1), Vector2i(i + 1, j), Vector2i(i, j) ]
		
		Tile.Anchor.B1: return [Vector2i(i, j), Vector2i(i + 1, j), Vector2i(i + 1, j - 1), Vector2i(i, j - 1) ]
		Tile.Anchor.B2: return [Vector2i(i - 1, j), Vector2i(i, j), Vector2i(i, j - 1), Vector2i(i - 1, j - 1) ]
		Tile.Anchor.B3: return [Vector2i(i - 1, j + 1), Vector2i(i, j + 1), Vector2i(i, j), Vector2i(i - 1, j) ]
		Tile.Anchor.B4: return [Vector2i(i, j + 1), Vector2i(i + 1, j + 1), Vector2i(i + 1, j), Vector2i(i, j) ]
		
		Tile.Anchor.C1: return [Vector2i(i, j), Vector2i(i + 1, j - 1), Vector2i(i + 1, j - 2), Vector2i(i, j - 1) ]
		Tile.Anchor.C2: return [Vector2i(i - 1, j + 1), Vector2i(i, j), Vector2i(i, j - 1), Vector2i(i - 1, j) ]
		Tile.Anchor.C3: return [Vector2i(i - 1, j + 2), Vector2i(i, j + 1), Vector2i(i, j), Vector2i(i - 1, j + 1) ]
		Tile.Anchor.C4: return [Vector2i(i, j + 1), Vector2i(i + 1, j), Vector2i(i + 1, j - 1), Vector2i(i, j) ]
	
	return []
