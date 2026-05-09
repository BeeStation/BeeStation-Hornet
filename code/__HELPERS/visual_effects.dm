/**
 * Causes the passed atom / image to appear floating,
 * playing a simple animation where they move up and down by 2 pixels (looping)
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define DO_FLOATING_ANIM(target) \
	animate(target, pixel_y = 2, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE); \
	animate(pixel_y = -2, time = 1 SECONDS, flags = ANIMATION_RELATIVE)

/**
 * Stops the passed atom / image from appearing floating
 *
 * In most cases you should NOT call this manually, instead use [/datum/element/movetype_handler]!
 * This is just so you can apply the animation to things which can be animated but are not movables (like images)
 */
#define STOP_FLOATING_ANIM(target) \
	var/__final_pixel_y = 0; \
	if(ismovable(target)) { \
		var/atom/movable/__movable_target = target; \
		__final_pixel_y += __movable_target.base_pixel_y; \
	}; \
	if(isliving(target)) { \
		var/mob/living/__living_target = target; \
		__final_pixel_y += __living_target.has_offset(pixel = PIXEL_Y_OFFSET); \
	}; \
	animate(target, pixel_y = __final_pixel_y, time = 1 SECONDS)

/// The duration of the animate call in mob/living/update_transform
#define UPDATE_TRANSFORM_ANIMATION_TIME (0.2 SECONDS)

/**
 * Proc called when you want the atom to spin around the center of its icon (or where it would be if its transform var is translated)
 * By default, it makes the atom spin forever and ever at a speed of 60 rpm.
 *
 * Arguments:
 * * speed: how much it takes for the atom to complete one 360° rotation
 * * loops: how many times do we want the atom to rotate
 * * clockwise: whether the atom ought to spin clockwise or counter-clockwise
 * * segments: in how many animate calls the rotation is split. Probably unnecessary, but you shouldn't set it lower than 3 anyway.
 * * parallel: whether the animation calls have the ANIMATION_PARALLEL flag, necessary for it to run alongside concurrent animations.
 * * tag: animation tag to use, for parralel animations only
 */
/atom/proc/SpinAnimation(speed = 1 SECONDS, loops = -1, clockwise = TRUE, segments = 3, parallel = TRUE, tag = null)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	SEND_SIGNAL(src, COMSIG_ATOM_SPIN_ANIMATION, speed, loops, segments, segment)
	do_spin_animation(speed, loops, segments, segment, parallel, tag)

///Animates source spinning around itself. For docmentation on the args, check atom/proc/SpinAnimation()
/atom/proc/do_spin_animation(speed = 1 SECONDS, loops = -1, segments = 3, angle = 120, parallel = TRUE, tag = null)
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/segment_matrix = matrix(transform)
		segment_matrix.Turn(angle*i)
		matrices += segment_matrix
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loop = loops, flags = ANIMATION_PARALLEL, tag = tag)
	else
		animate(src, transform = matrices[1], time = speed, loop = loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional
