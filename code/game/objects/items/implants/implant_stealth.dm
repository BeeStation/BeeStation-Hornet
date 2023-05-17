/obj/item/implant/stealth
	name = "S3 implant"
	desc = "Allows you to be hidden in plain sight."
	actions_types = list(/datum/action/item_action/agent_box)

/obj/item/implanter/stealth
	name = "implanter (stealth)"
	imp_type = /obj/item/implant/stealth

//Box Object

/obj/structure/closet/cardboard/agent
	name = "inconspicious box"
	desc = "It's so normal that you didn't notice it before."
	icon_state = "agentbox"
	max_integrity = 1 // "This dumb box shouldn't take more than one hit to make it vanish."
	move_speed_multiplier = 0.5
	var/mutable_appearance/ghost_visible_box // we'll let this box visible by ghosts

/obj/structure/closet/cardboard/agent/proc/go_invisible()
	animate(src, , alpha = 0, time = 20)
	animate(ghost_visible_box, alpha = 100, time = 20) // ghosts can see this

/obj/structure/closet/cardboard/agent/Initialize(mapload)
	. = ..()
	ghost_visible_box = mutable_appearance(icon, icon_state, INVISIBILITY_OOC_INFORMATION, src.plane)
	go_invisible()

/obj/structure/closet/cardboard/agent/open()
	. = ..()
	QDEL_NULL(ghost_visible_box)
	qdel(src)

/obj/structure/closet/cardboard/agent/process()
	alpha = max(0, alpha - 50)
	ghost_visible_box.alpha = max(100, ghost_visible_box.alpha - 25)

/obj/structure/closet/cardboard/agent/proc/reveal()
	alpha = 255
	ghost_visible_box.alpha = 255
	addtimer(CALLBACK(src, PROC_REF(go_invisible)), 10, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/structure/closet/cardboard/agent/Bump(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()

/obj/structure/closet/cardboard/agent/Bumped(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()
