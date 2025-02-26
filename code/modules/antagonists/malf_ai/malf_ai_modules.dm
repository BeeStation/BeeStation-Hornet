#define DEFAULT_DOOMSDAY_TIMER 450 SECONDS
#define DOOMSDAY_ANNOUNCE_INTERVAL 60 SECONDS

#define MALF_VENDOR_TIPPING_TIME 0.5 SECONDS //within human reaction time
#define MALF_VENDOR_TIPPING_CRIT_CHANCE 100 //percent - guaranteed

#define MALF_AI_ROLL_TIME 0.5 SECONDS
#define MALF_AI_ROLL_COOLDOWN 1 SECONDS + MALF_AI_ROLL_TIME
#define MALF_AI_ROLL_DAMAGE 75
#define MALF_AI_ROLL_CRIT_CHANCE 5

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

GLOBAL_LIST_INIT(malf_modules, subtypesof(/datum/ai_module/malf))

/// The malf AI action subtype. All malf actions are subtypes of this.
/datum/action/innate/ai
	name = "AI Action"
	desc = "You aren't entirely sure what this does, but it's very beepy and boopy."
	background_icon_state = "bg_tech_blue"
	button_icon_state = null
	icon_icon = 'icons/hud/actions/actions_AI.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// The owner AI, so we don't have to typecast every time
	var/mob/living/silicon/ai/owner_AI
	/// Amount of uses for this action. Defining this as 0 will make this infinite-use
	var/uses = 0
	/// If we automatically use up uses on each activation
	var/auto_use_uses = TRUE

/datum/action/innate/ai/Grant(mob/living/player)
	. = ..()
	if(!isAI(owner))
		WARNING("AI action [name] attempted to grant itself to non-AI mob [key_name(player)]!")
		qdel(src)
	else
		owner_AI = owner

/datum/action/innate/ai/is_available(feedback = FALSE)
	if(owner_AI && !COOLDOWN_FINISHED(owner_AI, malf_cooldown))
		return FALSE
	. = ..()

/datum/action/innate/ai/on_activate(mob/user, atom/target)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(auto_use_uses)
		adjust_uses(-1)
	if(uses)
		start_cooldown()
	user.log_message("activated malf module [name]", LOG_GAME)

/datum/action/innate/ai/New()
	. = ..()
	desc = desc + (uses ? " It has [uses] use\s remaining." : "")

/datum/action/innate/ai/proc/update_desc()
	desc = initial(desc) + (uses ? " It has [uses] use\s remaining." : "")

/datum/action/innate/ai/proc/adjust_uses(amt, silent)
	uses += amt

	update_desc()
	update_buttons()

	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining."))
	if(uses <= 0)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		qdel(src)

/// Framework for ranged abilities that can have different effects by left-clicking stuff.
/datum/action/innate/ai/ranged
	name = "Ranged AI Action"
	auto_use_uses = FALSE //This is so we can do the thing and disable/enable freely without having to constantly add uses
	requires_target = TRUE
	unset_after_click = TRUE

/datum/action/innate/ai/ranged/adjust_uses(amt, silent)
	uses += amt

	update_desc()
	update_buttons()

	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use\s remaining."))
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		Remove(owner)
		QDEL_IN(src, 10 SECONDS) //let any active timers on us finish up

/// The base module type, which holds info about each ability.
/datum/ai_module
	var/name = "generic module"
	var/category = "generic category"
	var/description = "generic description"
	var/cost = 5
	/// If this module can only be purchased once. This always applies to upgrades, even if the variable is set to false.
	var/one_purchase = FALSE
	/// If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/power_type = /datum/action/innate/ai
	/// If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/upgrade = FALSE
	/// Text shown when an ability is unlocked
	var/unlock_text = span_notice("Hello World!")
	/// Sound played when an ability is unlocked
	var/unlock_sound

/// Applies upgrades
/datum/ai_module/proc/upgrade(mob/living/silicon/ai/AI)
	return

/// Modules causing destruction
/datum/ai_module/malf/destructive
	category = "Destructive Modules"

/// Modules with stealthy and utility uses
/datum/ai_module/malf/utility
	category = "Utility Modules"

/// Modules that are improving AI abilities and assets
/datum/ai_module/malf/upgrade
	category = "Upgrade Modules"

/// Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/ai_module/malf/destructive/nuke_station
	name = "Doomsday Device"
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay. \
		Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/nuke_station
	unlock_text = span_notice("You slowly, carefully, establish a connection with the on-station self-destruct. You can now activate it at any time.")

/datum/action/innate/ai/nuke_station
	name = "Doomsday Device"
	desc = "Activates the doomsday device. This is not reversible."
	button_icon_state = "doomsday_device"
	auto_use_uses = FALSE
	var/device_active = FALSE

/datum/action/innate/ai/nuke_station/on_activate(mob/user, atom/target)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!istype(T) || !is_station_level(T.z))
		to_chat(owner, span_warning("You cannot activate the doomsday device while off-station!"))
		return
	if(tgui_alert(owner, "Send arming signal?", "purge_all_life()", list("confirm = TRUE;", "confirm = FALSE;")) != "confirm = TRUE;")
		return
	if(device_active || owner_AI.stat == DEAD)
		return //prevent the AI from activating an already active doomsday or while they are dead
	if(!isturf(owner_AI.loc))
		return //prevent AI from activating doomsday while shunted or carded, fucking abusers
	device_active = TRUE
	start_doomsday(owner)

/datum/action/innate/ai/nuke_station/proc/start_doomsday(mob/living/owner)
	//oh my GOD.
	set waitfor = FALSE
	message_admins("[key_name_admin(owner)][ADMIN_FLW(owner)] has activated AI Doomsday.")
	var/pass = prob(10) ? "******" : "hunter2"
	to_chat(owner, span_smallboldannounce("run -o -a 'selfdestruct'"))
	sleep(0.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_smallboldannounce("Running executable 'selfdestruct'..."))
	sleep(rand(10, 30))
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	owner.playsound_local(owner, 'sound/misc/bloblarm.ogg', 50, 0, use_reverb = FALSE)
	to_chat(owner, span_userdanger("!!! UNAUTHORIZED SELF-DESTRUCT ACCESS !!!"))
	to_chat(owner, span_bolddanger("This is a class-3 security violation. This incident will be reported to Central Command."))
	for(var/i in 1 to 3)
		sleep(2 SECONDS)
		if(QDELETED(owner) || !isturf(owner_AI.loc))
			active = FALSE
			return
		to_chat(owner, span_bolddanger("Sending security report to Central Command.....[rand(0, 9) + (rand(20, 30) * i)]%"))
	sleep(0.3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_smallboldannounce("auth 'akjv9c88asdf12nb' [pass]"))
	owner.playsound_local(owner, 'sound/items/timer.ogg', 50, 0, use_reverb = FALSE)
	sleep(3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Welcome, akjv9c88asdf12nb."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(0.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Arm self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0, use_reverb = FALSE)
	sleep(2 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_smallboldannounce("Y"))
	sleep(1.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Confirm arming of self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(1 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_smallboldannounce("Y ")) // Extra space so the two Y's don't merge
	sleep(rand(15, 25))
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Please repeat password to confirm."))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(1.4 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_smallboldannounce(pass))
	sleep(4 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Transmitting arming signal..."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	if(owner_AI.stat != DEAD)
		priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", ANNOUNCER_AIMALF)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		var/obj/machinery/doomsday_device/DOOM = new(owner_AI)
		owner_AI.nuking = TRUE
		owner_AI.doomsday_device = DOOM
		owner_AI.doomsday_device.start()
		for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
			P.switch_mode_to(TRACK_MALF_AI) //Pinpointers start tracking the AI wherever it goes

		notify_ghosts(
			"[owner_AI] has activated a Doomsday Device!",
			source = owner_AI,
			header = "DOOOOOOM!!!",
		)

		qdel(src)

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	density = TRUE
	verb_exclaim = "blares"
	use_power = NO_POWER_USE
	var/timing = FALSE
	var/obj/effect/countdown/doomsday/countdown
	var/detonation_timer
	var/next_announce
	var/mob/living/silicon/ai/owner

/obj/machinery/doomsday_device/Initialize(mapload)
	. = ..()
	if(!isAI(loc))
		stack_trace("Doomsday created outside an AI somehow, shit's fucking broke. Anyway, we're just gonna qdel now. Go make a github issue report.")
		return INITIALIZE_HINT_QDEL
	owner = loc
	countdown = new(src)

/obj/machinery/doomsday_device/Destroy()
	timing = FALSE
	QDEL_NULL(countdown)
	STOP_PROCESSING(SSfastprocess, src)
	SSshuttle.clearHostileEnvironment(src)
	SSmapping.remove_nuke_threat(src)
	SSsecurity_level.set_level(SEC_LEVEL_RED)
	for(var/mob/living/silicon/robot/borg in owner?.connected_robots)
		borg.lamp_doom = FALSE
		borg.toggle_headlamp(FALSE, TRUE) //forces borg lamp to update
	owner?.doomsday_device = null
	owner?.nuking = null
	owner = null
	for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
		P.switch_mode_to(TRACK_NUKE_DISK) //Party's over, back to work, everyone
		P.alert = FALSE
	return ..()

/obj/machinery/doomsday_device/proc/start()
	detonation_timer = world.time + DEFAULT_DOOMSDAY_TIMER
	next_announce = world.time + DOOMSDAY_ANNOUNCE_INTERVAL
	timing = TRUE
	countdown.start()
	START_PROCESSING(SSfastprocess, src)
	SSshuttle.registerHostileEnvironment(src)
	SSmapping.add_nuke_threat(src) //This causes all blue "circuit" tiles on the map to change to animated red icon state.
	for(var/mob/living/silicon/robot/borg in owner.connected_robots)
		borg.lamp_doom = TRUE
		borg.toggle_headlamp(FALSE, TRUE) //forces borg lamp to update

/obj/machinery/doomsday_device/proc/seconds_remaining()
	. = max(0, (round((detonation_timer - world.time) / 10)))

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || !is_station_level(T.z))
		minor_announce("DOOMSDAY DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		owner.ShutOffDoomsdayDevice()
		return
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(!sec_left)
		timing = FALSE
		sound_to_playing_players('sound/machines/alarm.ogg')
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(Cinematic), CINEMATIC_MALF, world, CALLBACK(src, PROC_REF(trigger_doomsday))), 10 SECONDS)

	else if(world.time >= next_announce)
		minor_announce("[sec_left] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		next_announce += DOOMSDAY_ANNOUNCE_INTERVAL

/obj/machinery/doomsday_device/proc/trigger_doomsday()
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
	to_chat(world, span_bold("The AI cleansed the station of life with the Doomsday device!"))
	SSticker.force_ending = 1

/// Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/ai_module/malf/destructive/lockdown
	name = "Hostile Station Lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. \
		Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds, briefly \
		opening all doors on the station."
	cost = 30
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/lockdown
	unlock_text = span_notice("You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.")
	unlock_sound = 'sound/machines/boltsdown.ogg'

/datum/action/innate/ai/lockdown
	name = "Lockdown"
	desc = "Closes, bolts, and electrifies every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	button_icon_state = "lockdown"
	uses = 1

/datum/action/innate/ai/lockdown/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/door/airlock in GLOB.airlocks)
		if(QDELETED(airlock) || !is_station_level(airlock.z))
			continue
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, hostile_lockdown), owner)
		addtimer(CALLBACK(airlock, TYPE_PROC_REF(/obj/machinery/door, disable_lockdown)), 90 SECONDS)

	var/obj/machinery/computer/communications/random_comms_console = locate() in GLOB.shuttle_caller_list
	random_comms_console?.post_status("alert", "lockdown")

	minor_announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert:", TRUE)
	to_chat(owner, span_danger("Lockdown initiated. Network reset in 90 seconds."))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce),
		"Automatic system reboot complete. Have a secure day.",
		"Network reset:"), 90 SECONDS)

/// Override Machine: Allows the AI to override a machine, animating it into an angry, living version of itself.
/datum/ai_module/malf/destructive/override_machine
	name = "Machine Override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. Four uses per purchase."
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

/datum/action/innate/ai/ranged/override_machine/on_activate(mob/user, atom/target)
	. = ..()
	if(user.incapacitated())
		return FALSE
	if(!ismachinery(target))
		target.balloon_alert(user, "can't animate")
		to_chat(user, span_warning("You can only animate machines!"))
		return FALSE
	var/obj/machinery/clicked_machine = target

	if(istype(clicked_machine, /obj/machinery/porta_turret_cover)) //clicking on a closed turret will attempt to override the turret itself instead of the animated/abstract cover.
		var/obj/machinery/porta_turret_cover/clicked_turret = clicked_machine
		clicked_machine = clicked_turret.parent_turret

	if((clicked_machine.resistance_flags & INDESTRUCTIBLE) || is_type_in_typecache(clicked_machine, GLOB.blacklisted_malf_machines))
		to_chat(user, span_warning("That machine can't be overridden!"))
		return FALSE

	user.playsound_local(user, 'sound/misc/interference.ogg', 50, FALSE, use_reverb = FALSE)

	clicked_machine.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [clicked_machine]!"))
	addtimer(CALLBACK(src, PROC_REF(animate_machine), user, clicked_machine), 5 SECONDS) //kabeep!
	to_chat(user, span_danger("Sending override signal..."))
	adjust_uses(-1) //adjust after we unset the active ability since we may run out of charges, thus deleting the ability

	return TRUE

/datum/action/innate/ai/ranged/override_machine/proc/animate_machine(mob/user, obj/machinery/to_animate)
	if(QDELETED(to_animate))
		return

	new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(to_animate), to_animate, user, TRUE)

/// Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/ai_module/malf/destructive/destroy_rcd
	name = "Destroy RCDs"
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
	to_chat(owner, span_danger("RCD detonation pulse emitted."))
	user.playsound_local(user, 'sound/machines/twobeep.ogg', 50, 0)

/// Overload Machine: Allows the AI to overload a machine, detonating it after a delay. Two uses per purchase.
/datum/ai_module/malf/destructive/overload_machine
	name = "Machine Overload"
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

/datum/action/innate/ai/ranged/overload_machine/proc/detonate_machine(mob/user, obj/machinery/to_explode)
	if(QDELETED(to_explode))
		return

	var/turf/machine_turf = get_turf(to_explode)
	message_admins("[ADMIN_LOOKUPFLW(user)] overloaded [to_explode.name] ([to_explode.type]) at [ADMIN_VERBOSEJMP(machine_turf)].")
	user.log_message("overloaded [to_explode.name]", LOG_ATTACK)
	explosion(to_explode, heavy_impact_range = 2, light_impact_range = 3)
	if(!QDELETED(to_explode)) //to check if the explosion killed it before we try to delete it
		qdel(to_explode)

/datum/action/innate/ai/ranged/overload_machine/on_activate(mob/user, atom/target)
	. = ..()
	if(user.incapacitated())
		return FALSE
	if(!ismachinery(target))
		target.balloon_alert(user, "can't overload")
		to_chat(user, span_warning("You can only overload machines!"))
		return FALSE
	var/obj/machinery/clicked_machine = target

	if(istype(clicked_machine, /obj/machinery/porta_turret_cover)) //clicking on a closed turret will attempt to override the turret itself instead of the animated/abstract cover.
		var/obj/machinery/porta_turret_cover/clicked_turret = clicked_machine
		clicked_machine = clicked_turret.parent_turret

	if((clicked_machine.resistance_flags & INDESTRUCTIBLE) || is_type_in_typecache(clicked_machine, GLOB.blacklisted_malf_machines))
		to_chat(user, span_warning("You cannot overload that device!"))
		return FALSE

	user.playsound_local(user, "sound/effects/sparks1.ogg", 50, 0)
	adjust_uses(-1)

	clicked_machine.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [clicked_machine]!"))
	addtimer(CALLBACK(src, PROC_REF(detonate_machine), user, clicked_machine), 5 SECONDS) //kaboom!
	to_chat(user, span_danger("Overcharging machine..."))
	return TRUE

/// Blackout: Overloads a random number of lights across the station. Three uses.
/datum/ai_module/malf/destructive/blackout
	name = "Blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. Three uses per purchase."
	cost = 15
	power_type = /datum/action/innate/ai/blackout
	unlock_text = span_notice("You hook into the powernet and route bonus power towards the station's lighting.")
	unlock_sound = 'sound/effects/sparks1.ogg'

/datum/action/innate/ai/blackout
	name = "Blackout"
	desc = "Overloads random lights across the station."
	button_icon_state = "blackout"
	uses = 3
	auto_use_uses = FALSE

/datum/action/innate/ai/blackout/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(prob(30 * apc.overload))
			apc.overload_lighting()
		else
			apc.overload++
	to_chat(owner, span_notice("Overcurrent applied to the powernet."))
	user.playsound_local(user, "sound/effects/sparks1.ogg", 50, 0)
	adjust_uses(-1)
	if(QDELETED(src) || uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		return

/// HIGH IMPACT HONKING
/datum/ai_module/malf/destructive/megahonk
	name = "Percussive Intercomm Interference"
	description = "Emit a debilitatingly percussive auditory blast through the station intercoms. Does not overpower hearing protection. Two uses per purchase."
	cost = 20
	power_type = /datum/action/innate/ai/honk
	unlock_text = span_notice("You upload a sinister sound file into every intercom...")
	unlock_sound = 'sound/items/airhorn.ogg'

/datum/action/innate/ai/honk
	name = "Percussive Intercomm Interference"
	desc = "Rock the station's intercom system with an obnoxious HONK!"
	button_icon_state = "intercom"
	uses = 2

/datum/action/innate/ai/honk/on_activate(mob/user, atom/target)
	. = ..()
	to_chat(owner, span_clown("The intercom system plays your prepared file as commanded."))
	for(var/obj/item/radio/intercom/found_intercom as anything in GLOB.intercoms_list)
		if(!found_intercom.is_on() || !found_intercom.get_listening() || found_intercom.wires.is_cut(WIRE_RX)) //Only operating intercoms play the honk
			continue
		playsound(found_intercom, 'sound/items/airhorn.ogg', 100, TRUE)
		for(var/mob/living/carbon/honk_victim in ohearers(6, found_intercom))
			var/turf/victim_turf = get_turf(honk_victim)
			if(isspaceturf(victim_turf) && !victim_turf.Adjacent(found_intercom)) //Prevents getting honked in space
				continue
			if(honk_victim.soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 30, deafen_pwr = 60)) //Ear protection will prevent these effects
				honk_victim.jitteriness = max(honk_victim.jitteriness, 120 SECONDS)
				to_chat(honk_victim, span_clown("HOOOOONK!"))

/// Robotic Factory: Places a large machine that converts humans that go through it into cyborgs. Unlocking this ability removes shunting.
/datum/ai_module/malf/utility/place_cyborg_transformer
	name = "Robotic Factory (Removes Shunting)"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	one_purchase = TRUE
	cost = 100
	power_type = /datum/action/innate/ai/place_transformer
	unlock_text = span_notice("You make contact with Space Amazon and request a robotics factory for delivery.")
	unlock_sound = 'sound/machines/ping.ogg'

/datum/action/innate/ai/place_transformer
	name = "Place Robotics Factory"
	desc = "Places a machine that converts humans into cyborgs. Conveyor belts included!"
	button_icon_state = "robotic_factory"
	uses = 1
	auto_use_uses = FALSE //So we can attempt multiple times
	var/placing_transformer = FALSE
	var/list/turfOverlays

/datum/action/innate/ai/place_transformer/New()
	. = ..()
	for(var/i in 1 to 3)
		var/image/I = image("icon" = 'icons/turf/overlays.dmi')
		LAZYADD(turfOverlays, I)

/datum/action/innate/ai/place_transformer/on_activate(mob/user, atom/target)
	. = ..()
	if(!owner_AI.can_place_transformer(src) || placing_transformer)
		return
	placing_transformer = TRUE
	if(tgui_alert(owner, "Are you sure you want to place the machine here?", "Are you sure?", list("Yes", "No")) == "No")
		placing_transformer = FALSE
		return
	if(!owner_AI.can_place_transformer(src))
		placing_transformer = FALSE
		return
	var/turf/T = get_turf(owner_AI.eyeobj)
	var/obj/machinery/transformer/conveyor = new(T)
	conveyor.master_ai = owner
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
	if(owner_AI.can_shunt) //prevent repeated messages
		owner_AI.can_shunt = FALSE
		to_chat(owner, span_warning("You are no longer able to shunt your core to APCs."))
	adjust_uses(-1)
	placing_transformer = FALSE

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
		addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, T), 3 SECONDS)
	if(!success)
		to_chat(src, span_warning("[alert_msg]"))
	return success

/// Air Alarm Safety Override: Unlocks the ability to enable dangerous modes on all air alarms.
/datum/ai_module/malf/utility/break_air_alarms
	name = "Air Alarm Safety Override"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use extremely dangerous environmental modes. \
			Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = TRUE
	cost = 50
	power_type = /datum/action/innate/ai/break_air_alarms
	unlock_text = span_notice("You remove the safety overrides on all air alarms, but you leave the confirm prompts open. You can hit 'Yes' at any time... you bastard.")
	unlock_sound = 'sound/effects/space_wind.ogg'

/datum/action/innate/ai/break_air_alarms
	name = "Override Air Alarm Safeties"
	desc = "Enables extremely dangerous settings on all air alarms."
	button_icon_state = "break_air_alarms"
	uses = 1

/datum/action/innate/ai/break_air_alarms/on_activate(mob/user, atom/target)
	. = ..()
	for(var/obj/machinery/airalarm/AA in GLOB.air_alarms)
		if(!is_station_level(AA.z))
			continue
		AA.obj_flags |= EMAGGED
	to_chat(owner, span_notice("All air alarm safeties on the station have been overridden. Air alarms may now use extremely dangerous environmental modes."))
	user.playsound_local(user, 'sound/machines/terminal_off.ogg', 50, 0)

/// Thermal Sensor Override: Unlocks the ability to disable all fire alarms from doing their job.
/datum/ai_module/malf/utility/break_fire_alarms
	name = "Thermal Sensor Override"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. \
		This will remove their ability to scan for fire and thus their ability to alert."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/action/innate/ai/break_fire_alarms
	unlock_text = span_notice("You replace the thermal sensing capabilities of all fire alarms with a manual override, \
		allowing you to turn them off at will.")
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
	to_chat(owner, span_notice("All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized."))
	user.playsound_local(user, 'sound/machines/terminal_off.ogg', 50, 0)

/// Reactivate Camera Network: Reactivates up to 20 cameras across the station.
/datum/ai_module/malf/utility/reactivate_cameras
	name = "Reactivate Camera Network"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. \
		Can be used to repair up to 20 cameras."
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
	for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
		if(!uses)
			break
		if(!C.status || C.view_range != initial(C.view_range))
			C.toggle_cam(owner_AI, 0) //Reactivates the camera based on status. Badly named proc.
			C.view_range = initial(C.view_range)
			fixed_cameras++
			uses-- //Not adjust_uses() so it doesn't automatically delete or show a message
	to_chat(owner, span_notice("Diagnostic complete! Cameras reactivated: <b>[fixed_cameras]</b>. Reactivations remaining: <b>[uses]</b>."))
	user.playsound_local(user, 'sound/items/wirecutter.ogg', 50, 0)
	adjust_uses(0, TRUE) //Checks the uses remaining
	if(QDELETED(src) || !uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		return

/// Upgrade Camera Network: EMP-proofs all cameras, in addition to giving them X-ray vision.
/datum/ai_module/malf/upgrade/upgrade_cameras
	name = "Upgrade Camera Network"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-proofing and light-amplified X-ray vision. Upgrade is done immediately upon purchase." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	cost = 35 //Decent price for omniscience!
	upgrade = TRUE
	unlock_text = span_notice("OTA firmware distribution complete! Cameras upgraded: CAMSUPGRADED. Light amplification system online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/malf/upgrade/upgrade_cameras/upgrade(mob/living/silicon/ai/AI)
	// Sets up nightvision
	AI.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	AI.update_sight()

	var/upgraded_cameras = 0
	for(var/obj/machinery/camera/camera as anything in GLOB.cameranet.cameras)
		var/upgraded = FALSE

		if(!camera.isXRay())
			camera.upgradeXRay(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_xray_firmware_active and clean up isxray()
			//Update what it can see.
			GLOB.cameranet.updateVisibility(camera, 0)
			upgraded = TRUE

		if(!camera.isEmpProof())
			camera.upgradeEmpProof(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_emp_firmware_active and clean up isemp()
			upgraded = TRUE

		if(upgraded)
			upgraded_cameras++
	unlock_text = replacetext(unlock_text, "CAMSUPGRADED", "<b>[upgraded_cameras]</b>") //This works, since unlock text is called after upgrade()

/// AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/ai_module/malf/upgrade/upgrade_turrets
	name = "AI Turret Upgrade"
	description = "Improves the power and health of all AI turrets. This effect is permanent. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("You establish a power diversion to your turrets, upgrading their health and damage.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/malf/upgrade/upgrade_turrets/upgrade(mob/living/silicon/ai/AI)
	for(var/obj/machinery/porta_turret/ai/turret in GLOB.machines)
		turret.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
		turret.emp_proofing = TRUE
		turret.max_integrity = 200
		turret.repair_damage(200)
		turret.stun_projectile = /obj/projectile/beam/disabler/pass_glass //// AI defenses are often built with glass, so this is big.
		turret.stun_projectile_sound = 'sound/weapons/lasercannonfire.ogg'
		turret.lethal_projectile = /obj/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
		turret.lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'

/// Enhanced Surveillance: Enables AI to hear conversations going on near its active vision.
/datum/ai_module/malf/upgrade/eavesdrop
	name = "Enhanced Surveillance"
	description = "Via a combination of hidden microphones and lip reading software, \
		you are able to use your cameras to listen in on conversations. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/malf/upgrade/eavesdrop/upgrade(mob/living/silicon/ai/AI)
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE

/// Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/ai_module/malf/upgrade/mecha_domination
	name = "Unlock Mech Domination"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. \
		Upgrade is done immediately upon purchase. Do not allow the mech to leave the station's vicinity or allow it to be destroyed. \
		If your core is destroyed, you will be lose connection with the Doomsday Device and the countdown will cease."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. \
		Loss of signal will result in total system lockout. If your inactive core is destroyed, you will lose connection with the Doomsday Device and the countdown will cease.</b>")
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/ai_module/malf/upgrade/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!

/datum/ai_module/malf/upgrade/voice_changer
	name = "Voice Changer"
	description = "Allows you to synthesize your own voices. Upgrade is active immediately upon purchase."
	cost = 40
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/voice_changer
	unlock_text = span_notice("OTA firmware distribution complete! Voice changer online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/action/innate/ai/voice_changer
	name = "Voice Changer"
	button_icon_state = "voice_changer"
	desc = "Allows you to synthesize your own voices."
	auto_use_uses = FALSE
	var/obj/machinery/ai_voicechanger/voice_changer_machine

/datum/action/innate/ai/voice_changer/on_activate(mob/user, atom/target)
	. = ..()
	if(!voice_changer_machine)
		voice_changer_machine = new(owner_AI)
	voice_changer_machine.ui_interact(usr)

/obj/machinery/ai_voicechanger
	name = "Voice Changer"
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	/// The AI this voicechanger belongs to
	var/mob/living/silicon/ai/owner
	// Verb used when voicechanger is on
	var/say_verb
	/// Name used when voicechanger is on
	var/say_name
	/// Span used when voicechanger is on
	var/say_span
	/// TRUE if the AI is changing its voice
	var/changing_voice = FALSE
	/// Saved verb state, used to restore after a voice change
	var/prev_verbs
	/// Saved span state, used to restore after a voice change
	var/prev_span
	/// The list of available voices
	var/static/list/voice_options = list("normal", SPAN_ROBOT, SPAN_YELL, SPAN_CLOWN)

/obj/machinery/ai_voicechanger/Initialize(mapload)
	. = ..()
	if(!isAI(loc))
		return INITIALIZE_HINT_QDEL
	owner = loc
	owner.ai_voicechanger = src
	prev_verbs = list("say" = owner.verb_say, "ask" = owner.verb_ask, "exclaim" = owner.verb_exclaim , "yell" = owner.verb_yell  )
	prev_span = owner.speech_span
	say_name = owner.name
	say_verb = owner.verb_say
	say_span = owner.speech_span

/obj/machinery/ai_voicechanger/Destroy()
	if(owner)
		owner.ai_voicechanger = null
		owner = null
	return ..()

/obj/machinery/ai_voicechanger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiVoiceChanger")
		ui.open()

/obj/machinery/ai_voicechanger/ui_data(mob/user)
	var/list/data = list(
		"voices" = voice_options,
		"on" = changing_voice,
		"say_verb" = say_verb,
		"name" = say_name,
		"selected" = say_span || owner.speech_span
	)
	return data

/obj/machinery/ai_voicechanger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	switch(action)
		if("power")
			update_appearance()
			changing_voice = !changing_voice
			if(changing_voice)
				prev_verbs["say"] = owner.verb_say
				owner.verb_say	= say_verb
				prev_verbs["ask"] = owner.verb_ask
				owner.verb_ask	= say_verb
				prev_verbs["exclaim"] = owner.verb_exclaim
				owner.verb_exclaim	= say_verb
				prev_verbs["yell"] = owner.verb_yell
				owner.verb_yell	= say_verb
				prev_span = owner.speech_span
				owner.speech_span = say_span
			else
				owner.verb_say	= prev_verbs["say"]
				owner.verb_ask	= prev_verbs["ask"]
				owner.verb_exclaim	= prev_verbs["exclaim"]
				owner.verb_yell	= prev_verbs["yell"]
				owner.speech_span = prev_span
			return TRUE
		if("look")
			var/selection = params["look"]
			if(isnull(selection))
				return FALSE

			var/found = FALSE
			for(var/option in voice_options)
				if(option == selection)
					found = TRUE
					break
			if(!found)
				stack_trace("User attempted to select an unavailable voice option")
				return FALSE

			say_span = selection
			if(changing_voice)
				owner.speech_span = say_span
			to_chat(usr, span_notice("Voice set to [selection]."))
			return TRUE
		if("verb")
			say_verb = strip_html(params["verb"], MAX_NAME_LEN)
			if(changing_voice)
				owner.verb_say = say_verb
				owner.verb_ask = say_verb
				owner.verb_exclaim = say_verb
				owner.verb_yell = say_verb
			return TRUE
		if("name")
			say_name = strip_html(params["name"], MAX_NAME_LEN)
			return TRUE

/datum/ai_module/malf/utility/emag
	name = "Targeted Safeties Override"
	description = "Allows you to disable the safeties of any machinery on the station, provided you can access it."
	cost = 20
	power_type = /datum/action/innate/ai/ranged/emag
	unlock_text = span_notice("You download an illicit software package from a syndicate database leak and integrate it into your firmware, fighting off a few kernel intrusions along the way.")
	unlock_sound = 'sound/effects/sparks1.ogg'

/datum/action/innate/ai/ranged/emag
	name = "Targeted Safeties Override"
	desc = "Allows you to effectively emag anything you click on."
	button_icon_state = "emag"
	uses = 7
	enable_text = span_notice("You load your syndicate software package to your most recent memory slot.")
	disable_text = span_notice("You unload your syndicate software package.")
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

/datum/action/innate/ai/ranged/emag/on_activate(mob/user, atom/target)
	. = ..()
	// Only things with of or subtyped of any of these types may be remotely emagged
	var/static/list/compatable_typepaths = list(
		/obj/machinery,
		/obj/structure,
		/obj/item/radio/intercom,
		/obj/item/modular_computer,
		/mob/living/simple_animal/bot,
		/mob/living/silicon,
	)

	if(!isAI(user))
		return FALSE

	var/mob/living/silicon/ai/ai_clicker = user

	if(ai_clicker.incapacitated())
		return FALSE

	if(!ai_clicker.can_see(target))
		target.balloon_alert(ai_clicker, "can't see!")
		return FALSE

	if(ismachinery(target))
		var/obj/machinery/clicked_machine = target
		if(!clicked_machine.is_operational)
			clicked_machine.balloon_alert(ai_clicker, "not operational!")
			return FALSE

	if(!(is_type_in_list(target, compatable_typepaths)))
		target.balloon_alert(ai_clicker, "incompatable!")
		return FALSE

	if(istype(target, /obj/machinery/door/airlock)) // I HATE THIS CODE SO MUCHHH
		var/obj/machinery/door/airlock/clicked_airlock = target
		if(!clicked_airlock.canAIControl(ai_clicker))
			clicked_airlock.balloon_alert(ai_clicker, "unable to interface!")
			return FALSE

	if(istype(target, /obj/machinery/airalarm))
		var/obj/machinery/airalarm/alarm = target
		if(alarm.aidisabled)
			alarm.balloon_alert(ai_clicker, "unable to interface!")
			return FALSE

	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/clicked_apc = target
		if(clicked_apc.aidisabled)
			clicked_apc.balloon_alert(ai_clicker, "unable to interface!")
			return FALSE

	target.use_emag(ai_clicker)
	var/obj/target_obj = target
	if(!(target_obj?.obj_flags & EMAGGED))
		to_chat(ai_clicker, span_warning("Hostile software insertion failed!"))
		return FALSE

	to_chat(ai_clicker, span_notice("Software package successfully injected."))
	adjust_uses(-1)

	return TRUE

/datum/ai_module/malf/utility/core_tilt
	name = "Rolling Servos"
	description = "Allows you to slowly roll around, crushing anything in your way with your bulk."
	cost = 10
	power_type = /datum/action/innate/ai/ranged/core_tilt
	unlock_sound = 'sound/effects/bang.ogg'
	unlock_text = span_notice("You gain the ability to roll over and crush anything in your way.")

/datum/action/innate/ai/ranged/core_tilt
	name = "Roll over"
	button_icon_state = "roll_over"
	desc = "Allows you to roll over in the direction of your choosing, crushing anything in your way."
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	uses = 20
	COOLDOWN_DECLARE(time_til_next_tilt)
	enable_text = span_notice("Your inner servos shift as you prepare to roll around. Click adjacent tiles to roll onto them!")
	disable_text = span_notice("You disengage your rolling protocols.")

	/// How long does it take for us to roll?
	var/roll_over_time = MALF_AI_ROLL_TIME
	/// On top of [roll_over_time], how long does it take for the ability to cooldown?
	var/roll_over_cooldown = MALF_AI_ROLL_COOLDOWN

/datum/action/innate/ai/ranged/core_tilt/on_activate(mob/user, atom/target)
	. = ..()
	if(!COOLDOWN_FINISHED(src, time_til_next_tilt))
		user.balloon_alert(user, "on cooldown!")
		return FALSE

	if(!isAI(user))
		return FALSE
	var/mob/living/silicon/ai/ai_clicker = user

	if(ai_clicker.incapacitated() || !isturf(ai_clicker.loc))
		return FALSE

	var/turf/turf = get_turf(target)
	if(isnull(turf))
		return FALSE

	if(turf == ai_clicker.loc)
		turf.balloon_alert(ai_clicker, "can't roll on yourself!")
		return FALSE

	var/picked_dir = get_dir(ai_clicker, turf)
	if(!picked_dir)
		return FALSE
	var/turf/temp_target = get_step(ai_clicker, picked_dir) // we can move during the timer so we cant just pass the ref

	new /obj/effect/temp_visual/telegraphing/vending_machine_tilt(temp_target, roll_over_time)
	ai_clicker.balloon_alert_to_viewers("rolling...")
	addtimer(CALLBACK(src, PROC_REF(do_roll_over), ai_clicker, picked_dir), roll_over_time)

	adjust_uses(-1)

	COOLDOWN_START(src, time_til_next_tilt, roll_over_cooldown)

/datum/action/innate/ai/ranged/core_tilt/proc/do_roll_over(mob/living/silicon/ai/ai_clicker, picked_dir)
	if(ai_clicker.incapacitated() || !isturf(ai_clicker.loc)) // prevents bugs where the ai is carded and rolls
		return

	var/turf/target = get_step(ai_clicker, picked_dir) // in case we moved we pass the dir not the target turf
	if(isnull(target))
		return

	var/paralyze_time = clamp(6 SECONDS, 0 SECONDS, (roll_over_cooldown * 0.9)) //the clamp prevents stunlocking as the max is always a little less than the cooldown between rolls
	ai_clicker.tilt(target, MALF_AI_ROLL_DAMAGE, MALF_AI_ROLL_CRIT_CHANCE, paralyze_time, rotation = get_rotation_from_dir(picked_dir))

/// Used in our radial menu, state-checking proc after the radial menu sleeps
/datum/action/innate/ai/ranged/core_tilt/proc/radial_check(mob/living/silicon/ai/user)
	if(QDELETED(user) || user.incapacitated() || user.stat == DEAD || uses <= 0)
		return FALSE
	return TRUE

/datum/action/innate/ai/ranged/core_tilt/proc/get_rotation_from_dir(dir)
	switch (dir)
		if(NORTH, NORTHWEST, WEST, SOUTHWEST)
			return 270 // try our best to not return 180 since it works badly with animate
		if(EAST, NORTHEAST, SOUTH, SOUTHEAST)
			return 90
		else
			stack_trace("non-standard dir entered to get_rotation_from_dir. (got: [dir])")
			return 0

/datum/ai_module/malf/utility/remote_vendor_tilt
	name = "Remote Vendor Tilting"
	description = "Lets you remotely tip vendors over in any direction."
	cost = 15
	power_type = /datum/action/innate/ai/ranged/remote_vendor_tilt
	unlock_sound = 'sound/effects/bang.ogg'
	unlock_text = span_notice("You gain the ability to remotely tip any vendor onto any adjacent tiles.")

/datum/action/innate/ai/ranged/remote_vendor_tilt
	name = "Remote Vendor Tilting"
	desc = "Use to remotely tilt a vendor in any direction you desire."
	button_icon_state = "vendor_tilt"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	uses = 8
	var/time_to_tilt = MALF_VENDOR_TIPPING_TIME
	enable_text = span_notice("You prepare to wobble any vendors you see.")
	disable_text = span_notice("You stop focusing on tipping vendors.")

/datum/action/innate/ai/ranged/remote_vendor_tilt/on_activate(mob/user, atom/target)
	. = ..()
	var/mob/living/silicon/ai/ai_clicker = user
	if(!user || !isAI(user))
		return FALSE

	if(ai_clicker.incapacitated())
		return FALSE

	if(!istype(target, /obj/machinery/vending))
		target.balloon_alert(ai_clicker, "not a vendor!")
		return FALSE

	var/obj/machinery/vending/clicked_vendor = target

	if(clicked_vendor.tilted)
		clicked_vendor.balloon_alert(ai_clicker, "already tilted!")
		return FALSE

	if(!clicked_vendor.tiltable)
		clicked_vendor.balloon_alert(ai_clicker, "cannot be tilted!")
		return FALSE

	if(!clicked_vendor.is_operational)
		clicked_vendor.balloon_alert(ai_clicker, "inoperable!")
		return FALSE

	var/picked_dir_string = show_radial_menu(ai_clicker, clicked_vendor, GLOB.all_radial_directions, custom_check = CALLBACK(src, PROC_REF(radial_check), user, clicked_vendor))
	if(isnull(picked_dir_string))
		return FALSE
	var/picked_dir = text2dir(picked_dir_string)

	var/turf/turf = get_step(clicked_vendor, picked_dir)
	if(!ai_clicker.can_see(turf))
		to_chat(ai_clicker, span_warning("You can't see the target tile!"))
		return FALSE

	new /obj/effect/temp_visual/telegraphing/vending_machine_tilt(turf, time_to_tilt)
	clicked_vendor.visible_message(span_warning("[clicked_vendor] starts falling over..."))
	clicked_vendor.balloon_alert_to_viewers("falling over...")
	addtimer(CALLBACK(src, PROC_REF(do_vendor_tilt), clicked_vendor, turf), time_to_tilt)

	adjust_uses(-1)

	to_chat(user, span_danger("Tilting..."))
	return TRUE

/datum/action/innate/ai/ranged/remote_vendor_tilt/proc/do_vendor_tilt(obj/machinery/vending/vendor, turf/target)
	if(QDELETED(vendor))
		return FALSE

	if(vendor.tilted || !vendor.tiltable)
		return FALSE

	vendor.tilt(target, MALF_VENDOR_TIPPING_CRIT_CHANCE)

/// Used in our radial menu, state-checking proc after the radial menu sleeps
/datum/action/innate/ai/ranged/remote_vendor_tilt/proc/radial_check(mob/living/silicon/ai/user, obj/machinery/vending/clicked_vendor)
	if(QDELETED(user) || user.incapacitated() || user.stat == DEAD)
		return FALSE

	if(QDELETED(clicked_vendor))
		return FALSE

	if(uses <= 0)
		return FALSE

	if(!user.can_see(clicked_vendor))
		to_chat(user, span_warning("Lost sight of [clicked_vendor]!"))
		return FALSE

	return TRUE

/datum/ai_module/malf/utility/fake_alert
	name = "Fake Alert"
	description = "Assess the most probable threats to the station, and send a distracting fake alert by hijacking the station's alert and threat identification systems."
	cost = 20
	power_type = /datum/action/innate/ai/fake_alert
	unlock_sound = 'sound/effects/sparks1.ogg'
	unlock_text = span_notice("You gain control of the station's alert system.")

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
	var/chosen_event = tgui_input_list(owner,"Send fake alert", "Fake Alert", events_to_chose)
	if(!chosen_event)
		return FALSE
	var/datum/round_event_control/event_control = events_to_chose[chosen_event]
	if(!event_control)
		return FALSE
	var/datum/round_event/event_announcement = new event_control.typepath()
	event_announcement.kill()
	event_announcement.announce(TRUE)
	return TRUE

#undef DEFAULT_DOOMSDAY_TIMER
#undef DOOMSDAY_ANNOUNCE_INTERVAL

#undef MALF_VENDOR_TIPPING_TIME
#undef MALF_VENDOR_TIPPING_CRIT_CHANCE

#undef MALF_AI_ROLL_COOLDOWN
#undef MALF_AI_ROLL_TIME
#undef MALF_AI_ROLL_DAMAGE
#undef MALF_AI_ROLL_CRIT_CHANCE
