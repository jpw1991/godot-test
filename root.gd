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

func generate_obj():
	var vertices = []
	var normals = []
	var uvs = []
	var faces = []
	
	var floor_y = 0
	var wall_y = 1
	
	var tiles = [
		[Tile.new(0,0,TileType.WALL)]
#		[Tile.new(0,0,TileType.WALL),Tile.new(1,0,TileType.WALL)],
#		[Tile.new(0,0,TileType.WALL),Tile.new(1,0,TileType.WALL),Tile.new(2,0,TileType.WALL)],
#		[Tile.new(0,1,TileType.WALL),Tile.new(1,1,TileType.FLOOR),Tile.new(2,1,TileType.WALL)],
#		[Tile.new(2,0,TileType.WALL),Tile.new(1,2,TileType.WALL),Tile.new(2,2,TileType.WALL)],
		]
	
	var faces_by_tile = {}
	
	const BOTTOM_LEFT = Vector3(-1, 0, 1)
	const BOTTOM_RIGHT = Vector3(1, 0, 1)
	const TOP_LEFT = Vector3(-1, 0, -1)
	const TOP_RIGHT = Vector3(1, 0, -1)
	
	for row in tiles:
		var tile_verts = []
		for column in row:
			var position = Vector3(column.x, floor_y, -column.y)
			
			vertices.append(position + TOP_LEFT)
			tile_verts.append(len(vertices))
			#normals.append(Vector3.UP)
			uvs.append(Vector2(0.0, 0.0))
			
			vertices.append(position + BOTTOM_LEFT)
			tile_verts.append(len(vertices))
			#normals.append(Vector3.UP)
			uvs.append(Vector2(0.0, 1.0))
			
			if len(tile_verts) < 4:
				vertices.append(position + TOP_RIGHT)
				tile_verts.append(len(vertices))
				#normals.append(Vector3.UP)
				uvs.append(Vector2(1.0, 0.0))
				
				vertices.append(position + BOTTOM_RIGHT)
				tile_verts.append(len(vertices))
				#normals.append(Vector3.UP)
				uvs.append(Vector2(1.0, 1.0))
			normals.append(Vector3.UP)
			# create the faces
			# faces must be created counter-clockwise
			var verts_len = len(vertices)
			faces.append([tile_verts[0], tile_verts[2], tile_verts[1]])
			faces.append([tile_verts[0], tile_verts[3], tile_verts[1]])
#			
			# remove the first 2 verts for the next time
			tile_verts.pop_front()
			tile_verts.pop_front()
	
	write_obj_file("output.obj", vertices, normals, uvs, faces)

func write_obj_file(filename, vertices, normals, uvs, faces):
	var file = FileAccess.open("res://%s" % filename, FileAccess.WRITE)
	file.store_line("o MapMesh")
	for vertex in vertices:
		file.store_line("v %.6f %.6f %.6f" % [vertex.x, vertex.y, vertex.z])
	for normal in normals:
		file.store_line("vn %.4f %.4f %.4f" % [normal.x, normal.y, normal.z])
	for uv in uvs:
		file.store_line("vt %.6f %.6f" % [uv.x, uv.y])
	file.store_line("s 0")
	var face_line = "f"
	for face in faces:
		face_line += " %d/%d/%d" % [face[0], face[1], face[2]]
	file.store_line(face_line)
	file.close()

func _ready():
	generate_obj()
