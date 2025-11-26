/obj/item/gun/ballistic/taser
	name = "APS-Arc Ballistic Taser"
	desc = "Standard taser for on-station APS enforcement. While principially less-lethal, overuse is highly discouraged due to the chance for heart-attacks."
	icon_state = "taser"
	item_state = "ballistic_taser"
	worn_icon_state = "officer_pistol"
	magazine_wording = "taser cartridge"
	cartridge_wording = "taser cartridge"
	fire_sound = 'sound/weapons/taser/shot.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/taser
	w_class = WEIGHT_CLASS_LARGE
	can_suppress = FALSE
	fire_rate = 1
	throwforce = 0
	weapon_weight = WEAPON_LIGHT
	bolt_type = BOLT_TYPE_NO_BOLT
	casing_ejector = TRUE
	tac_reloads = FALSE
	internal_magazine = TRUE
	has_weapon_slowdown = FALSE

/obj/item/gun/ballistic/taser/after_live_shot_fired(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	var/turf/current_location = get_turf(user)
	current_location.add_emitter(/obj/emitter/confetti/taser, "taser_confetti", 10, lifespan = 15)
	chambered = null
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		CB.forceMove(drop_location())
		CB.bounce_away(FALSE, NONE)
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/taser/update_overlays()
	. = ..()
	var/mutable_appearance/cartridge = mutable_appearance(icon, "taser_cartridge")
	if(magazine?.ammo_count() >= 1)
		. += cartridge

/obj/item/gun/ballistic/taser/examine(mob/user)
	. = ..()
	. += "While traditionally challenging to aim, tests have shown that officer's accuracy greatly improves when this weapon is used in combination with the SecHUD, specially when targets are painted as 'wanted'."
	. += span_notice("<i>You could examine it more thoroughly...</i>")

/obj/item/gun/ballistic/taser/examine_more(mob/user)
	. = ..()
	. += "<i>The APS-Arc is a compact stunner made from impact-resistant polymer, developed by Nanotrasen for use by APS officers in the field. \
		Each reloadable cartridge snaps in a pre-spooled wire spindle and barbed contact needles, primed for a precise and long-lasting electrical jolt. And officers can swap or reload spares in seconds too! \
		This Lightweight and virtually silent design uilizes a manually cocked hammer to puncture the internal propellant load, it's the go-anywhere, reliable, less-lethal option security teams rely on.</i>"
