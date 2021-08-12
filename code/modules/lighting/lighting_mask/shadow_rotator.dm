#define ROTATION_PARTS_PER_DECISECOND 1

/atom/movable/lighting_mask
	var/currentAngle = 0
	var/desiredAngle = 0

//Rotates the light source to angle degrees.
/atom/movable/lighting_mask/proc/rotate(angle = 0, time = 2)
	desiredAngle = angle
	//Converting our transform is pretty simple.
	var/matrix/M = matrix()
	M.Turn(desiredAngle - currentAngle)
	M *= transform
	//Apply our matrix
	animate(src, time = time, transform = M)
	//Now we are facing this direction
	currentAngle = angle
