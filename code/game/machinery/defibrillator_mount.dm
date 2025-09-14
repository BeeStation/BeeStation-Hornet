//Holds defibs and recharges them from the powernet
//You can activate the mount with an empty hand to grab the paddles
//Not being adjacent will cause the paddles to snap back
/obj/machinery/defibrillator_mount
	name = "defibrillator mount"
	desc = "Holds and recharges defibrillators. You can grab the paddles if one is mounted."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	power_channel = AREA_USAGE_EQUIP
	req_one_access = list(ACCESS_MEDICAL, ACCESS_HEADS, ACCESS_SECURITY) //used to control clamps
	processing_flags = NONE
	layer = ABOVE_WINDOW_LAYER
	var/obj/item/defibrillator/defib //this mount's defibrillator
	var/clamps_locked = FALSE //if true, and a defib is loaded, it can't be removed without unlocking the clamps

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/defibrillator_mount, 28)

/obj/machinery/defibrillator_mount/loaded/Initialize(mapload) //loaded subtype for mapping use
	. = ..()
	defib = new/obj/item/defibrillator/loaded(src)
	update_icon()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/defibrillator_mount/loaded, 28)

/obj/machinery/defibrillator_mount/Destroy()
	if(defib)
		QDEL_NULL(defib)
		end_processing()
	. = ..()

/obj/machinery/defibrillator_mount/atom_destruction()
	if(defib)
		defib.forceMove(get_turf(src))
		defib.visible_message(span_notice("[defib] falls to the ground from the destroyed wall mount."))
		defib = null
		end_processing()
	return ..()


/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += span_notice("There is a defib unit hooked up. Alt-click to remove it.")
		if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
			. += span_notice("Due to a security situation, its locking clamps can be toggled by swiping any ID.")
		else
			. += span_notice("Its locking clamps can be [clamps_locked ? "dis" : ""]engaged by swiping an ID with access.")
	else
		. += span_notice("It's <i>empty</i> and can be <b>pried</b> off the wall.")

/obj/machinery/defibrillator_mount/process()
	if(defib?.cell && defib.cell.charge < defib.cell.maxcharge && is_operational)
		var/power_to_use = 200 WATT
		use_power(power_to_use)
		defib.cell.give(power_to_use * POWER_TRANSFER_LOSS)
		update_icon()

/obj/machinery/defibrillator_mount/update_icon()
	cut_overlays()
	if(defib)
		add_overlay("defib")
		if(defib.powered)
			add_overlay(defib.safety ? "online" : "emagged")
			var/ratio = defib.cell.charge / defib.cell.maxcharge
			ratio = CEILING(ratio * 4, 1) * 25
			add_overlay("charge[ratio]")
		if(clamps_locked)
			add_overlay("clamps")

/obj/machinery/defibrillator_mount/get_cell()
	if(defib)
		return defib.get_cell()

SCREENTIP_ATTACK_HAND(/obj/machinery/defibrillator_mount, "Use")

//defib interaction
/obj/machinery/defibrillator_mount/attack_hand(mob/living/user)
	if(!defib)
		to_chat(user, span_warning("There's no defibrillator unit loaded!"))
		return
	if(defib.paddles.loc != defib)
		to_chat(user, span_warning("[defib.paddles.loc == user ? "You are already" : "Someone else is"] holding [defib]'s paddles!"))
		return
	user.put_in_hands(defib.paddles)

/obj/machinery/defibrillator_mount/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/defibrillator))
		if(defib)
			to_chat(user, span_warning("There's already a defibrillator in [src]!"))
			return
		if(HAS_TRAIT(I, TRAIT_NODROP) || !user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] hooks up [I] to [src]!"), \
		span_notice("You press [I] into the mount, and it clicks into place."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		defib = I
		begin_processing()
		update_icon()
		return
	else if(defib && I == defib.paddles)
		defib.paddles.snap_back()
		return
	var/obj/item/card/id = I.GetID()
	if(id)
		if(check_access(id) || SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
			if(!defib)
				to_chat(user, span_warning("You can't engage the clamps on a defibrillator that isn't there."))
				return
			clamps_locked = !clamps_locked
			to_chat(user, span_notice("Clamps [clamps_locked ? "" : "dis"]engaged."))
			update_icon()
		else
			to_chat(user, span_warning("Insufficient access."))
		return
	..()

/obj/machinery/defibrillator_mount/multitool_act(mob/living/user, obj/item/multitool)
	if(!defib)
		to_chat(user, span_warning("There isn't any defibrillator to clamp in!"))
		return TRUE
	if(!clamps_locked)
		to_chat(user, span_warning("[src]'s clamps are disengaged!"))
		return TRUE
	user.visible_message(span_notice("[user] presses [multitool] into [src]'s ID slot..."), \
	span_notice("You begin overriding the clamps on [src]..."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	if(!do_after(user, 100, target = src) || !clamps_locked)
		return
	user.visible_message(span_notice("[user] pulses [multitool], and [src]'s clamps slide up."), \
	span_notice("You override the locking clamps on [src]!"))
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	clamps_locked = FALSE
	update_icon()
	return TRUE

/obj/machinery/defibrillator_mount/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(!defib)
		to_chat(user, span_warning("It'd be hard to remove a defib unit from a mount that has none."))
		return
	if(clamps_locked)
		to_chat(user, span_warning("You try to tug out [defib], but the mount's clamps are locked tight!"))
		return
	if(!user.put_in_hands(defib))
		to_chat(user, span_warning("You need a free hand!"))
		return
	user.visible_message(span_notice("[user] unhooks [defib] from [src]."), \
	span_notice("You slide out [defib] from [src] and unhook the charging cables."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	// Make sure processing ends before the defib is nulled
	end_processing()
	defib = null
	update_icon()

/obj/machinery/defibrillator_mount/crowbar_act(mob/living/user, obj/item/W)
	if(!defib)
		W.play_tool_sound(src, 75)
		user.visible_message(span_notice("[user.name] starts prying the [src] off the wall."), \
							span_notice("You start prying the defibrillator mount off the wall."))
		if(W.use_tool(src, user, 30, volume=50, amount = 0))
			new /obj/item/wallframe/defib_mount(loc)
			user.visible_message(\
				span_notice("[user.name] pries the [src] off the wall with [W]."),\
				span_notice("You pry the defibrillator mount off the wall."))
			qdel(src)
			return TRUE

//wallframe, for attaching the mounts easily
/obj/item/wallframe/defib_mount
	name = "unhooked defibrillator mount"
	desc = "A frame for a defibrillator mount. It can't be removed once it's placed."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	custom_materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/machinery/defibrillator_mount
	pixel_shift = 28
