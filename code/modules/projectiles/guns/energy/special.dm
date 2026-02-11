/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man-portable anti-armor weapon designed to disable mechanical threats at range."
	icon_state = "ionrifle"
	inhand_icon_state = null //so the human update icon uses the icon_state instead.
	worn_icon_state = null
	w_class = WEIGHT_CLASS_HUGE
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion) //Heavy EMP, 15 shots
	ammo_x_offset = 3
	fire_rate = 1.5
	gun_charge = 12000 WATT

/obj/item/gun/energy/ionrifle/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 17, \
		overlay_y = 9)

/obj/item/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is much faster, built to be ergonomic and efficient, but packs less of a punch per shot."
	icon_state = "ioncarbine"
	worn_icon_state = "ioncarbine"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	pin = null
	ammo_type = list(/obj/item/ammo_casing/energy/ion/weak) //Light EMP, 24 shots
	ammo_x_offset = 2
	fire_rate = 2.5
	full_auto = TRUE

/obj/item/gun/energy/ionrifle/carbine/add_seclight_point()
	. = ..()
	// We use the same overlay as the parent, so we can just let the component inherit the correct offsets here
	AddComponent(/datum/component/seclite_attachable, overlay_x = 18, overlay_y = 11)

/obj/item/gun/energy/ionrifle/carbine/pin
	pin = /obj/item/firing_pin

/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	pin = null
	ammo_x_offset = 1

/obj/item/gun/energy/decloner/update_overlays()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(!QDELETED(cell) && (cell.charge > shot.e_cost))
		. += mutable_appearance(icon, "decloner_spin")
		if (emissive_charge)
			. += emissive_appearance(icon, "decloner_spin", layer, alpha = 80)
			ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/item/gun/energy/decloner/unrestricted
	pin = /obj/item/firing_pin
	ammo_type = list(/obj/item/ammo_casing/energy/declone/weak)

/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	inhand_icon_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = 1

/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "meteor_gun"
	inhand_icon_state = "c20r"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1
	automatic_charge_overlays = FALSE

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	inhand_icon_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	automatic_charge_overlays = FALSE

/obj/item/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
	ammo_x_offset = 2

/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	inhand_icon_state = "plasmacutter"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("attacks", "slashes", "cuts", "slices")
	attack_verb_simple = list("attack", "slash", "cut", "slice")
	force = 12
	sharpness = SHARP
	can_charge = FALSE
	dead_cell = TRUE
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	tool_behaviour = TOOL_WELDER
	weapon_weight = WEAPON_LIGHT
	fire_rate = 0.5 
	automatic = 1
	toolspeed = 0.7 //plasmacutters can be used as welders, and are faster than standard welders
	var/progress_flash_divisor = 10  //copypasta is best pasta
	var/light_intensity = 1
	var/charge_weld = 25 //amount of charge used up to start action (multiplied by amount) and per progress_flash_divisor ticks of welding
	var/heat_weld = 3800

/obj/item/gun/energy/plasmacutter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 25, 105, 0, 'sound/weapons/plasma_cutter.ogg')

/obj/item/gun/energy/plasmacutter/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("[src] is [round(cell.percent())]% charged.")

/obj/item/gun/energy/plasmacutter/attackby(obj/item/I, mob/user)
	var/charge_multiplier = 0 //2 = Refined stack, 1 = Ore
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		charge_multiplier = 2
	if(istype(I, /obj/item/stack/ore/plasma))
		charge_multiplier = 1
	if(charge_multiplier)
		if(cell.charge == cell.maxcharge)
			to_chat(user, span_notice("You try to insert [I] into [src], but it's fully charged.")) //my cell is round and full
			return
		I.use(1)
		cell.give(5 KILOWATT *charge_multiplier)
		to_chat(user, span_notice("You insert [I] in [src], recharging it."))
	else
		..()

// Tool procs, in case plasma cutter is used as welder
// Can we start welding?
/obj/item/gun/energy/plasmacutter/tool_start_check(mob/living/user, amount)
	. = tool_use_check(user, amount)
	if(. && user)
		user.flash_act(light_intensity)

// Can we weld? Plasma cutter does not use charge continuously.
// Amount cannot be defaulted to 1: most of the code specifies 0 in the call.
/obj/item/gun/energy/plasmacutter/tool_use_check(mob/living/user, amount)
	if(QDELETED(cell))
		to_chat(user, span_warning("[src] does not have a cell, and cannot be used!"))
		return FALSE
	// Amount cannot be used if drain is made continuous, e.g. amount = 5, charge_weld = 25
	// Then it'll drain 125 at first and 25 periodically, but fail if charge dips below 125 even though it still can finish action
	// Alternately it'll need to drain amount*charge_weld every period, which is either obscene or makes it free for other uses
	if(amount ? cell.charge < charge_weld * amount : cell.charge < charge_weld)
		to_chat(user, span_warning("You need more charge to complete this task!"))
		return FALSE

	return TRUE

/obj/item/gun/energy/plasmacutter/use(amount)
	return (!QDELETED(cell) && cell.use(amount ? amount * charge_weld : charge_weld))

// This only gets called by use_tool(delay > 0)
// It's also supposed to not get overridden in the first place.
/obj/item/gun/energy/plasmacutter/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	. = ..() //return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())
	if(. && user)
		if (progress_flash_divisor == 0)
			user.flash_act(min(light_intensity,1))
			progress_flash_divisor = initial(progress_flash_divisor)
		else
			progress_flash_divisor--

/obj/item/gun/energy/plasmacutter/use_tool(atom/target, mob/living/user, delay, amount=1, volume=0, datum/callback/extra_checks)
	if(amount)
		target.add_overlay(GLOB.welding_sparks)
		. = ..()
		target.cut_overlay(GLOB.welding_sparks)
	else
		. = ..(amount=1)

/obj/item/gun/energy/plasmacutter/is_hot()
	if(use(1))
		return heat_weld
	return heat


/obj/item/gun/energy/plasmacutter/update_icon()
	return

/obj/item/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	inhand_icon_state = "adv_plasmacutter"
	force = 15
	fire_rate = 0.75
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)

/obj/item/gun/energy/plasmacutter/cyborg
	name = "cyborg plasma cutter"
	desc = "An integrated plasma cutter."
	dead_cell = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE
	tool_behaviour = null //because it will drain the cutters cell and not the borgs.
	requires_wielding = FALSE


/obj/item/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	inhand_icon_state = null
	icon_state = "wormhole_projector"
	automatic_charge_overlays = FALSE
	var/obj/effect/portal/p_blue
	var/obj/effect/portal/p_orange
	var/atmos_link = FALSE

/obj/item/gun/energy/wormhole_projector/update_icon()
	icon_state = "[initial(icon_state)][select]"
	inhand_icon_state = icon_state

/obj/item/gun/energy/wormhole_projector/update_ammo_types()
	. = ..()
	for(var/i in 1 to ammo_type.len)
		var/obj/item/ammo_casing/energy/wormhole/W = ammo_type[i]
		if(istype(W))
			W.gun = WEAKREF(src)
			var/obj/projectile/beam/wormhole/WH = W.BB
			if(istype(WH))
				WH.gun = WEAKREF(src)

/obj/item/gun/energy/wormhole_projector/on_chamber_fired()
	..()
	select_fire()

/obj/item/gun/energy/wormhole_projector/proc/on_portal_destroy(obj/effect/portal/P)
	if(P == p_blue)
		p_blue = null
	else if(P == p_orange)
		p_orange = null

/obj/item/gun/energy/wormhole_projector/proc/has_blue_portal()
	if(istype(p_blue) && !QDELETED(p_blue))
		return TRUE
	return FALSE

/obj/item/gun/energy/wormhole_projector/proc/has_orange_portal()
	if(istype(p_orange) && !QDELETED(p_orange))
		return TRUE
	return FALSE

/obj/item/gun/energy/wormhole_projector/proc/crosslink()
	if(!has_blue_portal() && !has_orange_portal())
		return
	if(!has_blue_portal() && has_orange_portal())
		p_orange.link_portal(null)
		return
	if(!has_orange_portal() && has_blue_portal())
		p_blue.link_portal(null)
		return
	p_orange.link_portal(p_blue)
	p_blue.link_portal(p_orange)

/obj/item/gun/energy/wormhole_projector/proc/create_portal(obj/projectile/beam/wormhole/W, turf/target)
	var/obj/effect/portal/P = new /obj/effect/portal(target, src, 300, null, FALSE, null, atmos_link)
	if(istype(W, /obj/projectile/beam/wormhole/orange))
		qdel(p_orange)
		p_orange = P
		P.icon_state = "portal1"
	else
		qdel(p_blue)
		p_blue = P
	crosslink()

/* 3d printer 'pseudo guns' for borgs */

/obj/item/gun/energy/printer
	name = "cyborg lmg"
	desc = "An LMG that fires 3D-printed flechettes. They are slowly resupplied using the cyborg's internal power source."
	icon_state = "l6_cyborg"
	icon = 'icons/obj/guns/projectile.dmi'
	gun_charge = 6 KILOWATT
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = FALSE
	use_cyborg_cell = TRUE
	automatic = 1
	fire_rate = 6
	requires_wielding = FALSE

/obj/item/gun/energy/printer/update_icon()
	return

/obj/item/gun/energy/printer/emp_act()
	return

/obj/item/gun/energy/temperature
	name = "temperature gun"
	icon_state = "freezegun"
	desc = "A gun that changes temperatures."
	ammo_type = list(/obj/item/ammo_casing/energy/temp, /obj/item/ammo_casing/energy/temp/hot)
	gun_charge = 100 KILOWATT
	automatic = 1
	fire_rate = 4
	pin = null

/obj/item/gun/energy/temperature/pin
	pin = /obj/item/firing_pin

/obj/item/gun/energy/temperature/security
	name = "security temperature gun"
	desc = "A weapon that can only be used to its full potential by the truly robust."
	pin = /obj/item/firing_pin
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	inhand_icon_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	charge_sections = 5
	ammo_x_offset = 2
	shaded_charge = FALSE

/obj/item/gun/energy/laser/instakill/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	inhand_icon_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/gun/energy/laser/instakill/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	inhand_icon_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/gravity_gun
	name = "one-point bluespace-gravitational manipulator"
	desc = "An experimental, multi-mode device that fires bolts of Zero-Point Energy, causing local distortions in gravity."
	ammo_type = list(/obj/item/ammo_casing/energy/gravity/repulse, /obj/item/ammo_casing/energy/gravity/attract, /obj/item/ammo_casing/energy/gravity/chaos)
	inhand_icon_state = "gravity_gun"
	icon_state = "gravity_gun"
	automatic_charge_overlays = FALSE
	fire_rate = 0.2
	var/power = 4
