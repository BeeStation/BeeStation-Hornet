/obj/effect/spawner/random/vending
	name = "machinery spawner"
	desc = "Randomized electronics for extra fun."
	/// whether it hacks the vendor on spawn (only used for mapedits)
	var/hacked = FALSE

/obj/effect/spawner/random/vending/make_item(spawn_loc, type_path_to_make)
	var/obj/machinery/vending/vending = ..()
	if(istype(vending))
		vending.extended_inventory = hacked

	return vending

/obj/effect/spawner/random/vending/snackvend
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."
	icon_state = "snack"
	loot_type_path = /obj/machinery/vending/snack
	loot = list()

/obj/effect/spawner/random/vending/colavend
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."
	icon_state = "cola"
	loot_type_path = /obj/machinery/vending/cola
	loot = list()

/obj/effect/spawner/random/vending/deputy_vend
	name = "Deputy vendor"
	desc = "Spawns a deputy vendor if the station is lowpop."
	icon = 'icons/obj/vending.dmi'
	icon_state = "dep-broken"
	loot_type_path = /obj/machinery/vending/deputy
	loot = list()

/obj/effect/spawner/random/vending/deputy_vend/Initialize(mapload)
	. = ..()
	if (!SSticker.current_state >= GAME_STATE_PLAYING)
		check_spawn()
		return
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(check_spawn)))

/obj/effect/spawner/random/vending/deputy_vend/proc/check_spawn()
	if ((SSjob.is_job_empty(JOB_NAME_SECURITYOFFICER) && SSjob.is_job_empty(JOB_NAME_HEADOFSECURITY) && SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT) || SSjob.initial_players_to_assign < MINPOP_JOB_LIMIT)
		new /obj/machinery/vending/deputy(loc)
	qdel(src)
