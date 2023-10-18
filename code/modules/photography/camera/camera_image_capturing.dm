/image/photo
	var/_step_x = 0
	var/_step_y = 0
	var/is_orbiting = FALSE

/image/photo/New(location, atom/A)			//Intentionally not Initialize(), to make sure the clone assumes the intended appearance in time for the camera getFlatIcon.
	if(istype(A))
		loc = location
		appearance = A.appearance
		dir = A.dir
		if(ismovable(A))
			var/atom/movable/AM = A
			_step_x = AM.step_x
			_step_y = AM.step_y
			is_orbiting = AM.orbiting ? TRUE : FALSE
	. = ..()

/obj/item/camera/proc/camera_get_icon(list/turfs, turf/center, psize_x = 96, psize_y = 96, datum/turf_reservation/clone_area, size_x, size_y, total_x, total_y)
	var/list/images = list()
	var/skip_normal = FALSE
	var/wipe_images = FALSE

	if(istype(clone_area) && total_x == clone_area.width && total_y == clone_area.height && size_x >= 0 && size_y > 0)
		var/cloned_center_x = round(clone_area.bottom_left_coords[1] + ((total_x - 1) / 2))
		var/cloned_center_y = round(clone_area.bottom_left_coords[2] + ((total_y - 1) / 2))
		for(var/t in turfs)
			var/turf/T = t
			var/offset_x = T.x - center.x
			var/offset_y = T.y - center.y
			var/turf/newT = locate(cloned_center_x + offset_x, cloned_center_y + offset_y, clone_area.bottom_left_coords[3])
			if(!(newT in clone_area.reserved_turfs))		//sanity check so we don't overwrite other areas somehow
				continue
			images += new /image/photo(newT, T)
			if(T.loc.icon_state)
				images += new /image/photo(newT, T.loc)
			for(var/i in T.contents)
				var/atom/A = i
				if(!A.invisibility || (see_ghosts && can_camera_see_atom(A)))
					images += new /image/photo(newT, A)
		skip_normal = TRUE
		wipe_images = TRUE
		center = locate(cloned_center_x, cloned_center_y, clone_area.bottom_left_coords[3])

	if(!skip_normal)
		for(var/i in turfs)
			var/turf/T = i
			images += new /image/photo(T.loc, T)
			for(var/atom/movable/A in T)
				if(A.invisibility)
					if(!(see_ghosts && can_camera_see_atom(A)))
						continue
				images += new /image/photo(A.loc, A)
			CHECK_TICK

	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(psize_x, psize_y)


	var/list/sorted = sortTim(images, GLOBAL_PROC_REF(cmp_atom_layer_asc))
	var/xcomp = FLOOR(psize_x / 2, 1) - 15
	var/ycomp = FLOOR(psize_y / 2, 1) - 15


	if(!skip_normal) //these are not clones
		for(var/Adummy in sorted)
			var/image/photo/A = Adummy
			var/xo = (A.x - center.x) * world.icon_size + A.pixel_x + xcomp + A._step_x
			var/yo = (A.y - center.y) * world.icon_size + A.pixel_y + ycomp + A._step_y
			var/icon/img = getFlatIcon(A)
			if(img)
				res.Blend(img, blendMode2iconMode(A.blend_mode), xo, yo)
			CHECK_TICK

	else
		for(var/Adummy in sorted) //these are clones
			var/image/photo/clone = Adummy
			// Center of the image in X
			var/xo = (clone.x - center.x) * world.icon_size + clone.pixel_x + xcomp + clone._step_x
			// Center of the image in Y
			var/yo = (clone.y - center.y) * world.icon_size + clone.pixel_y + ycomp + clone._step_y
			var/icon/img = getFlatIcon(clone, no_anim = TRUE)
			if(img)
				if(clone.transform) // getFlatIcon doesn't give a snot about transforms.
					var/datum/decompose_matrix/decompose = clone.transform.decompose()
					// Scale in X, Y
					if(decompose.scale_x != 1 || decompose.scale_y != 1)
						var/base_w = img.Width()
						var/base_h = img.Height()
						// scale_x can be negative
						img.Scale(base_w * abs(decompose.scale_x), base_h * decompose.scale_y)
						if(decompose.scale_x < 0)
							img.Flip(EAST)
						xo -= base_w * (decompose.scale_x - SIGN(decompose.scale_x)) / 2 * SIGN(decompose.scale_x)
						yo -= base_h * (decompose.scale_y - 1) / 2

					if(!clone.is_orbiting)
						// Rotation
						if(decompose.rotation != 0)
							img.Turn(decompose.rotation)
						// Shift
						xo += decompose.shift_x
						yo += decompose.shift_y

					else // there's no way to get real orbit animation. faking orbit animation here.
						var/ghost_rotated = rand(0, 360)
						img.Turn(-ghost_rotated)
						xo += round(cos(ghost_rotated)*25) // 25 pixels away from the centre
						yo += round(sin(ghost_rotated)*25)
						// put ghost images randomly scattered on a line of a circle
						// credit to Aramix for the circle math

				res.Blend(img, blendMode2iconMode(clone.blend_mode), xo, yo)
			CHECK_TICK

	if(!silent)
		if(istype(custom_sound))				//This is where the camera actually finishes its exposure.
			playsound(loc, custom_sound, 75, 1, -3)
		else
			playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	if(wipe_images)
		QDEL_LIST(images)
	sorted.Cut()

	return res
