extends Node

const manual_levels = [
	{"wall_matrix": [[1,1,0,1,1],
					[1,1,0,1,1],
					[1,1,1,1,1],
					[1,1,1,1,1],
					[1,1,1,1,1],], "path": [1], "holes_amount": 2, "star_position": Vector3(2,1,0), "bomb_powerup": false, "slow_powerup": false},
	
	{"wall_matrix": [[1,1,0,1,1],
					[1,1,0,0,1],
					[1,1,1,1,1],
					[1,1,1,1,1],
					[1,1,1,1,1],], "path": [1,2], "holes_amount": 3, "star_position": Vector3(3,1,0), "bomb_powerup": false, "slow_powerup": false},
	
	{"wall_matrix": [[1,1,0,1,1],
					[1,1,0,0,1],
					[1,1,1,0,1],
					[1,1,1,0,1],
					[1,1,1,1,1],], "path": [1,2,1,1], "holes_amount": 5, "star_position": Vector3(3,3,0), "bomb_powerup": false, "slow_powerup": false},
	
	{"wall_matrix": [[1,0,1,1,1,1],
					[1,0,1,1,1,1],
					[1,0,1,1,1,1],
					[1,0,0,0,0,1],
					[1,1,1,1,1,1],], "path": [1,1,1,2,2,2], "holes_amount": 7, "star_position": Vector3(4,3,0), "bomb_powerup": false, "slow_powerup": false},
	
	{"wall_matrix": [[1,0,1,1,1,1],
					[1,0,1,1,0,1],
					[1,0,1,1,0,1],
					[1,0,0,0,0,1],
					[1,1,1,1,1,1],], "path": [1,1,1,2,2,2,3,3], "holes_amount": 9, "star_position": Vector3(4,1,0), "bomb_powerup": false, "slow_powerup": false},
]
