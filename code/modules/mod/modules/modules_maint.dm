//Maint modules for MODsuits

///Springlock Mechanism - allows your modsuit to activate faster, but reagents are very dangerous.
/obj/item/mod/module/springlock
	name = "\improper MOD springlock module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up, but was taken out of modern suits because of the springlock's tendency to \"snap\" back \
		into place when exposed to humidity. You know what it's like to have an entire exoskeleton enter you?"
	icon_state = "springlock"
	complexity = 3 // it is inside every part of your suit, so
	incompatible_modules = list(/obj/item/mod/module/springlock)
	var/set_off = FALSE
	var/step_change = 0.5

/obj/item/mod/module/springlock/on_install()
	mod.activation_step_time *= step_change

/obj/item/mod/module/springlock/on_uninstall(deleting = FALSE)
	mod.activation_step_time /= step_change

/obj/item/mod/module/springlock/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS,  PROC_REF(on_wearer_exposed))

/obj/item/mod/module/springlock/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_ATOM_EXPOSE_REAGENTS)

///Signal fired when wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/on_wearer_exposed(atom/source, list/reagents, datum/reagents/source_reagents, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	if(!(methods & (VAPOR|PATCH|TOUCH)) || set_off || mod.wearer.stat == DEAD)
		return //remove non-touch reagent exposure
	to_chat(mod.wearer, "<span_class='danger'>[src] makes an ominous click sound...</span>")
	playsound(src, 'sound/items/modsuit/springlock.ogg', 75, TRUE)
	addtimer(CALLBACK(src,  PROC_REF(snap_shut)), rand(3 SECONDS, 5 SECONDS))
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE,  PROC_REF(on_activate_spring_block))
	set_off = TRUE

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/springlock/proc/on_activate_spring_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "springlocks aren't responding...?")
	return MOD_CANCEL_ACTIVATE

///Delayed death proc of the suit after the wearer is exposed to reagents
/obj/item/mod/module/springlock/proc/snap_shut()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	if(!mod.wearer) //while there is a guaranteed user when on_wearer_exposed() fires, that isn't the same case for this proc
		return
	mod.wearer.visible_message("[src] inside [mod.wearer]'s [mod.name] snaps shut, mutilating the user inside!", "<span_class='userdanger'>*SNAP*</span")
	mod.wearer.emote("scream")
	playsound(mod.wearer, 'sound/effects/snap.ogg', 75, TRUE, frequency = 0.5)
	playsound(mod.wearer, 'sound/effects/splat.ogg', 50, TRUE, frequency = 0.5)
	mod.wearer.apply_damage(500, BRUTE, forced = TRUE) //boggers, bogchamp, etc
	if(!HAS_TRAIT(mod.wearer, TRAIT_NODEATH))
		mod.wearer.death() //just in case, for some reason, they're still alive
	flash_color(mod.wearer, flash_color = "#FF0000", flash_time = 10 SECONDS)
	set_off = FALSE

///Rave Visor - Gives you a rainbow visor and plays jukebox music to you.
/obj/item/mod/module/visor/rave
	name = "\improper MOD rave visor module"
	desc = "A Super Cool Awesome Visor (SCAV), intended for modular suits."
	icon_state = "rave_visor"
	complexity = 1
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// The client colors applied to the wearer.
	var/datum/client_colour/rave_screen
	/// The current element in the rainbow_order list we are on.
	var/rave_number = 1
	/// A list of the colors the module can take.
	var/static/list/rainbow_order = list(
		list(1,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(1,0,0,0, 0,0.5,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(1,0,0,0, 0,1,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(0,0,0,0, 0,1,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0),
		list(0,0,0,0, 0,0.5,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0),
		list(1,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0),
	)
	/// What actually plays music to us
	var/datum/jukebox/single_mob/music_player

/obj/item/mod/module/visor/rave/Initialize(mapload)
	. = ..()
	music_player = new(src)
	music_player.sound_loops = TRUE

/obj/item/mod/module/visor/rave/Destroy()
	QDEL_NULL(music_player)
	QDEL_NULL(rave_screen)
	return ..()

/obj/item/mod/module/visor/rave/on_activation(mob/activator)
	rave_screen = mod.wearer.add_client_colour(/datum/client_colour/rave, REF(src))
	rave_screen.update_colour(rainbow_order[rave_number])
	music_player.start_music(mod.wearer)

/obj/item/mod/module/visor/rave/on_deactivation(mob/activator, display_message = TRUE, deleting = FALSE)
	QDEL_NULL(rave_screen)
	if(isnull(music_player.active_song_sound))
		return

	music_player.unlisten_all()
	if(deleting)
		return
	SEND_SOUND(mod.wearer, sound('sound/machines/terminal_off.ogg', volume = 50, channel = CHANNEL_JUKEBOX))

/obj/item/mod/module/visor/rave/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	. = ..()
	if (!.)
		return

	var/mutable_appearance/visor_overlay = mod.get_visor_overlay(standing)
	visor_overlay.appearance_flags |= RESET_COLOR
	if (!isnull(music_player.active_song_sound))
		visor_overlay.color = rainbow_order[rave_number]
	. += visor_overlay

/obj/item/mod/module/visor/rave/on_active_process(delta_time)
	rave_number++
	if(rave_number > length(rainbow_order))
		rave_number = 1
	mod.wearer.update_clothing(mod.slot_flags)
	rave_screen.update_colour(rainbow_order[rave_number])

/obj/item/mod/module/visor/rave/get_configuration()
	. = ..()
	if(length(music_player.songs))
		.["selection"] = add_ui_configuration("Song", "list", music_player.selection.song_name, music_player.songs)

/obj/item/mod/module/visor/rave/configure_edit(key, value)
	switch(key)
		if("selection")
			if(!isnull(music_player.active_song_sound))
				return

			var/datum/track/new_song = music_player.songs[value]
			if(QDELETED(src) || !istype(new_song, /datum/track))
				return

			music_player.selection = new_song

///Tanner - Tans you with spraytan.
/obj/item/mod/module/tanner
	name = "\improper MOD tanning module"
	desc = "A tanning module for modular suits. Skin cancer functionality hasn't ever been proven, \
		although who knows with the rumors..."
	icon_state = "tanning"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/tanner)
	cooldown_time = 30 SECONDS
	required_slots = list(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)

/obj/item/mod/module/tanner/on_use()
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, TRUE)
	var/datum/reagents/holder = new()
	holder.add_reagent(/datum/reagent/spraytan, 10)
	holder.trans_to(mod.wearer, 10, method = VAPOR)
	if(prob(5))
		SSradiation.irradiate(mod.wearer, intensity = 100)
	drain_power(use_power_cost)

///Balloon Blower - Blows a balloon.
/obj/item/mod/module/balloon
	name = "\improper MOD balloon blower module"
	desc = "A strange module invented years ago by some ingenious mimes. It blows balloons."
	icon_state = "bloon"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN*0.5
	incompatible_modules = list(/obj/item/mod/module/balloon)
	cooldown_time = 15 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	var/balloon_path = /obj/item/toy/balloon
	var/blowing_time = 10 SECONDS
	var/oxygen_damage = 20

/obj/item/mod/module/balloon/on_use()
	if(!do_after(mod.wearer, blowing_time, target = mod))
		return FALSE
	mod.wearer.adjustOxyLoss(oxygen_damage)
	playsound(src, 'sound/items/modsuit/inflate_bloon.ogg', 50, TRUE)
	var/obj/item/balloon = new balloon_path(get_turf(src))
	mod.wearer.put_in_hands(balloon)
	drain_power(use_power_cost)

/// Paper Dispenser - Dispenses (sometimes burning) paper sheets.
/obj/item/mod/module/paper_dispenser
	name = "\improper MOD paper dispenser module"
	desc = "A simple module designed by the bureaucrats of Torch Bay. \
		It dispenses 'warm, clean, and crisp sheets of paper' onto a nearby table. Usually."
	icon_state = "paper_maker"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/paper_dispenser)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// The total number of sheets created by this MOD. The more sheets, them more likely they set on fire.
	var/num_sheets_dispensed = 0

/obj/item/mod/module/paper_dispenser/on_use()
	if(!do_after(mod.wearer, 1 SECONDS, target = mod))
		return FALSE

	var/obj/item/paper/crisp_paper = new(get_turf(src))
	crisp_paper.desc = "It's crisp and warm to the touch. Must be fresh."

	var/obj/structure/table/nearby_table = locate() in range(1, mod.wearer)
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "dispensed paper[nearby_table ? " onto table":""]")

	mod.wearer.put_in_hands(crisp_paper)
	if(nearby_table)
		mod.wearer.transferItemToLoc(crisp_paper, nearby_table.drop_location(), silent = FALSE)

	// Up to a 30% chance to set the sheet on fire, +2% per sheet made
	if(prob(min(num_sheets_dispensed * 2, 30)))
		if(crisp_paper in mod.wearer.held_items)
			mod.wearer.dropItemToGround(crisp_paper, force = TRUE)
		crisp_paper.balloon_alert(mod.wearer, "PC LOAD LETTER!")
		crisp_paper.visible_message("<span_class='warning'>[crisp_paper] bursts into flames, it's too crisp!</span>")
		crisp_paper.fire_act(1000, 100)

	drain_power(use_power_cost)
	num_sheets_dispensed++


///Stamper - Extends a stamp that can switch between accept/deny modes.
/obj/item/mod/module/stamp
	name = "\improper MOD stamper module"
	desc = "A module installed into the wrist of the suit, this functions as a high-power stamp, \
		able to switch between accept and deny modes."
	icon_state = "stamp"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/stamp/mod
	incompatible_modules = list(/obj/item/mod/module/stamp)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/stamp/mod
	name = "\improper MOD electronic stamp"
	desc = "A high-power stamp, able to switch between accept and deny mode when used."

/obj/item/stamp/mod/attack_self(mob/user, modifiers)
	. = ..()
	if(icon_state == "stamp-ok")
		icon_state = "stamp-deny"
	else
		icon_state = "stamp-ok"
	balloon_alert(user, "switched mode")

///Atrocinator - Flips your gravity.
/obj/item/mod/module/atrocinator
	name = "\improper MOD atrocinator module"
	desc = "A mysterious orb that has mysterious effects when inserted in a MODsuit."
	icon_state = "atrocinator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/atrocinator, /obj/item/mod/module/magboot, /obj/item/mod/module/anomaly_locked/antigrav)
	overlay_state_inactive = "module_atrocinator"
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// How many steps the user has taken since turning the suit on, used for footsteps.
	var/step_count = 0
	/// If you use the module on a planetary turf, you fly up. To the sky.
	var/you_fucked_up = FALSE

/obj/item/mod/module/atrocinator/on_activation()
	playsound(src, 'sound/effects/curseattack.ogg', 50)
	mod.wearer.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED,  PROC_REF(check_upstairs))
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	//ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))
	check_upstairs() //todo at some point flip your screen around

/obj/item/mod/module/atrocinator/deactivate(display_message = TRUE, deleting = FALSE)
	if(you_fucked_up && !deleting)
		to_chat(mod.wearer, "<span_class='danger'>It's too late.</span>")
		return FALSE
	return ..()

/obj/item/mod/module/atrocinator/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/effects/curseattack.ogg', 50)
	mod.wearer.RemoveElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	step_count = 0
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	//REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))
	var/turf/open/openspace/current_turf = get_turf(mod.wearer)
	if(istype(current_turf))
		current_turf.zFall(mod.wearer)

/obj/item/mod/module/atrocinator/proc/check_upstairs()
	SIGNAL_HANDLER

	if(you_fucked_up || mod.wearer.has_gravity() > NEGATIVE_GRAVITY)
		return

	var/turf/open/current_turf = get_turf(mod.wearer)
	var/turf/open/openspace/turf_above = get_step_multiz(mod.wearer, UP)
	if(current_turf && istype(turf_above))
		current_turf.zFall(mod.wearer)
		return

	else if(!turf_above && istype(current_turf) && current_turf.planetary_atmos) //nothing holding you down
		INVOKE_ASYNC(src,  PROC_REF(fly_away))
		return

	else if(!(step_count % 2))
		playsound(current_turf, 'sound/items/modsuit/atrocinator_step.ogg', 50)
	step_count++

#define FLY_TIME 5 SECONDS

/obj/item/mod/module/atrocinator/proc/fly_away()
	you_fucked_up = TRUE
	playsound(src, 'sound/effects/whirthunk.ogg', 75)
	to_chat(mod.wearer, "<span_class='userdanger'>That was stupid.</span>")
	investigate_log("has flown off into space due to the [src].", INVESTIGATE_DEATHS)
	mod.wearer.Stun(FLY_TIME, ignore_canstun = TRUE)
	animate(mod.wearer, FLY_TIME, pixel_y = 256, alpha = 0)
	QDEL_IN(mod.wearer, FLY_TIME)

#undef FLY_TIME
