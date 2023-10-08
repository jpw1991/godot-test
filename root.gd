extends Node
 
const BOTTOM_LEFT = Vector3(0, 0, -1)
const BOTTOM_RIGHT = Vector3(1, 0, -1)
const TOP_LEFT = Vector3(0, 0, 0)
const TOP_RIGHT = Vector3(1, 0, 0)

const BOTTOM_LEFT_UV = Vector2(0.0, 1.0)
const BOTTOM_RIGHT_UV = Vector2(1.0, 1.0)
const TOP_LEFT_UV = Vector2(0.0, 0.0)
const TOP_RIGHT_UV = Vector2(1.0, 0.0)

var mesh_instance : MeshInstance3D
var timer = 0.0
var interval = 1.0

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
 
	func height():
		match self.tile_type:
			TileType.WALL:
				return 1
			_:
				return 0


func generate_surface_tool():
	var tiles_2d = [
		[Tile.new(0,0,TileType.WALL),Tile.new(1,0,TileType.WALL),Tile.new(2,0,TileType.WALL)],
		[Tile.new(0,1,TileType.WALL),Tile.new(1,1,TileType.FLOOR),Tile.new(2,1,TileType.WALL)],
		[Tile.new(0,2,TileType.WALL),Tile.new(1,2,TileType.WALL),Tile.new(2,2,TileType.WALL)],
		[Tile.new(0,3,TileType.FLOOR),Tile.new(1,3,TileType.FLOOR),Tile.new(2,3,TileType.FLOOR)],
		]
	var result = SurfaceTool.new()
	result.begin(Mesh.PRIMITIVE_TRIANGLES)
	result.set_color(Color(1, 0, 0))
	
	var index_count = 0
	for y in range(tiles_2d.size()):
		for x in range(tiles_2d[y].size()):
			var tile = tiles_2d[y][x]
			var face_indices = []
			var position = Vector3(tile.x, tile.height(), tile.y)
			
			# to do: order should be top left, top right, bottom left, bottom right
			
			result.add_triangle_fan([position + TOP_LEFT, position + TOP_RIGHT,
				position + BOTTOM_LEFT, position + BOTTOM_RIGHT],
				[TOP_LEFT_UV, TOP_RIGHT_UV, BOTTOM_LEFT_UV, BOTTOM_RIGHT_UV],
				[], [], [Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP])
			
			# West wall
			if x == 0 or tiles_2d[y][x-1].height() < tile.height():
				face_indices = []
				
				var min_height = 0 if x == 0 else tiles_2d[y][x-1].height()
				var max_height = tile.height()
				
				result.add_triangle_fan([Vector3(position.x, min_height, position.z),
					Vector3(position.x, max_height, position.z),
					Vector3(position.x, min_height, position.z - 1),
					Vector3(position.x, max_height, position.z - 1)],
					[TOP_LEFT_UV, TOP_RIGHT_UV, BOTTOM_LEFT_UV, BOTTOM_RIGHT_UV],
				[], [], [Vector3.LEFT, Vector3.LEFT, Vector3.LEFT, Vector3.LEFT])
				
			# East wall
			if x == tiles_2d[y].size() - 1 or tiles_2d[y][x+1].height() < tile.height():
				face_indices = []
				
				var min_height = 0 if x == tiles_2d[y].size() - 1 else tiles_2d[y][x+1].height()
				var max_height = tile.height()
				
				result.add_triangle_fan([Vector3(position.x + 1, min_height, position.z),
					Vector3(position.x + 1, max_height, position.z),
					Vector3(position.x + 1, min_height, position.z - 1),
					Vector3(position.x + 1, max_height, position.z - 1)],
					[TOP_LEFT_UV, TOP_RIGHT_UV, BOTTOM_LEFT_UV, BOTTOM_RIGHT_UV],
				[], [], [Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT])
				
			# South wall
			if y == 0 or tiles_2d[y-1][x].height() < tile.height():
				face_indices = []
				
				var min_height = 0 if y == 0 else tiles_2d[y-1][x].height()
				var max_height = tile.height()
				
				result.add_triangle_fan([Vector3(position.x, min_height, position.z),
					Vector3(position.x, max_height, position.z),
					Vector3(position.x + 1, min_height, position.z),
					Vector3(position.x + 1, max_height, position.z)],
					[TOP_LEFT_UV, TOP_RIGHT_UV, BOTTOM_LEFT_UV, BOTTOM_RIGHT_UV],
				[], [], [Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK])
				
			# North wall
			if y == tiles_2d.size()- 1 or tiles_2d[y+1][x].height() < tile.height():
				face_indices = []
				
				var min_height = 0 if y == tiles_2d.size() - 1 else tiles_2d[y+1][x].height()
				var max_height = tile.height()
				
				result.add_triangle_fan([Vector3(position.x, min_height, position.z - 1),
					Vector3(position.x, max_height, position.z - 1),
					Vector3(position.x + 1, min_height, position.z - 1),
					Vector3(position.x + 1, max_height, position.z - 1)],
					[TOP_LEFT_UV, TOP_RIGHT_UV, BOTTOM_LEFT_UV, BOTTOM_RIGHT_UV],
				[], [], [Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD])
	
	return result
 
func generate_obj():
	var vertices = []
	var normals = []
	var uvs = []
	var faces = []
 
	var tiles = [
		[Tile.new(0,0,TileType.WALL),Tile.new(1,0,TileType.WALL),Tile.new(2,0,TileType.WALL)],
		[Tile.new(0,1,TileType.WALL),Tile.new(1,1,TileType.FLOOR),Tile.new(2,1,TileType.WALL)],
		[Tile.new(0,2,TileType.WALL),Tile.new(1,2,TileType.WALL),Tile.new(2,2,TileType.WALL)],
		[Tile.new(0,3,TileType.FLOOR),Tile.new(1,3,TileType.FLOOR),Tile.new(2,3,TileType.FLOOR)],
		]
 
	const BOTTOM_LEFT = Vector3(0, 0, -1)
	const BOTTOM_RIGHT = Vector3(1, 0, -1)
	const TOP_LEFT = Vector3(0, 0, 0)
	const TOP_RIGHT = Vector3(1, 0, 0)
 
	for y in range(tiles.size()):
		for x in range(tiles[y].size()):
			var tile = tiles[y][x]
 
			var face_indices = []
 
			var position = Vector3(tile.x, tile.height(), -tile.y)
 
			vertices.append(position + TOP_LEFT)
			face_indices.append(len(vertices))
			normals.append(Vector3.UP)
			uvs.append(Vector2(0.0, 0.0))
 
			vertices.append(position + BOTTOM_LEFT)
			face_indices.append(len(vertices))
			normals.append(Vector3.UP)
			uvs.append(Vector2(0.0, 1.0))
 
			vertices.append(position + TOP_RIGHT)
			face_indices.append(len(vertices))
			normals.append(Vector3.UP)
			uvs.append(Vector2(1.0, 0.0))
 
			vertices.append(position + BOTTOM_RIGHT)
			face_indices.append(len(vertices))
			normals.append(Vector3.UP)
			uvs.append(Vector2(1.0, 1.0))
			# create the faces
			# faces must be created counter-clockwise
			faces.append([face_indices[0], face_indices[2], face_indices[1]])
			faces.append([face_indices[2], face_indices[3], face_indices[1]])
 
			# West wall
			if x == 0 or tiles[y][x-1].height() < tile.height():
				face_indices = []
 
				var min_height = 0 if x == 0 else tiles[y][x-1].height()
				var max_height = tile.height()
 
				vertices.append(Vector3(position.x, min_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.LEFT)
				uvs.append(Vector2(0, 0))
 
				vertices.append(Vector3(position.x, min_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.LEFT)
				uvs.append(Vector2(0, 1))
 
				vertices.append(Vector3(position.x, max_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.LEFT)
				uvs.append(Vector2(1, 0))
 
				vertices.append(Vector3(position.x, max_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.LEFT)
				uvs.append(Vector2(1, 1))
 
				faces.append([face_indices[2], face_indices[1], face_indices[0]])
				faces.append([face_indices[2], face_indices[3], face_indices[1]])
 
			# # East wall
			if x == tiles[y].size() - 1 or tiles[y][x+1].height() < tile.height():
				face_indices = []
 
				var min_height = 0 if x == tiles[y].size() - 1 else tiles[y][x+1].height()
				var max_height = tile.height()
 
				vertices.append(Vector3(position.x + 1, min_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.RIGHT)
				uvs.append(Vector2(0, 0))
 
				vertices.append(Vector3(position.x + 1, min_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.RIGHT)
				uvs.append(Vector2(0, 1))
 
				vertices.append(Vector3(position.x + 1, max_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.RIGHT)
				uvs.append(Vector2(1, 0))
 
				vertices.append(Vector3(position.x + 1, max_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.RIGHT)
				uvs.append(Vector2(1, 1))
 
				faces.append([face_indices[0], face_indices[1], face_indices[2]])
				faces.append([face_indices[1], face_indices[3], face_indices[2]])
 
			# South wall
			if y == 0 or tiles[y-1][x].height() < tile.height():
				face_indices = []
 
				var min_height = 0 if y == 0 else tiles[y-1][x].height()
				var max_height = tile.height()
 
				vertices.append(Vector3(position.x, min_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.BACK)
				uvs.append(Vector2(0, 0))
 
				vertices.append(Vector3(position.x + 1, min_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.BACK)
				uvs.append(Vector2(0, 1))
 
				vertices.append(Vector3(position.x, max_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.BACK)
				uvs.append(Vector2(1, 0))
 
				vertices.append(Vector3(position.x + 1, max_height, position.z))
				face_indices.append(len(vertices))
				normals.append(Vector3.BACK)
				uvs.append(Vector2(1, 1))
 
				faces.append([face_indices[0], face_indices[1], face_indices[2]])
				faces.append([face_indices[1], face_indices[3], face_indices[2]])
 
			# North wall
			if y == tiles.size()- 1 or tiles[y+1][x].height() < tile.height():
				face_indices = []
 
				var min_height = 0 if y == tiles.size() - 1 else tiles[y+1][x].height()
				var max_height = tile.height()
 
				vertices.append(Vector3(position.x, min_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.FORWARD)
				uvs.append(Vector2(0, 0))
 
				vertices.append(Vector3(position.x + 1, min_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.FORWARD)
				uvs.append(Vector2(0, 1))
 
				vertices.append(Vector3(position.x, max_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.FORWARD)
				uvs.append(Vector2(1, 0))
 
				vertices.append(Vector3(position.x + 1, max_height, position.z - 1))
				face_indices.append(len(vertices))
				normals.append(Vector3.FORWARD)
				uvs.append(Vector2(1, 1))
 
				faces.append([face_indices[2], face_indices[1], face_indices[0]])
				faces.append([face_indices[2], face_indices[3], face_indices[1]])
 
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
	for face in faces:
		file.store_line("f %d %d %d" % [face[0], face[1], face[2]])
	file.close()
 
func _ready():
	#generate_obj()
	var mesh = ArrayMesh.new()
	
	var surface_tool = generate_surface_tool()
	#surface_tool.optimize_indices_for_cache()
	#surface_tool.generate_normals(false)
	surface_tool.commit(mesh)
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

#func _process(delta):
#	timer += delta
#	if timer >= interval:
#		mesh_instance.rotate_y(1)
#		timer = 0.0
