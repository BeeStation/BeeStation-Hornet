/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 60, ACID = 30, STAMINA = 0, BLEED = 0)
	anchored = FALSE
	interacts_with_air = TRUE

		///Stores the gas mixture of the portable component. Don't access this directly, use return_air() so you support the temporary processing it provides
	var/datum/gas_mixture/air_contents

	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0
	var/maximum_pressure = 90 * ONE_ATMOSPHERE

	///Used to track if anything of note has happen while running process_atmos()
	var/excited = TRUE

/obj/machinery/portable_atmospherics/Initialize(mapload)
	. = ..()
	air_contents = new(volume)
	air_contents.temperature = (T20C)
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/Destroy()
	SSair.stop_processing_machine(src)
	disconnect()
	QDEL_NULL(air_contents)
	return ..()

/obj/machinery/portable_atmospherics/ex_act(severity, target)
	if(severity == 1 || target == src)
		if(resistance_flags & INDESTRUCTIBLE)
			return //Indestructable cans shouldn't release air

		//This explosion will destroy the can, release its air.
		var/turf/T = get_turf(src)
		T.assume_air(air_contents)
		T.air_update_turf(FALSE, FALSE)

	return ..()

/obj/machinery/portable_atmospherics/analyzer_act(mob/living/user, obj/item/I)
	if(..() && holding)
		return atmosanalyzer_scan(user, holding, TRUE)

/obj/machinery/portable_atmospherics/process_atmos()
	excited = (excited | air_contents.react(src))
	if(!excited)
		return PROCESS_KILL
	excited = FALSE

/obj/machinery/portable_atmospherics/return_air()
	SSair.start_processing_machine(src)
	return air_contents

/obj/machinery/portable_atmospherics/return_analyzable_air()
	return air_contents

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != get_turf(src))
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	var/datum/pipeline/connected_port_parent = connected_port.parents[1]
	connected_port_parent.reconcile_air()

	set_anchored(TRUE) //Prevent movement
	pixel_x = new_port.pixel_x
	pixel_y = new_port.pixel_y

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/Move()
	. = ..()
	if(.)
		disconnect()

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	pixel_x = 0
	pixel_y = 0

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, !ismonkey(user)) || !can_interact(user))
		return
	if(holding)
		to_chat(user, "<span class='notice'>You remove [holding] from [src].</span>")
		replace_tank(user, TRUE)

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	if(holding)
		. += "<span class='notice'>\The [src] contains [holding]. Alt-click [src] to remove it.</span>\n"+\
			"<span class='notice'>Click [src] with another gas tank to hot swap [holding].</span>"

/obj/machinery/portable_atmospherics/proc/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	if(!user)
		return FALSE
	if(holding)
		user.put_in_hands(holding)
		UnregisterSignal(holding, COMSIG_PARENT_QDELETING)
		holding = null
	if(new_tank)
		holding = new_tank
		RegisterSignal(holding, COMSIG_PARENT_QDELETING, .proc/unregister_holding)

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		return replace_tank(user, FALSE, item)
	return ..()

/obj/machinery/portable_atmospherics/wrench_act(mob/living/user, obj/item/wrench)
	if(machine_stat & BROKEN)
		return FALSE
	if(connected_port)
		investigate_log("was disconnected from [connected_port] by [key_name(user)].", INVESTIGATE_ATMOS)
		disconnect()
		wrench.play_tool_sound(src)
		user.visible_message( \
			"[user] disconnects [src].", \
			"<span class='notice'>You unfasten [src] from the port.</span>", \
			"<span class='hear'>You hear a ratchet.</span>")
		update_appearance()
		return TRUE
	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(!possible_port)
		to_chat(user, "<span class='notice'>Nothing happens.</span>")
		return FALSE
	if(!connect(possible_port))
		to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
		return FALSE
	wrench.play_tool_sound(src)
	user.visible_message( \
		"[user] connects [src].", \
		"<span class='notice'>You fasten [src] to the port.</span>", \
		"<span class='hear'>You hear a ratchet.</span>")
	update_appearance()
	investigate_log("was connected to [possible_port] by [key_name(user)].", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/portable_atmospherics/attacked_by(obj/item/I, mob/user)
	if(I.force < 10 && !(machine_stat & BROKEN))
		take_damage(0)
	else
		investigate_log("was smacked with \a [I] by [key_name(user)].", INVESTIGATE_ATMOS)
		add_fingerprint(user)
		..()

/// Holding tanks can get to zero integrity and be destroyed without other warnings due to pressure change.
/// This checks for that case and removes our reference to it.
/obj/machinery/portable_atmospherics/proc/unregister_holding()
	SIGNAL_HANDLER

	UnregisterSignal(holding, COMSIG_PARENT_QDELETING)
	holding = null
