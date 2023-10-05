extends Node

enum TileType {
	NOTHING,
	STONE,
	WALL,
	FLOOR,
	DOOR,
	STAIRS_UP,
	STAIRS_DOWN,
	PLAYER_START_POSITION,
}

class Tile:
	# An individual tile
	var x : int
	var y : int
	var tile_type : TileType

	func _init(tile_x, tile_y, type):
		self.x = tile_x
		self.y = tile_y
		self.tile_type = type

func generateOBJ():
	var vertices = []
	var normals = []
	var uvs = []
	var faces = []
	
	var tile_size = 1.0
	var floor_y = 0
	var wall_y = 1
	
	var tile_vertices = [
		Vector3(-0.5, 0.0, 0.5),
		Vector3(0.5, 0.0, 0.5),
		Vector3(-0.5, 0.0, -0.5),
		Vector3(0.5, 0.0, -0.5),
	]
	var tile_normal = Vector3.UP
	var tile_uvs = [
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
	]
	
	# tiles go 
	var tiles = [
#		[Tile.new(0,0,TileType.WALL)]
		[Tile.new(0,0,TileType.WALL),Tile.new(1,0,TileType.WALL)],
#		[Tile.new(0,0,TileType.WALL),Tile.new(1,0,TileType.WALL),Tile.new(2,0,TileType.WALL)],
#		[Tile.new(0,1,TileType.WALL),Tile.new(1,1,TileType.FLOOR),Tile.new(2,1,TileType.WALL)],
#		[Tile.new(2,0,TileType.WALL),Tile.new(1,2,TileType.WALL),Tile.new(2,2,TileType.WALL)],
		]
	
	var faces_by_tile = {}
	
	for row in tiles:
		#var row_length = len(row)
		var tile_verts = []
		for column in row:
			# make the first triangle
			var position = Vector3(column.x * tile_size, floor_y, -column.y * tile_size)
			# -0.5,  0.0,  0.5 = bottom left
			#  0.5,  0.0,  0.5 = bottom right
			# -0.5,  0.0, -0.5 = top left
			#  0.5,  0.0,  0.5 = top right
			vertices.append(position + Vector3(tile_vertices[2])) # top left, index: len-4
			tile_verts.append(vertices[len(vertices)-1])
			normals.append(tile_normal)
			uvs.append(tile_uvs[2])
			
			vertices.append(position + Vector3(tile_vertices[0])) # bottom left, index: len-3
			tile_verts.append(vertices[len(vertices)-1])
			normals.append(tile_normal)
			uvs.append(tile_uvs[0])
			
			if len(tile_verts) < 4:
				vertices.append(position + Vector3(tile_vertices[3])) # top right, index: len-2
				tile_verts.append(vertices[len(vertices)-1])
				normals.append(tile_normal)
				uvs.append(tile_uvs[3])
				
				vertices.append(position + Vector3(tile_vertices[1])) # bottom right, index: len-1
				tile_verts.append(vertices[len(vertices)-1])
				normals.append(tile_normal)
				uvs.append(tile_uvs[1])
			# create the faces
			# faces must be created counter-clockwise
			var verts_len = len(vertices)
#			faces.append([verts_len-3, verts_len-2, verts_len])
#			faces.append([verts_len-3, verts_len, verts_len-1])
			#faces.append([verts_len-3, verts_len-2, verts_len-4])
			#faces.append([verts_len-3, verts_len-1, verts_len-2])
			faces.append([verts_len-4, verts_len-2, verts_len-1])
			faces.append([verts_len-4, verts_len-3, verts_len-2])
#			faces.append([base_vertex_index + 1, base_vertex_index + 2, base_vertex_index + 4])
#			faces.append([base_vertex_index + 1, base_vertex_index + 4, base_vertex_index + 3])
#			
			# remove the first 2 verts for the next time
			tile_verts.pop_front()
			tile_verts.pop_front()
			
#
#	for tile_index in range(len(tiles)):
#		var tile = tiles[tile_index]
#		var x = tile.x
#		var y = tile.y
#
#		# make the first triangle
#		var position = Vector3(x * tile_size, floor_y, y * tile_size)
#		# -0.5,  0.0,  0.5 = bottom left
#		#  0.5,  0.0,  0.5 = bottom right
#		# -0.5,  0.0, -0.5 = top left
#		#  0.5,  0.0,  0.5 = top right
#		var vertex_1 = position + Vector3(tile_vertices[0])
#		var vertex_2 = position + Vector3(tile_vertices[3])
#
#		if tile.tile_type == TileType.FLOOR:
#			# Add vertices, normals, and UVs for a floor tile
#			for i in range(4):
#				vertices.append(tile_vertices[i] + Vector3(x * tile_size, floor_y, -y * tile_size))
#				normals.append(tile_normal)
#				uvs.append(tile_uvs[i])
#			# Define faces for a floor tile (two triangles)
#			var base_vertex_index = (y * 3 + x) * 4
#			faces.append([base_vertex_index + 1, base_vertex_index + 2, base_vertex_index + 4])
#			faces.append([base_vertex_index + 1, base_vertex_index + 4, base_vertex_index + 3])
#		elif tile.tile_type == TileType.WALL:
#				# Generate OBJ data for a wall tile (a simple square)
#				var base_vertex_index = (y * 3 + x) * 4
#				for i in range(4):
#					vertices.append(tile_vertices[i] + Vector3(x * tile_size, wall_y, -y * tile_size))
#					normals.append(tile_normal)
#					uvs.append(tile_uvs[i])
#				faces.append([base_vertex_index + 1, base_vertex_index + 2, base_vertex_index + 4])
#				faces.append([base_vertex_index + 1, base_vertex_index + 4, base_vertex_index + 3])
#		# make note of the faces for the tile
#		faces_by_tile[tile_index] = [faces[len(faces)-1], faces[len(faces)-2]]
#	push_warning(faces_by_tile)
	
	write_obj_file("output.obj", vertices, normals, uvs, faces)
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	return surface_array

func write_obj_file(filename, vertices, normals, uvs, faces):
	var file = FileAccess.open("res://%s" % filename, FileAccess.WRITE)
	
	for vertex in vertices:
		file.store_line("v " + str(vertex.x) + " " + str(vertex.y) + " " + str(vertex.z))
	for normal in normals:
		file.store_line("vn " + str(normal.x) + " " + str(normal.y) + " " + str(normal.z))
	for uv in uvs:
		file.store_line("vt " + str(uv.x) + " " + str(uv.y))
	for face in faces:
		var faceStr = "f"
		for vertexIndex in face:
			faceStr += " " + str(vertexIndex) + "/" + str(vertexIndex) + "/" + str(vertexIndex)
		file.store_line(faceStr)
	file.close()

func _ready():
	var surface_array = generateOBJ()
	var child = CSGMesh3D.new()
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
	child.mesh = array_mesh
	add_child(child)
