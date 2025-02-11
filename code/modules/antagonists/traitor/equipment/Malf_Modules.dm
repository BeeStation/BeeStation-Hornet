#define DEFAULT_DOOMSDAY_TIMER 4500
#define DOOMSDAY_ANNOUNCE_INTERVAL 600
#define MALF_ACTION_GROUP "malf"

GLOBAL_LIST_INIT(blacklisted_malf_machines, typecacheof(list(
		/obj/machinery/field/containment,
		/obj/machinery/power/supermatter_crystal,
		/obj/machinery/gravity_generator,
		/obj/machinery/doomsday_device,
		/obj/machinery/nuclearbomb,
		/obj/machinery/nuclearbomb/selfdestruct,
		/obj/machinery/nuclearbomb/syndicate,
		/obj/machinery/syndicatebomb,
		/obj/machinery/syndicatebomb/badmin,
		/obj/machinery/syndicatebomb/badmin/clown,
		/obj/machinery/syndicatebomb/empty,
		/obj/machinery/syndicatebomb/self_destruct,
		/obj/machinery/syndicatebomb/training,
		/obj/machinery/atmospherics/pipe/layer_manifold,
		/obj/machinery/atmospherics/pipe/multiz,
		/obj/machinery/atmospherics/pipe/smart,
		/obj/machinery/atmospherics/pipe/smart/manifold, //mapped one
		/obj/machinery/atmospherics/pipe/smart/manifold4w, //mapped one
		/obj/machinery/atmospherics/pipe/color_adapter,
		/obj/machinery/atmospherics/pipe/bridge_pipe,
		/obj/machinery/atmospherics/pipe/heat_exchanging/simple,
		/obj/machinery/atmospherics/pipe/heat_exchanging/junction,
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold,
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w,
		/obj/machinery/atmospherics/components/tank,
		/obj/machinery/atmospherics/components/unary/portables_connector,
		/obj/machinery/atmospherics/components/unary/passive_vent,
		/obj/machinery/atmospherics/components/unary/heat_exchanger,
		/obj/machinery/atmospherics/components/binary/valve,
		/obj/machinery/portable_atmospherics/canister,
	)))

//The malf AI action subtype. All malf actions are subtypes of this.
/datum/action/innate/ai
	name = "AI Action"
	desc = "You aren't entirely sure what this does, but it's very beepy and boopy."
	background_icon_state = "bg_tech_blue"
	button_icon_state = null
	icon_icon = 'icons/hud/actions/actions_AI.dmi'
	cooldown_group = MALF_ACTION_GROUP
	check_flags = AB_CHECK_CONSCIOUS
	/// The owner AI, so we don't have to typecast every time
	var/mob/living/silicon/ai/owner_AI
	/// If we have multiple uses of the same power
	var/uses
	/// If we automatically use up uses on each activation
	var/auto_use_uses = TRUE

/datum/action/innate/ai/New()
	..()
	if(initial(uses) > 1)
		update_desc()

/datum/action/innate/ai/Grant(mob/living/L)
	. = ..()
	if(!isAI(owner))
		WARNING("AI action [name] attempted to grant itself to non-AI mob [L.real_name] ([L.key])!")
		qdel(src)
	else
		owner_AI = owner

/datum/action/innate/ai/on_activate(mob/user, atom/target)
	SHOULD_CALL_PARENT(TRUE)
	..()
	if(auto_use_uses)
		adjust_uses(-1)
	start_cooldown()

/datum/action/innate/ai/proc/update_desc()
	desc = ("[initial(desc)] There [uses > 1 ? "are" : "is"] <b>[uses]</b> reactivation[uses > 1 ? "s" : ""] remaining.")

/datum/action/innate/ai/proc/adjust_uses(amt, silent)
	uses += amt
	update_desc()
	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining."))
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		qdel(src)

//Framework for ranged abilities that can have different effects by left-clicking stuff.
/datum/action/innate/ai/ranged
	name = "Ranged AI Action"
	auto_use_uses = FALSE //This is so we can do the thing and disable/enable freely without having to constantly add uses
	requires_target = TRUE
	unset_after_click = TRUE

/datum/action/innate/ai/ranged/adjust_uses(amt, silent)
	uses += amt
	update_desc()
	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining."))
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		Remove(owner)
		QDEL_IN(src, 100) //let any active timers on us finish up

//The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/temp
	var/processing_time = 50
	var/list/possible_modules

/datum/module_picker/New()
	possible_modules = list()
	for(var/type in typesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if((AM.power_type && AM.power_type != /datum/action/innate/ai) || AM.upgrade)
			possible_modules += AM

/datum/module_picker/proc/remove_malf_verbs(mob/living/silicon/ai/AI) //Removes all malfunction-related abilities from the target AI.
	for(var/datum/AI_Module/AM in possible_modules)
		for(var/datum/action/A in AI.actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)

/datum/module_picker/proc/use(mob/user)
	var/list/dat = list()
	dat += "<B>Select use of processing time: (currently #[processing_time] left.)</B><BR>"
	dat += "<HR>"
	dat += "<B>Install Module:</B><BR>"
	dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
	for(var/datum/AI_Module/large/module in possible_modules)
		dat += "<A href='byond://?src=[REF(src)];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[REF(src)];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	for(var/datum/AI_Module/small/module in possible_modules)
		dat += "<A href='byond://?src=[REF(src)];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[REF(src)];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	dat += "<HR>"
	if(temp)
		dat += "[temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu")
	popup.set_content(dat.Join())
	popup.open()

/datum/module_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		to_chat(A, span_warning("You are already dead!"))
		return

	for(var/datum/AI_Module/AM in possible_modules)
		if (href_list[AM.mod_pick_name])

			// Cost check
			if(AM.cost > processing_time)
				temp = "You cannot afford this module."
				to_chat(A, span_notice("You cannot afford this module."))
				break

			var/datum/action/innate/ai/action = locate(AM.power_type) in A.actions
			// Give the power and take away the money.
			if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
				AM.upgrade(A)
				possible_modules -= AM
				to_chat(A, AM.unlock_text)
				A.playsound_local(A, AM.unlock_sound, 50, 0)
				A.log_message("purchased malf module [AM.module_name] (NEW PROCESSING: [processing_time - AM.cost])", LOG_GAME)
			else
				if(AM.power_type)
					if(AM.unlock_text)
						to_chat(A, AM.unlock_text)
					if(AM.unlock_sound)
						A.playsound_local(A, AM.unlock_sound, 50, 0)
					if(!action) //Unlocking for the first time
						var/datum/action/AC = new AM.power_type
						AC.Grant(A)
						A.current_modules += new AM.type
						temp = AM.description
						if(AM.one_purchase)
							possible_modules -= AM
						A.log_message("purchased malf module [AM.module_name] (NEW PROCESSING: [processing_time - AM.cost])", LOG_GAME)
					else //Adding uses to an existing module
						action.uses += initial(action.uses)
						temp = "Additional use[action.uses > 1 ? "s" : ""] added to [action.name]!"
						action.update_desc()
						A.log_message("purchased malf module [AM.module_name] (NEW USES: [action.uses]) (NEW PROCESSING: [processing_time - AM.cost])", LOG_GAME)
			processing_time -= AM.cost

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description
	use(usr)


//The base module type, which holds info about each ability.
/datum/AI_Module
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_purchase = FALSE //If this module can only be purchased once. This always applies to upgrades, even if the variable is set to false.
	var/power_type = /datum/action/innate/ai //If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/upgrade //If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/unlock_text = span_notice("Hello World!") //Text shown when an ability is unlocked
	var/unlock_sound //Sound played when an ability is unlocked

/datum/AI_Module/proc/upgrade(mob/living/silicon/ai/AI) //Apply upgrades!
	return

/datum/AI_Module/large //Big, powerful stuff that can only be used once.
/datum/AI_Module/small //Weak, usually localized stuff with multiple uses.


//Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/AI_Module/large/nuke_station
	module_name = "Doomsday Device"
	mod_pick_name = "nukestation"
	description = "Activate the station's nuclear warhead that will disintegrate all organic life on the station after a 450 seconds delay. Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/nuke_station
	unlock_text = span_notice("You establish an encrypted connection with the on-station self-destruct terminal. You can now activate it at any time.")

/datum/action/innate/ai/nuke_station
	name = "Doomsday Device"
	desc = "Activates the Doomsday device. This is not reversible."
	button_icon_state = "doomsday_device"
	auto_use_uses = FALSE
	var/device_active

/datum/action/innate/ai/nuke_station/on_activate(mob/user, atom/target)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!istype(T) || !is_station_level(T.z))
		to_chat(owner, span_warning("You cannot activate the Doomsday device while off-station!"))
		return
	if(alert(owner, "Send arming signal? (true = arm, false = cancel)", "purge_all_life()", "confirm = TRUE;", "confirm = FALSE;") != "confirm = TRUE;")
		return
	if (device_active)
		return //prevent the AI from activating an already active doomsday
	device_active = TRUE
	set_us_up_the_bomb(owner)

/datum/action/innate/ai/nuke_station/proc/set_us_up_the_bomb(mob/living/owner)
	set waitfor = FALSE
	to_chat(owner, span_smallboldannounce("run -o -a 'selfdestruct'"))
	sleep(5)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_smallboldannounce("Running executable 'selfdestruct'..."))
	sleep(rand(10, 30))
	if(!owner || QDELETED(owner))
		return
	owner.playsound_local(owner, 'sound/misc/bloblarm.ogg', 50, 0, use_reverb = FALSE)
	to_chat(owner, span_userdanger("!!! UNAUTHORIZED SELF-DESTRUCT ACCESS !!!"))
	to_chat(owner, span_boldannounce("This is a class-3 security violation. This incident will be reported to Central Command."))
	for(var/i in 1 to 3)
		sleep(20)
		if(!owner || QDELETED(owner))
			return
		to_chat(owner, span_boldannounce("Sending security report to Central Command.....[rand(0, 9) + (rand(20, 30) * i)]%"))
	sleep(3)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_smallboldannounce("auth 'akjv9c88asdf12nb' ******************"))
	owner.playsound_local(owner, 'sound/items/timer.ogg', 50, 0, use_reverb = FALSE)
	sleep(30)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Welcome, akjv9c88asdf12nb."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(5)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_boldnotice("Arm self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0, use_reverb = FALSE)
	sleep(20)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_smallboldannounce("Y"))
	sleep(15)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_boldnotice("Confirm arming of self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(10)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_smallboldannounce("Y"))
	sleep(rand(15, 25))
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_boldnotice("Please repeat password to confirm."))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(14)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_smallboldannounce("******************"))
	sleep(40)
	if(!owner || QDELETED(owner))
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Transmitting arming signal..."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(30)
	if(!owner || QDELETED(owner))
		return
	priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", ANNOUNCER_AIMALF)
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	owner.log_message("activated malf module [name]", LOG_GAME)
	var/obj/machinery/doomsday_device/DOOM = new(owner_AI)
	owner_AI.nuking = TRUE
	owner_AI.doomsday_device = DOOM
	owner_AI.doomsday_device.start()
	for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
		P.switch_mode_to(TRACK_MALF_AI) //Pinpointers start tracking the AI wherever it goes
	qdel(src)

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	density = TRUE
	verb_exclaim = "blares"
	var/timing = FALSE
	var/obj/effect/countdown/doomsday/countdown
	var/detonation_timer
	var/next_announce

/obj/machinery/doomsday_device/Initialize(mapload)
	. = ..()
	countdown = new(src)

/obj/machinery/doomsday_device/Destroy()
	QDEL_NULL(countdown)
	STOP_PROCESSING(SSfastprocess, src)
	SSshuttle.clearHostileEnvironment(src)
	SSmapping.remove_nuke_threat(src)
	for(var/mob/living/silicon/ai/AI as anything in GLOB.ai_list)
		if(AI.doomsday_device == src)
			AI.doomsday_device = null
	return ..()

/obj/machinery/doomsday_device/proc/start()
	detonation_timer = world.time + DEFAULT_DOOMSDAY_TIMER
	next_announce = world.time + DOOMSDAY_ANNOUNCE_INTERVAL
	timing = TRUE
	countdown.start()
	START_PROCESSING(SSfastprocess, src)
	SSshuttle.registerHostileEnvironment(src)
	SSmapping.add_nuke_threat(src) //This causes all blue "circuit" tiles on the map to change to animated red icon state.

/obj/machinery/doomsday_device/proc/seconds_remaining()
	. = max(0, (round((detonation_timer - world.time) / 10)))

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || !is_station_level(T.z))
		minor_announce("DOOMSDAY DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		SSshuttle.clearHostileEnvironment(src)
		qdel(src)
		return
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(!sec_left)
		timing = FALSE
		detonate()
	else if(world.time >= next_announce)
		minor_announce("[sec_left] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		next_announce += DOOMSDAY_ANNOUNCE_INTERVAL

/obj/machinery/doomsday_device/proc/detonate()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue
		if(issilicon(L))
			continue
		to_chat(L, span_userdanger("The blast wave from [src] tears you atom from atom!"))
		L.investigate_log("has been dusted by a doomsday device.", INVESTIGATE_DEATHS)
		L.dust()
	to_chat(world, "<B>The AI cleansed the station of life with the Doomsday device!</B>")
	SSticker.force_ending = 1


//AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret Upgrade"
	mod_pick_name = "turret"
	description = "Improves the power and health of all AI turrets. This effect is permanent."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("You rewrite the turrets' code, making the most use out of them. They are now fully repaired, EMP proof and their damage has been increased. \
	Your stun projectiles turned into upgraded disabler shots.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/upgrade_turrets/upgrade(mob/living/silicon/ai/AI)
	for(var/obj/machinery/porta_turret/ai/turret in GLOB.machines)
		turret.max_integrity = 200
		turret.emp_proofing = TRUE
		turret.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
		turret.stun_projectile = /obj/projectile/beam/disabler/pass_glass //// AI defenses are often built with glass, so this is big.
		turret.stun_projectile_sound = 'sound/weapons/lasercannonfire.ogg'
		turret.lethal_projectile = /obj/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
		turret.lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'


//Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/AI_Module/large/lockdown
	module_name = "Hostile Station Lockdown"
	mod_pick_name = "lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds, briefly \
	opening all doors on the station."
	cost = 30
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/lockdown
	unlock_text = span_notice("You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.")
	unlock_sound = 'sound/machines/boltsdown.ogg'

/datum/action/innate/ai/lockdown
	name = "Lockdown"
	desc = "Closes, bolts, and depowers every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	button_icon_state = "lockdown"
	uses = 1

/datum/action/innate/ai/lockdown/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door, hostile_lockdown), owner)
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/machinery/door, disable_lockdown)), 900)

	var/obj/machinery/computer/communications/C = locate() in GLOB.machines
	if(C)
		C.post_status("alert", "lockdown")

	minor_announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.","Network Alert:", TRUE)
	to_chat(owner, span_danger("Lockdown initiated. Network reset in 90 seconds."))
	owner.log_message("activated malf module [name]", LOG_GAME)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce),
		"Automatic system reboot complete. Have a secure day.",
		"Network reset:"), 900)


//Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/AI_Module/large/destroy_rcd
	module_name = "Destroy RCDs"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/destroy_rcds
	unlock_text = span_notice("After some improvisation, you rig your onboard radio to be able to send a signal to detonate all RCDs.")
	unlock_sound = 'sound/items/timer.ogg'

/datum/action/innate/ai/destroy_rcds
	name = "Destroy RCDs"
	desc = "Detonate all non-cyborg RCDs on the station."
	button_icon_state = "detonate_rcds"
	uses = 1
	cooldown_time = 10 SECONDS

/datum/action/innate/ai/destroy_rcds/on_activate(mob/user, atom/target)
	. = ..()
	for(var/I in GLOB.rcd_list)
		if(!istype(I, /obj/item/construction/rcd/borg)) //Ensures that cyborg RCDs are spared.
			var/obj/item/construction/rcd/RCD = I
			RCD.detonate_pulse()
	owner.log_message("activated malf module [name]", LOG_GAME)
	to_chat(owner, span_danger("RCD detonation pulse emitted."))
	owner.playsound_local(owner, 'sound/machines/twobeep.ogg', 50, 0)


//Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/AI_Module/large/mecha_domination
	module_name = "Unlock Mech Domination"
	mod_pick_name = "mechjack"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b>")
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/AI_Module/large/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!


//Thermal Sensor Override: Unlocks the ability to disable all fire alarms from doing their job.
/datum/AI_Module/large/break_fire_alarms
	module_name = "Thermal Sensor Override"
	mod_pick_name = "burnpigs"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/action/innate/ai/break_fire_alarms
	unlock_text = span_notice("You replace the thermal sensing capabilities of all fire alarms with a manual override, allowing you to turn them off at will.")
	unlock_sound = 'sound/machines/FireAlarm1.ogg'

/datum/action/innate/ai/break_fire_alarms
	name = "Override Thermal Sensors"
	desc = "Disables the automatic temperature sensing on all fire alarms, making them effectively useless."
	button_icon_state = "break_fire_alarms"
	uses = 1

/datum/action/innate/ai/break_fire_alarms/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/firealarm/bellman in GLOB.machines)
		if(!is_station_level(bellman.z))
			continue
		bellman.obj_flags |= EMAGGED
		bellman.update_icon()
	for(var/obj/machinery/door/firedoor/firelock in GLOB.machines)
		if(!is_station_level(firelock.z))
			continue
		firelock.on_emag(owner_AI)
	owner.log_message("activated malf module [name]", LOG_GAME)
	to_chat(owner, span_notice("All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized."))
	owner.playsound_local(owner, 'sound/machines/terminal_off.ogg', 50, 0)


//Air Alarm Safety Override: Unlocks the ability to enable dangerous modes on all air alarms.
/datum/AI_Module/large/break_air_alarms
	module_name = "Air Alarm Safety Override"
	mod_pick_name = "allow_flooding"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use extremely dangerous environmental modes. \
					Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = TRUE
	cost = 50
	power_type = /datum/action/innate/ai/break_air_alarms
	unlock_text = span_notice("You remove the safety overrides on all air alarms, but you leave the confirm prompts open.")
	unlock_sound = 'sound/effects/space_wind.ogg'

/datum/action/innate/ai/break_air_alarms
	name = "Override Air Alarm Safeties"
	desc = "Enables extremely dangerous settings on all air alarms."
	button_icon_state = "break_air_alarms"
	uses = 1

/datum/action/innate/ai/break_air_alarms/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		if(!is_station_level(AA.z))
			continue
		AA.obj_flags |= EMAGGED
	owner.log_message("activated malf module [name]", LOG_GAME)
	to_chat(owner, span_notice("All air alarm safeties on the station have been overridden. Air alarms may now use the Flood environmental mode."))
	owner.playsound_local(owner, 'sound/machines/terminal_off.ogg', 50, 0)

//Overload Machine: Allows the AI to overload a machine, detonating it after a delay. Two uses per purchase.
/datum/AI_Module/small/overload_machine
	module_name = "Machine Overload"
	mod_pick_name = "overload"
	description = "Overheats an electrical machine, causing a small explosion and destroying it. Two uses per purchase."
	cost = 20
	power_type = /datum/action/innate/ai/ranged/overload_machine
	unlock_text = span_notice("You enable the ability for the station's APCs to direct intense energy into machinery.")
	unlock_sound = 'sound/effects/comfyfire.ogg' //definitely not comfy, but it's the closest sound to "roaring fire" we have

/datum/action/innate/ai/ranged/overload_machine
	name = "Overload Machine"
	desc = "Overheats a machine, causing a small explosion after a short time."
	button_icon_state = "overload_machine"
	uses = 2
	ranged_mousepointer = 'icons/effects/mouse_pointers/overload_machine_target.dmi'
	enable_text = span_notice("You tap into the station's powernet. Click on a machine to detonate it, or use the ability again to cancel.")
	disable_text = span_notice("You release your hold on the powernet.")

/datum/action/innate/ai/ranged/overload_machine/proc/detonate_machine(mob/living/caller, obj/machinery/to_explode)
	if(QDELETED(to_explode))
		return

	var/turf/machine_turf = get_turf(to_explode)
	message_admins("[ADMIN_LOOKUPFLW(caller)] overloaded [to_explode.name] ([to_explode.type]) at [ADMIN_VERBOSEJMP(machine_turf)].")
	log_game("[key_name(caller)] overloaded [to_explode.name] ([to_explode.type]) at [AREACOORD(machine_turf)].")
	explosion(to_explode, heavy_impact_range = 2, light_impact_range = 3)
	if(!QDELETED(to_explode)) //to check if the explosion killed it before we try to delete it
		qdel(to_explode)

/datum/action/innate/ai/ranged/overload_machine/on_activate(mob/user, atom/target)
	. = ..()
	if(!istype(target, /obj/machinery))
		to_chat(user, "<span class='warning'>You can only overload machines!</span>")
		return FALSE
	var/obj/machinery/clicked_machine = target
	if(is_type_in_typecache(clicked_machine, GLOB.blacklisted_malf_machines))
		to_chat(user, "<span class='warning'>You cannot overload that device!</span>")
		return FALSE

	//caller.playsound_local(caller, SFX_SPARKS, 50, 0)
	adjust_uses(-1)
	if(uses)
		desc = "[initial(desc)] It has [uses] use\s remaining."
		update_buttons()

	clicked_machine.audible_message(("<span class='userdanger'>You hear a loud electrical buzzing sound coming from [clicked_machine]!</span>"))
	addtimer(CALLBACK(src, PROC_REF(detonate_machine), user, clicked_machine), 5 SECONDS) //kaboom!
	to_chat(user, "<span class='danger'>Overcharging machine...</span>")
	return TRUE

//Override Machine: Allows the AI to override a machine, animating it into an angry, living version of itself.
/datum/AI_Module/small/override_machine
	module_name = "Machine Override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. Four uses."
	cost = 30
	power_type = /datum/action/innate/ai/ranged/override_machine
	unlock_text = span_notice("You procure a virus from the Space Dark Web and distribute it to the station's machines.")
	unlock_sound = 'sound/machines/airlock_alien_prying.ogg'

/datum/action/innate/ai/ranged/override_machine
	name = "Override Machine"
	desc = "Animates a targeted machine, causing it to attack anyone nearby."
	button_icon_state = "override_machine"
	uses = 4
	ranged_mousepointer = 'icons/effects/mouse_pointers/override_machine_target.dmi'
	enable_text = span_notice("You tap into the station's powernet. Click on a machine to animate it, or use the ability again to cancel.")
	disable_text = span_notice("You release your hold on the powernet.")

/datum/action/innate/ai/ranged/override_machine/New()
	. = ..()
	desc = "[desc] It has [uses] use\s remaining."

/datum/action/innate/ai/ranged/override_machine/on_activate(mob/user, atom/target)
	. = ..()
	if(user.incapacitated())
		return FALSE
	if(!istype(target, /obj/machinery))
		to_chat(user, span_warning("You can only animate machines!"))
		return FALSE
	var/obj/machinery/clicked_machine = target
	if(!clicked_machine.can_be_overridden() || is_type_in_typecache(clicked_machine, GLOB.blacklisted_malf_machines))
		to_chat(user, span_warning("That machine can't be overridden!"))
		return FALSE

	user.playsound_local(user, 'sound/misc/interference.ogg', 50, FALSE, use_reverb = FALSE)
	adjust_uses(-1)

	if(uses)
		desc = "[initial(desc)] It has [uses] use\s remaining."
		update_buttons()

	clicked_machine.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [clicked_machine]!"))
	addtimer(CALLBACK(src, PROC_REF(animate_machine), user, clicked_machine), 5 SECONDS) //kabeep!
	to_chat(user, span_danger("Sending override signal..."))
	return TRUE

/datum/action/innate/ai/ranged/override_machine/proc/animate_machine(mob/living/caller, obj/machinery/to_animate)
	if(QDELETED(to_animate))
		return

	new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(to_animate), to_animate, caller, TRUE)

//Robotic Factory: Places a large machine that converts humans that go through it into cyborgs. Unlocking this ability removes shunting.
/datum/AI_Module/large/place_cyborg_transformer
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/place_transformer
	unlock_text = span_notice("You make contact with Space Amazon and request a robotics factory for delivery.")
	unlock_sound = 'sound/machines/ping.ogg'

/datum/action/innate/ai/place_transformer
	name = "Place Robotics Factory"
	desc = "Places a machine that converts humans into cyborgs. Conveyor belts included!"
	button_icon_state = "robotic_factory"
	uses = 1
	auto_use_uses = FALSE //So we can attempt multiple times
	var/list/turfOverlays

/datum/action/innate/ai/place_transformer/New()
	..()
	for(var/i in 1 to 3)
		var/image/I = image("icon"='icons/turf/overlays.dmi')
		LAZYADD(turfOverlays, I)

/datum/action/innate/ai/place_transformer/on_activate(mob/user, atom/target)
	. = ..()
	if(!owner_AI.can_place_transformer(src))
		return
	active = TRUE
	if(alert(owner, "Are you sure you want to place the machine here?", "Are you sure?", "Yes", "No") != "Yes")
		active = FALSE
		return
	if(!owner_AI.can_place_transformer(src))
		active = FALSE
		return
	var/turf/T = get_turf(owner_AI.eyeobj)
	var/obj/machinery/transformer/conveyor = new(T)
	conveyor.masterAI = owner
	playsound(T, 'sound/effects/phasein.ogg', 100, 1)
	owner_AI.can_shunt = FALSE
	to_chat(owner, span_warning("You are no longer able to shunt your core to APCs."))
	adjust_uses(-1)
	owner.log_message("activated malf module [name]", LOG_GAME)
	owner.log_message("placed Robotic Factory at [AREACOORD(T)]", LOG_GAME)

/mob/living/silicon/ai/proc/remove_transformer_image(client/C, image/I, turf/T)
	if(C && I.loc == T)
		C.images -= I

/mob/living/silicon/ai/proc/can_place_transformer(datum/action/innate/ai/place_transformer/action)
	if(!eyeobj || !isturf(loc) || incapacitated() || !action)
		return
	var/turf/middle = get_turf(eyeobj)
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room! Make sure you are placing the machine in a clear area and on a floor."
	var/success = TRUE
	for(var/n in 1 to 3) //We have to do this instead of iterating normally because of how overlay images are handled
		var/turf/T = turfs[n]
		if(!isfloorturf(T))
			success = FALSE
		var/datum/camerachunk/C = GLOB.cameranet.getCameraChunk(T.x, T.y, T.z)
		if(!C.visibleTurfs[T])
			alert_msg = "You don't have camera vision of this location!"
			success = FALSE
		for(var/atom/movable/AM in T.contents)
			if(AM.density)
				alert_msg = "That area must be clear of objects!"
				success = FALSE
		var/image/I = action.turfOverlays[n]
		I.loc = T
		client.images += I
		I.icon_state = "[success ? "green" : "red"]Overlay" //greenOverlay and redOverlay for success and failure respectively
		addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, T), 30)
	if(!success)
		to_chat(src, span_warning("[alert_msg]"))
	return success


//Blackout: Overloads a random number of lights across the station. Three uses.
/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. Three uses."
	cost = 15
	power_type = /datum/action/innate/ai/blackout
	unlock_text = span_notice("You hook into the powernet and route bonus power towards the station's lighting.")
	unlock_sound = "sparks"

/datum/action/innate/ai/blackout
	name = "Blackout"
	desc = "Overloads lights across the station."
	button_icon_state = "blackout"
	uses = 3

/datum/action/innate/ai/blackout/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(prob(30 * apc.overload))
			apc.overload_lighting()
		else
			apc.overload++
	owner.log_message("activated malf module [name]", LOG_GAME)
	to_chat(owner, span_notice("Overcurrent applied to the powernet."))
	owner.playsound_local(owner, "sparks", 50, 0)


//Disable Emergency Lights
/datum/AI_Module/small/emergency_lights
	module_name = "Disable Emergency Lights"
	mod_pick_name = "disable_emergency_lights"
	description = "Cuts emergency lights across the entire station. If power is lost to light fixtures, they will not attempt to fall back on emergency power reserves."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/emergency_lights
	unlock_text = span_notice("You hook into the powernet and locate the connections between light fixtures and their fallbacks.")
	unlock_sound = "sparks"

/datum/action/innate/ai/emergency_lights
	name = "Disable Emergency Lights"
	desc = "Disables all emergency lighting. Note that emergency lights can be restored through reboot at an APC."
	button_icon_state = "emergency_lights"
	uses = 1

/datum/action/innate/ai/emergency_lights/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/light/L in GLOB.machines)
		if(is_station_level(L.z))
			L.no_emergency = TRUE
			INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)
		CHECK_TICK
	owner.log_message("activated malf module [name]", LOG_GAME)
	to_chat(owner, span_notice("Emergency light connections severed."))
	owner.playsound_local(owner, 'sound/effects/light_flicker.ogg', 50, FALSE)


//Reactivate Camera Network: Reactivates up to 20 cameras across the station.
/datum/AI_Module/small/reactivate_cameras
	module_name = "Reactivate Camera Network"
	mod_pick_name = "recam"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. Can be used to repair up to 20 cameras."
	cost = 10
	power_type = /datum/action/innate/ai/reactivate_cameras
	unlock_text = span_notice("You deploy nanomachines to the cameranet.")
	unlock_sound = 'sound/items/wirecutter.ogg'

/datum/action/innate/ai/reactivate_cameras
	name = "Reactivate Cameras"
	desc = "Reactivates disabled cameras across the station; remaining uses can be used later."
	button_icon_state = "reactivate_cameras"
	uses = 20
	auto_use_uses = FALSE
	cooldown_time = 3 SECONDS

/datum/action/innate/ai/reactivate_cameras/on_activate(mob/user, atom/target)
	. = ..()
	var/fixed_cameras = 0
	for(var/V in GLOB.cameranet.cameras)
		if(!uses)
			break
		var/obj/machinery/camera/C = V
		if(!C.status || C.view_range != initial(C.view_range))
			C.toggle_cam(owner_AI, 0) //Reactivates the camera based on status. Badly named proc.
			C.view_range = initial(C.view_range)
			fixed_cameras++
			uses-- //Not adjust_uses() so it doesn't automatically delete or show a message
	to_chat(owner, span_notice("Diagnostic complete! Cameras reactivated: <b>[fixed_cameras]</b>. Reactivations remaining: <b>[uses]</b>."))
	owner.playsound_local(owner, 'sound/items/wirecutter.ogg', 50, 0)
	if(uses)
		owner.log_message("activated malf module [name] (NEW USES: [uses])", LOG_GAME)
	else
		owner.log_message("activated malf module [name] (NEW USES: 0)", LOG_GAME)
	adjust_uses(0, TRUE) //Checks the uses remaining

//Upgrade Camera Network: EMP-proofs all cameras, in addition to giving them X-ray vision.
/datum/AI_Module/large/upgrade_cameras
	module_name = "Upgrade Camera Network"
	mod_pick_name = "upgradecam"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-proofing and light-amplified X-ray vision." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	one_purchase = TRUE
	cost = 35 //Decent price for omniscience!
	upgrade = TRUE
	unlock_text = span_notice("OTA firmware distribution complete! Cameras upgraded: CAMSUPGRADED. Light amplification system online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/upgrade_cameras/upgrade(mob/living/silicon/ai/AI)
	AI.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //Night-vision, without which X-ray would be very limited in power.
	AI.update_sight()

	var/upgraded_cameras = 0
	for(var/V in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = V
		var/obj/structure/camera_assembly/assembly = C.assembly_ref?.resolve()
		if(assembly)
			var/upgraded = FALSE

			if(!C.isXRay())
				C.upgradeXRay(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_xray_firmware_active and clean up isxray()
				//Update what it can see.
				GLOB.cameranet.updateVisibility(C, 0)
				upgraded = TRUE

			if(!C.isEmpProof())
				C.upgradeEmpProof(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_emp_firmware_active and clean up isemp()
				upgraded = TRUE

			if(upgraded)
				upgraded_cameras++
	unlock_text = replacetext(unlock_text, "CAMSUPGRADED", "<b>[upgraded_cameras]</b>") //This works, since unlock text is called after upgrade()

/datum/AI_Module/large/eavesdrop
	module_name = "Enhanced Surveillance"
	mod_pick_name = "eavesdrop"
	description = "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations."
	cost = 30
	one_purchase = TRUE
	upgrade = TRUE
	unlock_text = span_notice("OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/eavesdrop/upgrade(mob/living/silicon/ai/AI)
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE


//Fake Alert: Overloads a random number of lights across the station. One use.
/datum/AI_Module/small/fake_alert
	module_name = "Fake Alert"
	mod_pick_name = "fake_alert"
	description = "Assess the most probable threats to the station, and send a distracting fake alert by hijacking the station's alert and threat identification systems."
	cost = 20
	power_type = /datum/action/innate/ai/fake_alert
	unlock_text = span_notice("You gain control of the station's alert system.")
	unlock_sound = "sparks"

/datum/action/innate/ai/fake_alert
	name = "Fake Alert"
	desc = "Scare the crew with a fake alert."
	button_icon_state = "fake_alert"
	uses = 1

/datum/action/innate/ai/fake_alert/on_activate(mob/user, atom/target)
	. = ..()
	var/list/events_to_chose = list()
	for(var/datum/round_event_control/E in SSevents.control)
		if(!E.can_malf_fake_alert)
			continue
		events_to_chose[E.name] = E
	var/chosen_event = input(owner,"Send fake alert","Fake Alert") in events_to_chose
	if (!chosen_event)
		return FALSE
	var/datum/round_event_control/event_control = events_to_chose[chosen_event]
	if (!event_control)
		return FALSE
	var/datum/round_event/event_announcement = new event_control.typepath()
	event_announcement.kill()
	event_announcement.announce(TRUE)
	owner.log_message("activated malf module [name] (TYPE: [chosen_event])", LOG_GAME)
	return TRUE

#undef MALF_ACTION_GROUP
#undef DEFAULT_DOOMSDAY_TIMER
#undef DOOMSDAY_ANNOUNCE_INTERVAL
