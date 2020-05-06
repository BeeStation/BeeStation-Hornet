/obj/effect/landmark/beach
	name = "supermatter cascade exit"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE


/obj/singularity/cascade/exit
	name = "bluespace rift"
	desc = "GET TO THE RIFT!!!"
	move_self = 0
	dissipate = 0 
	current_size = STAGE_FIVE
	allowed_size = STAGE_FIVE
	//var/datum/map_template/exit
	var/obj/effect/landmark/beach/exit
	icon = 'icons/obj/rift.dmi'
	icon_state = "rift"
	pixel_x = -128
	pixel_y = -128

/obj/singularity/cascade/exit/Initialize(mapload, starting_energy)
	. = ..()
	/*exit = new /datum/map_template/ruin/lavaland/biodome/beach
	exit.keep_cached_map = TRUE
	exit.load_new_z()*/
	exit = locate(/obj/effect/landmark/beach) in GLOB.landmarks_list
	set_light(10)

/obj/singularity/cascade/exit/ex_act(severity, target)
	return

/obj/singularity/cascade/exit/consume(atom/A)
	if(istype(A, /turf/closed/indestructible/supermatter/wall))
		return
	if (ismob(A))
		do_teleport(A, get_turf(exit), 0, null, null, null, null, TRUE)
		var/mob/M = A
		to_chat(M, "<span class='big blue'>You made it. You feel as though it's all going to be OK, in the end.</span>")
		return
	qdel(A)
	//if (iscarbon(A))
	
/obj/singularity/cascade/exit/process()
	eat()