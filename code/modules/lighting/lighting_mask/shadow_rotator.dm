#define ROTATION_PARTS_PER_DECISECOND 1

/atom/movable/lighting_mask
	var/currentAngle = 0
	var/desiredAngle = 0

//Rotates the light source to angle degrees.
/atom/movable/lighting_mask/proc/rotate(angle = 0)
	desiredAngle = angle
	//Converting our transform is pretty simple.
	var/matrix/M = matrix()
	M.Turn(desiredAngle - currentAngle)
	M *= transform
	//Overlays are in nullspace while applied, meaning their transform cannot be changed.
	//Disconnect the shadows from the overlay, apply the transform and then reapply them as an overlay.
	//Oh also since the matrix is really weird standard rotation matrices wont work here.
	overlays.Cut()
	//Disconnect from parent matrix, become a global position
	for(var/mutable_appearance/shadow as() in shadows)	//Mutable appearances are children of icon
		shadow.transform *= transform
		shadow.transform /= M
	//Apply our matrix
	transform = M
	//Readd the shadow overlays.
	overlays += shadows
	//Now we are facing this direction
	currentAngle = angle
