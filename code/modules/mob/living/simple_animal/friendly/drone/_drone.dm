
#define DRONE_HANDS_LAYER 1
#define DRONE_HEAD_LAYER 2
#define DRONE_TOTAL_LAYERS 2

#define DRONE_NET_CONNECT span_notice("DRONE NETWORK: [name] connected.")
#define DRONE_NET_DISCONNECT span_danger("DRONE NETWORK: [name] is not responding.")

#define MAINTDRONE	"drone_maint"
#define REPAIRDRONE	"drone_repair"
#define SCOUTDRONE	"drone_scout"

#define MAINTDRONE_HACKED "drone_maint_red"
#define REPAIRDRONE_HACKED "drone_repair_hacked"
#define SCOUTDRONE_HACKED "drone_scout_hacked"

/mob/living/simple_animal/drone
	name = "Drone"
	desc = "A maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_grey"
	icon_living = "drone_maint_grey"
	icon_dead = "drone_maint_dead"
	health = 30
	maxHealth = 30
	unsuitable_atmos_damage = 0
	wander = FALSE
	speed = 0
	healable = 0
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN | CANKNOCKDOWN)
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	speak_emote = list("chirps")
	speech_span = SPAN_ROBOT
	bubble_icon = "machine"
	initial_language_holder = /datum/language_holder/drone
	mob_size = MOB_SIZE_SMALL
	has_unlimited_silicon_privilege = 1
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_HUD, ANTAG_HUD)
	unique_name = TRUE
	faction = list(FACTION_NEUTRAL,FACTION_SILICON,FACTION_TURRET)
	dextrous = TRUE
	dextrous_hud_type = /datum/hud/dextrous/drone
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 7
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_items = list(null, null)
	var/staticChoice = "static"
	var/list/staticChoices = list("static", "blank", "letter", "animal")
	var/picked = FALSE //Have we picked our visual appearance (+ colour if applicable)
	var/colour = "grey"	//Stored drone color, so we can go back when unhacked.
	var/list/drone_overlays[DRONE_TOTAL_LAYERS]
	var/laws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. Your goals are to actively build, maintain, repair, improve, and provide power to the best of your abilities within the facility that housed your activation." //for derelict drones so they don't go to station.
	var/heavy_emp_damage = 25 //Amount of damage sustained if hit by a heavy EMP pulse

	///Alarm listener datum, handes caring about alarm events and such
	var/datum/alarm_listener/listener

	var/obj/item/internal_storage //Drones can store one item, of any size/type in their body
	var/obj/item/head
	var/obj/item/default_storage = /obj/item/storage/backpack/duffelbag/drone //If this exists, it will spawn in internal storage
	var/obj/item/default_hatmask //If this exists, it will spawn in the hat/mask slot if it can fit
	var/visualAppearance = MAINTDRONE //What we appear as
	var/hacked = FALSE //If we have laws to destroy the station
	var/flavortext = \
	"\n<big><span class='warning'>DO NOT INTERFERE WITH THE ROUND AS A DRONE OR YOU WILL BE DRONE BANNED</span></big>\n"+\
	"<span class='notify'>Drones are a ghost role that are allowed to fix the station and build things. Interfering with the round as a drone is against the rules.</span>\n"+\
	"<span class='notify'>Actions that constitute interference include, but are not limited to:</span>\n"+\
	"<span class='notify'>     - Interacting with round critical objects (IDs, weapons, contraband, powersinks, bombs, etc.)</span>\n"+\
	"<span class='notify'>     - Interacting with living beings (communication, attacking, healing, etc.)</span>\n"+\
	"<span class='notify'>     - Interacting with non-living beings (dragging bodies, looting bodies, etc.)</span>\n"+\
	"<span class='warning'>These rules are at admin discretion and will be heavily enforced.</span>\n"+\
	span_warning("<u>If you do not have the regular drone laws, follow your laws to the best of your ability.</u>")
	chat_color = "#8AB48C"

/mob/living/simple_animal/drone/Initialize(mapload)
	. = ..()
	GLOB.drones_list += src
	access_card = new /obj/item/card/id(src)
	access_card.access = get_all_accesses()

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, ITEM_SLOT_DEX_STORAGE)
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, ITEM_SLOT_HEAD)

	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

	alert_drones(DRONE_NET_CONNECT)

	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, INNATE_TRAIT)

	listener = new(list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), list(z))
	RegisterSignal(listener, COMSIG_ALARM_TRIGGERED, PROC_REF(alarm_triggered))
	RegisterSignal(listener, COMSIG_ALARM_CLEARED, PROC_REF(alarm_cleared))
	listener.RegisterSignal(src, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/datum/alarm_listener, prevent_alarm_changes))
	listener.RegisterSignal(src, COMSIG_LIVING_REVIVE, TYPE_PROC_REF(/datum/alarm_listener, allow_alarm_changes))

/mob/living/simple_animal/drone/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/drone/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(stat == DEAD)
		holder.icon_state = "huddead2"
	else if(incapacitated)
		holder.icon_state = "hudoffline"
	else
		holder.icon_state = "hudstat"

/mob/living/simple_animal/drone/Destroy()
	GLOB.drones_list -= src
	QDEL_NULL(access_card) //Otherwise it ends up on the floor!
	QDEL_NULL(listener)
	return ..()

/mob/living/simple_animal/drone/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	check_laws()

	if(flavortext)
		to_chat(src, "[flavortext]")

	if(!picked)
		pickVisualAppearance()

/mob/living/simple_animal/drone/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || client.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_silicon))
		return client.holder.auto_deadmin()
	return ..()

/mob/living/simple_animal/drone/death(gibbed)
	..(gibbed)
	if(internal_storage)
		dropItemToGround(internal_storage)
	if(head)
		dropItemToGround(head)

	alert_drones(DRONE_NET_DISCONNECT)


/mob/living/simple_animal/drone/gib()
	dust()

/mob/living/simple_animal/drone/examine(mob/user)
	. = list()

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "It has [I.examine_title(user)] in its [get_held_index_name(get_held_index_of_item(I))]."

	//Internal storage
	if(internal_storage && !(internal_storage.item_flags & ABSTRACT))
		. += "It is holding [internal_storage.examine_title(user)] in its internal storage."

	//Cosmetic hat - provides no function other than looks
	if(head && !(head.item_flags & ABSTRACT))
		. += "It is wearing [head.examine_title(user)] on its head."

	//Braindead
	if(!client && stat != DEAD)
		. += "Its status LED is blinking at a steady rate."

	//Hacked
	if(hacked)
		. += span_warning("Its display is glowing red!")

	//Damaged
	if(health != maxHealth)
		if(health > maxHealth * 0.33) //Between maxHealth and about a third of maxHealth, between 30 and 10 for normal drones
			. += span_warning("Its screws are slightly loose.")
		else //otherwise, below about 33%
			. += span_boldwarning("Its screws are very loose!")

	//Dead
	if(stat == DEAD)
		if(client)
			. += span_deadsay("A message repeatedly flashes on its display: \"REBOOT -- REQUIRED\".")
		else
			. += span_deadsay("A message repeatedly flashes on its display: \"ERROR -- OFFLINE\".")
	. += "</span>"


/mob/living/simple_animal/drone/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt maintenance drones.
	return -10


/mob/living/simple_animal/drone/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	Stun(100)
	to_chat(src, span_danger("<b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)..."))
	if(severity == 1)
		adjustBruteLoss(heavy_emp_damage)
		to_chat(src, span_userdanger("HeAV% DA%^MMA+G TO I/O CIR!%UUT!"))

/mob/living/simple_animal/drone/proc/alarm_triggered(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	to_chat(src, "--- [alarm_type] alarm detected in [source_area.name]!")

/mob/living/simple_animal/drone/proc/alarm_cleared(datum/source, alarm_type, area/source_area)
	SIGNAL_HANDLER
	to_chat(src, "--- [alarm_type] alarm in [source_area.name] has been cleared.")

/mob/living/simple_animal/drone/handle_temperature_damage()
	return

/mob/living/simple_animal/drone/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	if(affect_silicon)
		return ..()

/mob/living/simple_animal/drone/experience_pressure_difference(pressure_difference, direction)
	return

/mob/living/simple_animal/drone/bee_friendly()
	// Why would bees pay attention to drones?
	return 1

/mob/living/simple_animal/drone/electrocute_act(shock_damage, source, siemens_coeff, flags = NONE)
	return 0 //So they don't die trying to fix wiring
