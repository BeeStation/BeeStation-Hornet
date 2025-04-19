CREATION_TEST_IGNORE_SELF(/obj)

/obj
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	var/obj_flags = CAN_BE_HIT

	/// ONLY FOR MAPPING: Sets flags from a string list, handled in Initialize. Usage: set_obj_flags = "EMAGGED;!CAN_BE_HIT" to set EMAGGED and clear CAN_BE_HIT.
	var/set_obj_flags

	/// Extra examine line to describe controls, such as right-clicking, left-clicking, etc.
	var/desc_controls

	/// Icon to use as a 32x32 preview in crafting menus and such
	var/icon_preview
	var/icon_state_preview

	var/damtype = BRUTE
	var/force = 0
	/// How much bleeding damage do we cause, see __DEFINES/mobs.dm
	var/bleed_force = 0

	/*
	VAR_PRIVATE/atom_integrity //defaults to max_integrity
	/// The maximum integrity the object can have.
	var/max_integrity = 500
	/// The object will break once atom_integrity reaches this amount in take_damage(). 0 if we have no special broken behavior, otherwise is a percentage of at what point the obj breaks. 0.5 being 50%
	var/integrity_failure = 0
	/// Damage under this value will be completely ignored
	var/damage_deflection = 0
	/// Maximum damage that can be taken in a single hit
	var/max_hit_damage = null

	/// INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
	var/resistance_flags = NONE
	*/

	/// How much acid is on that obj
	var/acid_level = 0

	/// Have something WAY too amazing to live to the next round? Set a new path here. Overuse of this var will make me upset. Will replace the object with the type you specify during persistence.
	var/persistence_replacement
	var/current_skin //Has the item been reskinned?
	var/list/unique_reskin //List of options to reskin.
	var/list/unique_reskin_icon //List of icons for said options.

	// Access levels, used in modules\jobs\access.dm
	var/list/req_access
	var/req_access_txt = "0"
	var/list/req_one_access
	var/req_one_access_txt = "0"
	/// Custom fire overlay icon
	var/custom_fire_overlay

	/// Set when a player uses a pen on a renamable object
	var/renamedByPlayer = FALSE

	var/drag_slowdown // Amont of multiplicative slowdown applied if pulled. >1 makes you slower, <1 makes you faster.

	vis_flags = VIS_INHERIT_PLANE //when this be added to vis_contents of something it inherit something.plane, important for visualisation of obj in openspace.
	/// Map tag for something.  Tired of it being used on snowflake items.  Moved here for some semblance of a standard.
	/// Next pr after the network fix will have me refactor door interactions, so help me god.
	var/id_tag = null
	/// Network id. If set it can be found by either its hardware id or by the id tag if thats set.  It can also be
	/// broadcasted to as long as the other guys network is on the same branch or above.
	var/network_id = null

	uses_integrity = TRUE

	var/investigate_flags = NONE
	// ADMIN_INVESTIGATE_TARGET: investigate_log on pickup/drop
	/// If the emag behavior should be toggleable
	var/emag_toggleable = FALSE

/obj/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, obj_flags))
		if ((obj_flags & DANGEROUS_POSSESSION) && !(vval & DANGEROUS_POSSESSION))
			return FALSE
	return ..()

/obj/Initialize(mapload)

	. = ..() //Do this after, else mat datums is mad.

	if (set_obj_flags)
		var/flagslist = splittext(set_obj_flags,";")
		var/list/string_to_objflag = GLOB.bitfields["obj_flags"]
		for (var/flag in flagslist)
			if(flag[1] == "!")
				flag = copytext(flag, length(flag[1]) + 1) // Get all but the initial !
				obj_flags &= ~string_to_objflag[flag]
			else
				obj_flags |= string_to_objflag[flag]

	if((obj_flags & ON_BLUEPRINTS) && isturf(loc))
		var/turf/T = loc
		T.add_blueprints_preround(src)
	if(network_id)
		var/area/A = get_area(src)
		if(A)
			if(!A.network_root_id)
				log_telecomms("Area '[A.name]([REF(A)])' has no network network_root_id, force assigning in object [src]([REF(src)])")
				SSnetworks.lookup_area_root_id(A)
			network_id = NETWORK_NAME_COMBINE(A.network_root_id, network_id) // I regret nothing!!
		else
			log_telecomms("Created [src]([REF(src)] in nullspace, assuming network to be in station")
			network_id = NETWORK_NAME_COMBINE(STATION_NETWORK_ROOT, network_id) // I regret nothing!!
		AddComponent(/datum/component/ntnet_interface, network_id, id_tag)
		/// Needs to run before as ComponentInitialize runs after this statement...why do we have ComponentInitialize again?

// A list of all /obj by their id_tag
GLOBAL_LIST_EMPTY(objects_by_id_tag)

/obj/Initialize(mapload)
	. = ..()

	if (id_tag)
		GLOB.objects_by_id_tag[id_tag] = src

/obj/Destroy(force=FALSE)
	if(!ismachinery(src) && (datum_flags & DF_ISPROCESSING))
		STOP_PROCESSING(SSobj, src)
	SStgui.close_uis(src)
	GLOB.objects_by_id_tag -= id_tag
	. = ..()


/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process

	if(breath_request>0)
		var/datum/gas_mixture/environment = return_air()
		var/breath_percentage = BREATH_VOLUME / environment.return_volume()
		return remove_air(environment.total_moles() * breath_percentage)
	else
		return null

/obj/proc/updateUsrDialog()
	if((obj_flags & IN_USE) && !(obj_flags & USES_TGUI))
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M as() in nearby)
			if ((M.client && M.machine == src))
				is_in_use = TRUE
				ui_interact(M)
		if(issilicon(usr) || IsAdminGhost(usr))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					ui_interact(usr)

		// check for TK users

		if(usr?.has_dna())
			var/mob/living/carbon/C = usr
			if(!(usr in nearby))
				if(usr.client && usr.machine==src)
					if(C.dna.check_mutation(/datum/mutation/telekinesis))
						is_in_use = TRUE
						ui_interact(usr)
		if (is_in_use)
			obj_flags |= IN_USE
		else
			obj_flags &= ~IN_USE

/obj/proc/updateDialog(update_viewers = TRUE,update_ais = TRUE)
	// Check that people are actually using the machine. If not, don't update anymore.
	if(obj_flags & IN_USE)
		var/is_in_use = FALSE
		if(update_viewers)
			for(var/mob/M as() in viewers(1, src))
				if ((M.client && M.machine == src))
					is_in_use = TRUE
					src.interact(M)
		var/ai_in_use = FALSE
		if(update_ais)
			ai_in_use = AutoUpdateAI(src)

		if(update_viewers && update_ais) //State change is sure only if we check both
			if(!ai_in_use && !is_in_use)
				obj_flags &= ~IN_USE


/obj/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/mob/proc/unset_machine()
	SIGNAL_HANDLER

	if(!machine)
		return
	UnregisterSignal(machine, COMSIG_PARENT_QDELETING)
	machine.on_unset_machine(src)
	machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(obj/O)
	if(machine)
		unset_machine()
	machine = O
	RegisterSignal(O, COMSIG_PARENT_QDELETING, PROC_REF(unset_machine))
	if(istype(O))
		O.obj_flags |= IN_USE

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/singularity_pull(S, current_size)
	..()
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src,S)

/obj/get_dumping_location(datum/storage/source, mob/user)
	return get_turf(src)

/**
 * This proc is used for telling whether something can pass by this object in a given direction, for use by the pathfinding system.
 *
 * Trying to generate one long path across the station will call this proc on every single object on every single tile that we're seeing if we can move through, likely
 * multiple times per tile since we're likely checking if we can access said tile from multiple directions, so keep these as lightweight as possible.
 *
 * Arguments:
 * * ID- An ID card representing what access we have (and thus if we can open things like airlocks or windows to pass through them). The ID card's physical location does not matter, just the reference
 * * to_dir- What direction we're trying to move in, relevant for things like directional windows that only block movement in certain directions
 * * pathfinding_atom- The movable we're checking pass flags for, if we're making any such checks
 **/
/obj/proc/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/passing_atom)
	if(istype(passing_atom) && (passing_atom.pass_flags & pass_flags_self))
		return TRUE
	. = !density

/obj/proc/check_uplink_validity()
	return 1

/obj/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_MASS_DEL_TYPE, "Delete all of type")
	VV_DROPDOWN_OPTION(VV_HK_OSAY, "Object Say")

/obj/vv_do_topic(list/href_list)
	if(!(. = ..()))
		return
	if(href_list[VV_HK_OSAY])
		if(check_rights(R_FUN, FALSE))
			usr.client.object_say(src)

	if(href_list[VV_HK_MASS_DEL_TYPE])
		if(check_rights(R_DEBUG|R_SERVER))
			var/action_type = alert("Strict type ([type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
			if(action_type == "Cancel" || !action_type)
				return

			if(alert("Are you really sure you want to delete all objects of type [type]?",,"Yes","No") != "Yes")
				return

			if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
				return

			var/O_type = type
			switch(action_type)
				if("Strict type")
					var/i = 0
					for(var/obj/Obj in world)
						if(Obj.type == O_type)
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No objects of this type exist")
						return
					log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
					message_admins(span_notice("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) "))
				if("Type and subtypes")
					var/i = 0
					for(var/obj/Obj in world)
						if(istype(Obj,O_type))
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No objects of this type exist")
						return
					log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
					message_admins(span_notice("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) "))

/obj/examine(mob/user)
	. = ..()
	if(desc_controls)
		. += span_notice(desc_controls)
	if(unique_reskin_icon && !current_skin)
		. += span_notice("Alt-click it to reskin it.")

/obj/examine_tags(mob/user)
	. = ..()
	if(obj_flags & UNIQUE_RENAME)
		.["renameable"] = "Use a pen on it to rename it or change its description."

/obj/AltClick(mob/user)
	. = ..()
	if(unique_reskin_icon && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		reskin_obj(user)

/obj/proc/reskin_obj(mob/M)
	var/choice = show_radial_menu(M, src, unique_reskin, radius = 42, require_near = TRUE, tooltips = TRUE)
	if(!QDELETED(src) && choice && !current_skin && !M.incapacitated() && in_range(M,src))
		if(!unique_reskin[choice])
			return
		current_skin = choice
		icon_state = unique_reskin_icon[choice]
		to_chat(M, "[src] is now skinned as '[choice].'")
		src.update_icon()
	return

/obj/analyzer_act(mob/living/user, obj/item/I)
	if(atmos_scan(user=user, target=src, silent=FALSE))
		return TRUE
	return ..()

/obj/proc/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	return

/obj/proc/log_item(mob/user, actverb="(unknown verb)", additional_info="")
	if(investigate_flags & ADMIN_INVESTIGATE_TARGET)
		if(x == 0 && y == 0 && z == 0)
			actverb = "possessed"
		investigate_log("[src] was [actverb] by [key_name(user)] at [AREACOORD(user)]. [additional_info]", INVESTIGATE_ITEMS)

//For returning special data when the object is saved
//For example, or silos will return a list of their materials which will be dumped on top of them
//Can be customised if you have something that contains something you want saved
//If you put an incorrect format it will break outputting, so don't use this if you don't know what you are doing
//NOTE: Contents is automatically saved, so if you store your things in the contents var, don't worry about this
//====Output Format Examples====:
//===Single Object===
//	"/obj/item/folder/blue"
//===Multiple Objects===
//	"/obj/item/folder/blue,\n
//	/obj/item/folder/red"
//===Single Object with metadata===
//	"/obj/item/folder/blue{\n
//	\tdir = 8;\n
//	\tname = "special folder"\n
//	\t}"
//===Multiple Objects with metadata===
//	"/obj/item/folder/blue{\n
//	\tdir = 8;\n
//	\tname = "special folder"\n
//	\t},\n
//	/obj/item/folder/red"
//====How to save easily====:
//	return "[thing.type][generate_tgm_metadata(thing)]"
//Where thing is the additional thing you want to same (For example ores inside an ORM)
//Just add ,\n between each thing
//generate_tgm_metadata(thing) handles everything inside the {} for you
/obj/proc/on_object_saved(var/depth = 0)
	return ""

// Should move all contained objects to it's location.
/obj/proc/dump_contents()
	CRASH("Unimplemented.")

/obj/handle_ricochet(obj/projectile/P)
	. = ..()
	if(. && ricochet_damage_mod)
		take_damage(P.damage * ricochet_damage_mod, P.damage_type, P.armor_flag, 0, turn(P.dir, 180), P.armour_penetration) // pass along ricochet_damage_mod damage to the structure for the ricochet

/obj/update_overlays()
	. = ..()
	if(acid_level)
		. += GLOB.acid_overlay
	if(resistance_flags & ON_FIRE)
		. += GLOB.fire_overlay

/// Handles exposing an object to reagents.
/obj/expose_reagents(list/reagents, datum/reagents/source, method=TOUCH, volume_modifier=1, show_message=TRUE)
	if((. = ..()) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_obj(src, reagents[R])

///attempt to freeze this obj if possible. returns TRUE if it succeeded, FALSE otherwise.
/obj/proc/freeze()
	if(HAS_TRAIT(src, TRAIT_FROZEN))
		return FALSE
	if(resistance_flags & FREEZE_PROOF)
		return FALSE

	AddElement(/datum/element/frozen)
	return TRUE

///unfreezes this obj if its frozen
/obj/proc/unfreeze()
	SEND_SIGNAL(src, COMSIG_OBJ_UNFREEZE)

/obj/use_emag(mob/user, obj/item/card/emag/hacker)
	if(should_emag(user) && !SEND_SIGNAL(src, COMSIG_ATOM_SHOULD_EMAG, user))
		if(hacker)
			if(hacker.charges > 0)
				SEND_SIGNAL(src, COMSIG_ATOM_ON_EMAG, user)
				hacker.use_charge()
				on_emag(user)
			else
				to_chat(user, span_warning("[hacker] is out of charges and needs some time to restore them!"))
				user.balloon_alert(user, "out of charges!")
		else
			SEND_SIGNAL(src, COMSIG_ATOM_ON_EMAG, user)
			on_emag(user)

/// Unlike COMSIG_ATOM_SHOULD_EMAG, this is not inverted. If this is true, on_emag is called.
/obj/proc/should_emag(mob/user)
	return emag_toggleable || !(obj_flags & EMAGGED)

/// Performs the actions to emag something, given that should_emag succeeded. You should NOT call this directly. Call use_emag.
/obj/proc/on_emag(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(emag_toggleable)
		obj_flags ^= EMAGGED
	else
		obj_flags |= EMAGGED

/// shows mobs in its contents to ghosts. can be used to update
/obj/proc/update_mob_alpha()
	if(!length(contents))
		SSvis_overlays.remove_mob_alpha(src)
	var/list/exception_mobs = list()
	for(var/mob/each_mob in contents)
		exception_mobs += SSvis_overlays.add_mob_alpha(src, each_mob)
	SSvis_overlays.remove_mob_alpha(src, exception_mobs)
