/obj/effect/spawner/randomvend
	icon = 'icons/obj/vending.dmi'
	name = "spawn random vending machine"// THIS IS A PARENT, only use the subtype vendors
	desc = "Automagically transforms into a random vendor. If you see this while in a shift, please create a bug report."
	///whether it hacks the vendor on spawn currently used only by stinky mapedits
	var/hacked = FALSE

/obj/effect/spawner/randomvend/snack
	icon_state = "random_snack"
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomvend/snack/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/snack))
	var/obj/machinery/vending/snack/vend = new random_vendor(loc)
	vend.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL


/obj/effect/spawner/randomvend/cola
	icon_state = "random_cola"
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomvend/cola/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/cola))
	var/obj/machinery/vending/cola/vend = new random_vendor(loc)
	vend.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/deputy_vend
	name = "Deputy vendor"
	desc = "Spawns a deputy vendor if the station is lowpop."
	icon = 'icons/obj/vending.dmi'
	icon_state = "dep-broken"

/obj/effect/spawner/deputy_vend/Initialize(mapload)
	. = ..()
	if (!mapload)
		new /obj/machinery/vending/deputy(loc)
		return INITIALIZE_HINT_QDEL
	if (!SSticker.current_state >= GAME_STATE_PLAYING)
		check_spawn()
		return
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(check_spawn)))

/obj/effect/spawner/deputy_vend/proc/check_spawn()
	if ((SSjob.is_job_empty(JOB_NAME_SECURITYOFFICER) && SSjob.is_job_empty(JOB_NAME_HEADOFSECURITY) && SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT) || SSjob.initial_players_to_assign < MINPOP_JOB_LIMIT)
		new /obj/machinery/vending/deputy(loc)
	qdel(src)
