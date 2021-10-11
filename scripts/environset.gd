extends Spatial

const environs_d_meshes = [["res://models/meshes/Building_1A.mesh","res://models/meshes/Building_1B.mesh","res://models/meshes/Building_1C.mesh","res://models/meshes/Building_1D.mesh","res://models/meshes/Building_1E.mesh","res://models/meshes/Building_2A.mesh","res://models/meshes/Building_2B.mesh","res://models/meshes/Building_2C.mesh","res://models/meshes/Building_2D.mesh"],
							["res://models/meshes/Pillar_1.mesh","res://models/meshes/Pillar_2.mesh","res://models/meshes/Pillar_3.mesh"],
							["res://models/meshes/Cone_1.mesh","res://models/meshes/Cone_2.mesh","res://models/meshes/Cone_3.mesh"],
							["res://models/meshes/Rock_1.mesh","res://models/meshes/Rock_2.mesh","res://models/meshes/Rock_3.mesh","res://models/meshes/Rock_4.mesh"],
							["res://models/meshes/Building_3A.mesh","res://models/meshes/Building_3B.mesh","res://models/meshes/Building_3C.mesh","res://models/meshes/Building_3D.mesh","res://models/meshes/Building_3E.mesh","res://models/meshes/Building_4A.mesh","res://models/meshes/Building_4B.mesh","res://models/meshes/Building_4C.mesh","res://models/meshes/Building_4D.mesh","res://models/meshes/Building_4E.mesh"],
							["res://models/meshes/Cloud_4A.mesh","res://models/meshes/Cloud_4B.mesh","res://models/meshes/Cloud_4C.mesh"],]
const environs_u_meshes = [["res://models/meshes/Cloud_1A.mesh","res://models/meshes/Cloud_1B.mesh","res://models/meshes/Cloud_1C.mesh","res://models/meshes/Cloud_1D.mesh","res://models/meshes/Cloud_1E.mesh","res://models/meshes/Cloud_1F.mesh"],
							["res://models/meshes/Cloud_2A.mesh","res://models/meshes/Cloud_2B.mesh","res://models/meshes/Cloud_2C.mesh","res://models/meshes/Cloud_2D.mesh"],
							["res://models/meshes/Cloud_1A.mesh","res://models/meshes/Cloud_1B.mesh","res://models/meshes/Cloud_1C.mesh","res://models/meshes/Cloud_1D.mesh","res://models/meshes/Cloud_1E.mesh","res://models/meshes/Cloud_1F.mesh"],
							["res://models/meshes/Cloud_5A.mesh","res://models/meshes/Cloud_5B.mesh","res://models/meshes/Cloud_5C.mesh","res://models/meshes/Cloud_5D.mesh","res://models/meshes/Cloud_5E.mesh"],
							["res://models/meshes/Cloud_1A.mesh","res://models/meshes/Cloud_1B.mesh","res://models/meshes/Cloud_1C.mesh","res://models/meshes/Cloud_1D.mesh","res://models/meshes/Cloud_1E.mesh","res://models/meshes/Cloud_1F.mesh"],
							[],]

const scales = [[],[Vector3(0.5,7.692,0.5),Vector3(1,10,1),Vector3(1.5,10,1.5),],
					[Vector3(1.462,-2.769,1.462),Vector3(2.027,-1.186,2.027),Vector3(2.196,-2.196,2.196),],
					[],[],[]]

var d_children
var u_children

func put_meshes(index, level_texture):
	d_children = $DL.get_children()+$DR.get_children()
	u_children = $U.get_children()
	
	var dmeshes = []
	var umeshes = []
	
	for path in environs_d_meshes[index%len(environs_d_meshes)]:
		dmeshes.append(load(path))
	for path in environs_u_meshes[index%len(environs_u_meshes)]:
		umeshes.append(load(path))
	
	var lenD = len(dmeshes)
	for d_child in d_children:
		if randf()<0.2: continue
		var i = randi()%lenD
		d_child.mesh = dmeshes[i]
		d_child.material_override.albedo_texture = level_texture
		if index%len(environs_d_meshes)==1 or index%len(environs_d_meshes)==2:
			d_child.scale = scales[index%len(environs_d_meshes)][i]
	
	var lenU = len(umeshes)
	for u_child in u_children:
		if randf()<0.2: continue
		u_child.mesh = umeshes[randi()%lenU]
		u_child.material_override.albedo_texture = level_texture

func make_translations(env, dl, dr):
	translate(env)
	$DL.translate(dl)
	$DR.translate(dr)
