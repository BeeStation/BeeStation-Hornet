//Something to allow a mask to be rotated while retaining the position of the shadows.
//Should be theoretically pretty simple, however mutable_appearances dont accept modifications
//to their transform.

#define ROTATION_PARTS_PER_DECISECOND 2

/atom/movable/lighting_mask/alpha/proc/rotate(angle = 0, time = 0)
	if(time > 0)
		INVOKE_ASYNC(src, .proc/async_rotation_animation, angle, time)
		return
	//Converting our transform is pretty simple.
	var/matrix/M = matrix()
	M.Turn(angle)
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

//Kind of dodgy, but this is a way to manually do animate, since animate(shadow, ...)
//throws a 'nothing to animate' error, meaning we have to animate by parts ourselves.
//Drawback: This animation only runs at 10 FPS.
/atom/movable/lighting_mask/alpha/proc/async_rotation_animation(angle = 0, time = 0)
	var/current_part = 0
	var/matrix/M = matrix()
	M.Turn(angle / (time * ROTATION_PARTS_PER_DECISECOND))
	while(current_part < time * ROTATION_PARTS_PER_DECISECOND)
		//Increase the current part of the animation
		current_part ++
		//Cut the overlays so we can update their transform
		overlays.Cut()
		//Update the transform for shadows
		for(var/mutable_appearance/shadow as() in shadows)	//Mutable appearances are children of icon
			shadow.transform *= transform
			shadow.transform /= M * transform
		//Reapply transformed overlays
		overlays += shadows
		//Transform ourselves
		transform = M * transform
		sleep(1 / ROTATION_PARTS_PER_DECISECOND)
