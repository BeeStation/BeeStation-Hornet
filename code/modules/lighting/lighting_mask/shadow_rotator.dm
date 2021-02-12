//Something to allow a mask to be rotated while retaining the position of the shadows.
//Should be theoretically pretty simple, however mutable_appearances dont accept modifications
//to their transform.

/atom/movable/lighting_mask/alpha/proc/rotate(angle = 0)
	//Converting our transform is pretty simple.
	var/matrix/M = matrix()
	M.Turn(angle)
	//Overlays are in nullspace while applied, meaning their transform cannot be changed.
	//Disconnect the shadows from the overlay, apply the transform and then reapply them as an overlay.
	//Oh also since the matrix is really weird standard rotation matrices wont work here.
	overlays.Cut()
	//Disconnect from parent matrix, become a global position
	for(var/mutable_appearance/shadow as() in shadows)	//Mutable appearances are children of icon
		shadow.transform *= transform
	//Apply our matrix
	transform = M.Multiply(transform)
	//Reconnect to parent matrix, become a local position from global
	for(var/mutable_appearance/shadow as() in shadows)	//Mutable appearances are children of icon
		shadow.transform /= transform
	//Readd the shadow overlays.
	overlays += shadows
