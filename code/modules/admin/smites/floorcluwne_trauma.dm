/// Spawns the evil floor cluwne to terrorize people
/datum/smite/floorcluwne_trauma
	name = "Floor Cluwne (Traumatize, Non-Lethal)"

/datum/smite/floorcluwne_trauma/effect(client/user, mob/living/target)
	. = ..()
	if(!length(GLOB.heretic_sacrifice_landmarks))
		var/datum/map_template/template = new("_maps/templates/heretic_sacrifice_template.dmm", "Heretic arena")
		var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(template.width, template.height)
		template.load(locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3]))

	var/mob/living/carbon/human/H = target
	var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(get_turf(target))
	FC.force_target(H)
	FC.delete_after_target_killed = FALSE
	FC.terrorize = TRUE
