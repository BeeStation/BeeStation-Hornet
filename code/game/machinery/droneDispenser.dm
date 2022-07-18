#define DRONE_MINIMUM_AGE 14
#define DRONE_PRODUCTION "production"
#define DRONE_RECHARGING "recharging"
#define DRONE_READY "ready"

/obj/machinery/droneDispenser
	name = "drone dispenser"
	desc = "A hefty machine that, when supplied with iron and glass, creates a shell whenever it finds a suitable AI matrix on the extranet."

	icon = 'icons/obj/machines/droneDispenser.dmi'
	icon_state = "on"
	density = TRUE

	max_integrity = 250
	integrity_failure = 80
	
	var/icon_off = "off"
	var/icon_on = "on"
	var/icon_recharging = "recharge"
	var/icon_creating = "make"
	var/response_timer_id = null
	var/approval_time = 600 //1 minute

	// Mats and how much we are using
	var/list/using_materials
	var/starting_amount = 0
	var/iron_cost = 5000
	var/glass_cost = 5000
	var/power_used = 1000

	var/mode = DRONE_READY
	var/timer
	var/cooldownTime = 3000 //5 minutes

	var/mob/applicant = null

	var/work_sound = 'sound/items/rped.ogg'
	var/create_sound = 'sound/items/deconstruct.ogg'
	var/recharge_sound = 'sound/machines/ping.ogg'
	var/reject_sound = 'sound/machines/buzz-two.ogg'
	var/break_sound = 'sound/machines/warning-buzzer.ogg'

/obj/machinery/droneDispenser/Initialize(mapload)
	. = ..()
	var/datum/component/material_container/materials = AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass), MINERAL_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, TRUE, /obj/item/stack)
	materials.insert_amount_mat(starting_amount)
	materials.precise_insertion = TRUE
	using_materials = list(/datum/material/iron = iron_cost, /datum/material/glass = glass_cost)

/obj/machinery/droneDispenser/preloaded
	starting_amount = 20000

/obj/machinery/droneDispenser/examine(mob/user)
	. = ..()
	switch(mode)
		if(DRONE_READY)
			. += "<span class='warning'>It seems to be computing, no doubt searching for a suitable AI matrix.</span>"
		if(DRONE_PRODUCTION)
			. += "<span class='warning'>It's whirring violently.</span>"
		if(DRONE_RECHARGING)
			. += "<span class='warning'>It seems inactive, it's probably recharging.</span>"

/obj/machinery/droneDispenser/power_change()
	..()
	update_icon()

/obj/machinery/droneDispenser/process()
	if((stat & (NOPOWER|BROKEN)) || !anchored)
		return

	//handling recharging, this feels terrible, but it works.
	if(timer > world.time && !mode == DRONE_RECHARGING)
		mode = DRONE_RECHARGING
	if(timer < world.time && mode == DRONE_RECHARGING)
		mode = DRONE_READY
		audible_message("<span class='warning'>[src] pings.</span>")
		playsound(src, recharge_sound, 50, 1)

	update_icon()
	
/obj/machinery/droneDispenser/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "off"
	else if(mode == DRONE_RECHARGING)
		icon_state = "recharge"
	else if(mode == DRONE_PRODUCTION)
		icon_state = "make"
	else
		icon_state = "on"

/obj/machinery/droneDispenser/attackby(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_CROWBAR)
		var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
		materials.retrieve_all()
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You retrieve the materials from [src].</span>")

	else if(I.tool_behaviour == TOOL_WELDER)
		if(!(stat & BROKEN))
			to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
			return

		if(!I.tool_start_check(user, amount=1))
			return

		user.visible_message(
			"<span class='notice'>[user] begins patching up [src] with [I].</span>",
			"<span class='notice'>You begin restoring the damage to [src]...</span>")

		if(!I.use_tool(src, user, 40, volume=50, amount=1))
			return

		user.visible_message(
			"<span class='notice'>[user] fixes [src]!</span>",
			"<span class='notice'>You restore [src] to operation.</span>")

		stat &= ~BROKEN
		obj_integrity = max_integrity
	else if(user)
		return ..()

/obj/machinery/droneDispenser/attack_ghost(mob/user)
	//don't do anything if not ready
	if(mode == DRONE_READY)
		//check if they're banned from it
		if(is_banned_from(user.ckey, ROLE_DRONE) || QDELETED(src) || QDELETED(user))
			return

		//job age restriction checks
		if(CONFIG_GET(flag/use_age_restriction_for_jobs))
			if(!isnum_safe(user.client.player_age))
				return
			if(user.client.player_age < DRONE_MINIMUM_AGE)
				to_chat(user, "<span class='danger'>You're too new to play as a drone! Please try again in [DRONE_MINIMUM_AGE - user.client.player_age] days.</span>")
				return

		//making sure you can't do it before roundstart
		if(!SSticker.mode)
			to_chat(user, "<span class='danger'>Can't become a drone before the game has started.</span>")
			return

		//if you're already applied, don't allow it again
		if(response_timer_id)
			to_chat(user, "<span class='danger'>You can't apply for a drone spawn while someone is already waiting.</span>")
			return

		//no admins, no drones.
		var/list/admin_list = get_admin_counts(R_BAN)
		if(!length(admin_list["present"]))
			to_chat(user, "<span class='danger'>Can't become a drone without administrators online.</span>")
			return

		//here's the real meat
		var/be_drone = alert("Apply to become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
		if(be_drone == "No" || QDELETED(src) || !isobserver(user))
			return
		applicant = user

		//Start timer and ask the admins for their highly valued opinion
		response_timer_id = addtimer(CALLBACK(src, .proc/produce_drone), approval_time, TIMER_STOPPABLE)
		to_chat(GLOB.admins, "<span class='adminnotice'><b><font color=orange>DRONE BODY REQUEST:</font></b>[ADMIN_LOOKUPFLW(user)] intends to inhabit a drone body printed from [src] in [AREACOORD(src)] (will autoapprove in [DisplayTimeText(approval_time)]). (<A HREF='?_src_=holder;[HrefToken(TRUE)];reject_drone_application=[REF(src)]'>REJECT</A>) </span>")
		to_chat(user, "<span class='danger'>Your application has been sent to the administrators.</span>")
		log_admin("[user] has applied for drone body printed from [src] in [AREACOORD(src)]")	

		//move it to production state
		mode = DRONE_PRODUCTION
		audible_message("<span class='warning'>[src] whirs to life!</span>")
		playsound(src, work_sound, 50, 1)
	else
		return

/obj/machinery/droneDispenser/proc/reject(user)
	//if no user or timer, ignore.
	if(!user)
		return
	if(!response_timer_id)
		return

	//logging and such
	var/m = "[key_name(user)] has rejected a drone body application."
	message_admins(m)
	log_admin(m)
		
	//reset timer
	deltimer(response_timer_id)
	response_timer_id = null

	//tell the poor sod we don't want him
	to_chat(applicant, "<span class='danger'>Your application has been denied by an administrator.</span>")

	applicant = null

	//move it to ready state
	mode = DRONE_READY
	audible_message("<span class='warning'>[src] buzzes.</span>")
	playsound(src, reject_sound, 50, 1)

/obj/machinery/droneDispenser/proc/produce_drone()
	//if no user, ignore
	if(!applicant)
		return

	//reset timer
	deltimer(response_timer_id)
	response_timer_id = null

	//do we even have the mats needed?
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(!materials.has_materials(using_materials))
		mode = DRONE_READY
		audible_message("<span class='warning'>[src] buzzes.</span>")
		playsound(src, reject_sound, 50, 1)
		return // We require more minerals

	//use the mats, make the mob and move the ghost into it
	materials.use_materials(using_materials)
	use_power(power_used)
	var/mob/living/simple_animal/drone/D = new /mob/living/simple_animal/drone(get_turf(loc))
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.ckey = applicant.ckey

	//logging!
	message_admins("[applicant] has taken ownership of a drone body printed from [src] in [AREACOORD(src)]")
	log_admin("[applicant] has taken ownership of a drone body printed from [src] in [AREACOORD(src)]")

	applicant = null

	//move it to recharge state and start timer
	mode = DRONE_RECHARGING
	audible_message("<span class='warning'>[src] dispenses a drone.</span>")
	playsound(src, create_sound, 50, 1)
	timer = world.time + cooldownTime

/obj/machinery/droneDispenser/obj_break(damage_flag)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			audible_message("<span class='warning'>[src] lets out a tinny alarm before falling dark.</span>")
			playsound(src, break_sound, 50, 1)
			stat |= BROKEN

/obj/machinery/droneDispenser/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 5)
	qdel(src)

#undef DRONE_PRODUCTION
#undef DRONE_RECHARGING
#undef DRONE_READY
