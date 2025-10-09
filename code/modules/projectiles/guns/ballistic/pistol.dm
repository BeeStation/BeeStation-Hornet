/obj/item/gun/ballistic/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = TRUE
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = "sound/weapons/gunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 80
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"
	bolt_wording = "slide"
	fire_rate = 3
	automatic = 0
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE
	caliber = list("10mm")

/obj/item/gun/ballistic/automatic/pistol/locker
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors. This one is rusted from being inside of a locker for so long."

/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/der38
	name = "palm pistol"
	desc = "An 'Infiltrator' double-barreled derringer, chambered in the powerful .357. Useful in a pinch but inadequate for longer engagements."
	icon_state = "derringer"
	w_class = WEIGHT_CLASS_SMALL
	item_state = null //Too small to show in hand, unless examined
	throwforce = 0 //Derringers are light and tiny, no hurtie
	mag_type = /obj/item/ammo_box/magazine/internal/der38
	load_sound = 'sound/weapons/revolverload.ogg'
	eject_sound = 'sound/weapons/revolverempty.ogg'
	can_suppress = FALSE
	casing_ejector = FALSE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT //Functionally a double-barrel shotgun
	tac_reloads = FALSE
	fire_sound_volume = 60
	spread = 18 //Innate spread of 18 degrees, unwielded spread of 48; Stechkin is unwielded 40
	weapon_weight = WEAPON_LIGHT * 0.5 //Equivelant weight to 0.5 (Stechkin has weight 1)
	equip_time = 0
	has_weapon_slowdown = FALSE

/obj/item/gun/ballistic/automatic/pistol/der38/twelveshooter //For debugging only, or meme shit
	name = "palm pistol devastator"
	desc = "By the locker of Davy Jones, it be a fuhckin' twelve barreled derringer!"
	mag_type = /obj/item/ammo_box/magazine/internal/der38/twelveshooter

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE
	caliber = list(".45")

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	rack_sound = "sound/weapons/deaglerack.ogg"
	bolt_drop_sound = "sound/weapons/deagleslidedrop.ogg"
	lock_back_sound = "sound/weapons/deaglelock.ogg"
	fire_sound = "sound/weapons/deagleshot.ogg"

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "The original Russian version of a widely used Syndicate sidearm. Uses 9mm ammo."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = "A 2 dimensional gun.. what?"
	icon_state = "flatgun"

/obj/item/gun/ballistic/automatic/pistol/stickman/equipped(mob/user, slot)
	..()
	to_chat(user, span_notice("As you try to manipulate [src], it slips out of your possession.."))
	if(prob(50))
		to_chat(user, span_notice("..and vanishes from your vision! Where the hell did it go?"))
		qdel(src)
		user.update_icons()
	else
		to_chat(user, span_notice("..and falls into view. Whew, that was a close one."))
		user.dropItemToGround(src)


// ==================================
// Officer's Pistol
// ==================================

/obj/item/gun/ballistic/automatic/pistol/service
	name = "service pistol"
	desc = "A commemorative pistol given to Nanotrasen officers designed to use higher densities of energy to emulate the ballistic service pistols that they replaced. \
	It primarilly serves as a symbol of power, but has proven to be an effective tool at enforcing the power that is portrays. \
	It fires less-lethal rounds which stun the area of the body that they burn."
	icon_state = "officer"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/recharge/service
	can_suppress = FALSE
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = FALSE
	fire_rate = 4
	can_suppress = FALSE
	worn_icon_state = "officer_pistol"
	var/stripe_state = "officer_com"

/obj/item/gun/ballistic/automatic/pistol/service/update_icon()
	. = ..()
	var/mutable_appearance/stripe = mutable_appearance(icon, stripe_state)
	if (bolt_locked)
		stripe.pixel_x = -5
	add_overlay(stripe)

/obj/item/gun/ballistic/automatic/pistol/service/captain
	stripe_state = "officer_com"

/obj/item/gun/ballistic/automatic/pistol/service/hop
	stripe_state = "officer_srv"

/obj/item/gun/ballistic/automatic/pistol/service/hos
	stripe_state = "officer_sec"

/obj/item/gun/ballistic/automatic/pistol/service/ce
	stripe_state = "officer_eng"

/obj/item/gun/ballistic/automatic/pistol/service/rd
	stripe_state = "officer_sci"

/obj/item/gun/ballistic/automatic/pistol/service/cmo
	stripe_state = "officer_med"


#define NPS10_INCENDIARY "Incendiary"
#define NPS10_SHOTGUN "Area Denial"
#define NPS10_BREACH "High Explosive"
#define NPS10_SHOCK "Shock"
#define NPS10_IMPACT "Impact"
#define NPS10_ION "EM-Pulse"

// Security // Christ this might deserve it's own file
/obj/item/gun/ballistic/automatic/pistol/security
	name = "NPS-10"
	desc = "Standard APS smart-firearm for on-station law enforcement. Low-velocity and unlikely to breach the hull. Uses x200 LAW ammo cartridges."
	icon_state = "sec"
	w_class = WEIGHT_CLASS_LARGE
	mag_type = /obj/item/ammo_box/magazine/x200law
	can_suppress = FALSE
	worn_icon_state = "officer_pistol"
	empty_alarm = TRUE
	rack_sound = 'sound/weapons/nps10/NPS-rack.ogg'
	load_empty_sound = 'sound/weapons/nps10/NPS-load.ogg'
	bolt_drop_sound = 'sound/weapons/nps10/NPS-boltdrop.ogg'
	lock_back_sound = 'sound/weapons/nps10/NPS-lockback.ogg'
	fire_sound = 'sound/weapons/nps10/NPS-fire.ogg'
	recoil = 0.1

	var/special_ammo_mag_max = 6 // Max amount we can carry
	var/special_ammo_reserve = 6 // How many special shots we have left
	var/special_authorized = FALSE
	var/selected_special
	var/cooldown_length = 5 SECONDS
	var/list/special_types = list()
	actions_types = list(/datum/action/item_action/nps_special)

	// Callout lists
	var/list/incendiary_callouts = list("Incendiary." = 3, "Hotshot." = 2, "Burner." = 1)
	var/list/shotgun_callouts = list("Area." = 3, "Multishot." = 2, "Spreader." = 1)
	var/list/breach_callouts = list("High-Ex." = 3, "Breacher." = 2, "Explosive." = 1)
	var/list/shock_callouts = list("Stun." = 3, "Shock." = 2, "Incap." = 1)
	var/list/impact_callouts = list("Impact." = 3, "Bruiser." = 2, "Bully." = 1)
	var/list/ion_callouts = list("EM." = 3, "Gauss." = 2, "Jolt." = 1)

	COOLDOWN_DECLARE(special_round_chambering)

/obj/item/gun/ballistic/automatic/pistol/security/Initialize()
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(security_level))
	RegisterSignal(src, COMSIG_ITEM_UI_ACTION_CLICK, PROC_REF(on_action_click))

/obj/item/gun/ballistic/automatic/pistol/security/proc/generate_radial()
	// Generate radial menu
	for (var/obj/item/ammo_casing/x200special/possible_special as anything in subtypesof(/obj/item/ammo_casing/x200special))
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = possible_special.icon, icon_state = possible_special.radial_sprite)
		option.info = "[possible_special.special_name]\n[possible_special.explanation]"
		special_types[possible_special.special_name] = option

/obj/item/gun/ballistic/automatic/pistol/security/proc/security_level()
	SIGNAL_HANDLER
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED && !special_authorized)

		addtimer(CALLBACK(src, PROC_REF(special_action), TRUE), rand(25, 50) DECISECONDS)

	else if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED && special_authorized)

		addtimer(CALLBACK(src, PROC_REF(special_deauth), TRUE), rand(25, 50) DECISECONDS)

/obj/item/gun/ballistic/automatic/pistol/security/proc/special_action()
		audible_message("<span class='italics'>You hear a beep from \the [name].</span>", null, 1)
		balloon_alert_to_viewers("Red Alert signal detected: Authorising special ammo.")
		playsound(src, 'sound/weapons/nps10/NPS-specialon.ogg', 30)
		special_authorized = TRUE

/obj/item/gun/ballistic/automatic/pistol/security/proc/special_deauth()
		audible_message("<span class='italics'>You hear a beep from \the [name].</span>", null, 1)
		balloon_alert_to_viewers("Red Alert signal lost: Special ammo modules disengaged.")
		playsound(src, 'sound/weapons/nps10/NPS-specialoff.ogg', 30)
		special_authorized = FALSE
		unchamber_special()

/// Signal proc for [COMSIG_ITEM_UI_ACTION_CLICK] if our action button is clicked.
/obj/item/gun/ballistic/automatic/pistol/security/proc/on_action_click(obj/item/source, mob/user, datum/action)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, special_round_chambering))
		balloon_alert_to_viewers("Function on cooldown.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return COMPONENT_ACTION_HANDLED

	if(special_authorized)
		// Do we already have one selected? If yes, unchamber it.
		if(selected_special)
			unchamber_special()
		else
			INVOKE_ASYNC(src, PROC_REF(radial_special_picker), user)
	else
		balloon_alert_to_viewers("Not Authorized.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)

	return COMPONENT_ACTION_HANDLED

/obj/item/gun/ballistic/automatic/pistol/security/proc/radial_special_picker(mob/user)

	generate_radial()

	var/callout

	var/selection = show_radial_menu(user, src, special_types, radius = 40, require_near = TRUE, tooltips = TRUE)

	switch(selection)
		if(NPS10_INCENDIARY)
			callout = pick_weight(incendiary_callouts)
		if(NPS10_SHOTGUN)
			callout = pick_weight(shotgun_callouts)
		if(NPS10_BREACH)
			callout = pick_weight(breach_callouts)
		if(NPS10_SHOCK)
			callout = pick_weight(shock_callouts)
		if(NPS10_IMPACT)
			callout = pick_weight(impact_callouts)
		if(NPS10_ION)
			callout = pick_weight(ion_callouts)
		else
			return

	user.say(callout)

	addtimer(CALLBACK(src, PROC_REF(chamber_special), selection), 1.5 SECONDS)
	return

/obj/item/gun/ballistic/automatic/pistol/security/on_chamber_fired()
	. = ..()
	if(selected_special)
		selected_special = null

/obj/item/gun/ballistic/automatic/pistol/security/proc/get_dna()
	var/obj/item/firing_pin/dna/D = pin
	return D.unique_enzymes ? D.unique_enzymes : null

/obj/item/gun/ballistic/automatic/pistol/security/attackby(obj/item/O, mob/user, params)
	if(get_dna() && (ACCESS_ARMORY in O.GetAccess()))
		to_chat(user, "<span class='notice'>You reset the DNA lock.</span>")
		var/obj/item/firing_pin/dna/D = pin
		D.unique_enzymes = null
		if(D.obj_flags & EMAGGED)
			D.obj_flags &= ~EMAGGED
		investigate_log("dna lock reset by [key_name(user)]", INVESTIGATE_RECORDS)
	..()

/obj/item/gun/ballistic/automatic/pistol/security/emp_act(severity)
	audible_message("<span class='italics'>You hear erratic beeping from \the [name].</span>", null,  1)
	var/obj/item/firing_pin/dna/D = pin
	D.unique_enzymes = null
	investigate_log("dna lock reset by EMP", INVESTIGATE_RECORDS)
	..()

/obj/item/gun/ballistic/automatic/pistol/security/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 16, \
		overlay_y = 12)

/obj/item/gun/ballistic/automatic/pistol/security/examine(mob/user)
	. = ..()

	. += span_notice("<i>Features a Warden-resettable DNA lock, as well as a Red-Alert locked smart ammunition mode.</i>")
	. += span_notice("<b>There are [special_ammo_reserve] special rounds left!</b>")

	var/dna = get_dna()
	if(pin.obj_flags & EMAGGED)
		. += "<span class='warning'>The DNA lock flashes erratically! Use an ID with armory access to reset.</span>"
	else if(dna)
		. += "<span class='notice'>It is currently registered to: [dna]. Use an ID with armory access to reset.</span>"
	else
		. += "<span class='notice'>It is unregistered.</span>"

	. += span_warning("Smart-Ammo is <b>[special_authorized ? "authorized" : "disabled"]</b>.")

/datum/action/item_action/nps_special
	name = "Special Ammo"
	desc = "Select a special projectile mode from a list of options."

/obj/item/gun/ballistic/automatic/pistol/security/Destroy()
	UnregisterSignal(src, COMSIG_ITEM_UI_ACTION_CLICK)
	UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	. = ..()

/obj/item/gun/ballistic/automatic/pistol/security/proc/chamber_special(special)
	if(selected_special)
		return

	if(special_ammo_reserve < 1)
		balloon_alert_to_viewers("Ammo depleted.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return

	// Is a bullet chambered
	if(chambered)
		// Add a new round to the magazine (to simulate moving it out of the chamber)
		magazine.give_round(chambered)

	// Creating the round
	switch(special)
		if(NPS10_INCENDIARY)
			chambered = new/obj/item/ammo_casing/x200special/incendiary(src)
		if(NPS10_SHOTGUN)
			chambered = new/obj/item/ammo_casing/x200special/shotgun(src)
		if(NPS10_BREACH)
			chambered = new/obj/item/ammo_casing/x200special/breach(src)
		if(NPS10_SHOCK)
			chambered = new/obj/item/ammo_casing/x200special/shock(src)
		if(NPS10_IMPACT)
			chambered = new/obj/item/ammo_casing/x200special/impact(src)
		if(NPS10_ION)
			chambered = new/obj/item/ammo_casing/x200special/ion(src)
		else
			return

	balloon_alert_to_viewers("[special] selected.")

	COOLDOWN_START(src, special_round_chambering, cooldown_length)
	special_ammo_reserve--
	selected_special = special
	playsound(src, 'sound/weapons/nps10/NPS-specialon.ogg', 30)

/obj/item/gun/ballistic/automatic/pistol/security/proc/unchamber_special()
	if(selected_special)
		balloon_alert_to_viewers("Selection reset")
		qdel(chambered)
		special_ammo_reserve++
		selected_special = null
		rack()

/obj/item/gun/ballistic/automatic/pistol/security/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/x200special_charge))
		if(special_ammo_reserve >= special_ammo_mag_max)
			to_chat(user, span_notice("It's already full!"))
			return

		to_chat(user, span_notice("You carefully insert the charge..."))
		if(!do_after(user, delay = 0.5 SECONDS, target = src))
			return

		to_chat(user, span_notice("You insert the charge into the access port."))
		playsound(src, 'sound/weapons/nps10/NPS-load.ogg', 30)
		special_ammo_reserve++
		qdel(A)

// Special Bullets!
/obj/item/x200special_charge
	icon = 'icons/obj/ammo.dmi'
	icon_state = "x200special_charge"
	name = "x200 SPECIAL Smart-Ammo cartridge"
	desc = "This nifty little thing neatly slots into the bottom of any x200 compatible firearm. Capable of somehow adjusting to fit many different functions, the inner workings of this little device are a mystery to anyone outside Nanotrasen's specialist research and manufacturing blacksites."
	resistance_flags = FLAMMABLE

/obj/item/ammo_casing/x200special
	name = "x200 SPECIAL bullet casing"
	desc = "A x200 SPECIAL bullet casing."
	caliber = "x200 LAW"
	icon_state = "x200special"
	projectile_type = /obj/projectile/bullet/x200law
	var/special_name = "Dummy"
	var/explanation = "All of this is dummies rn"
	var/radial_sprite = "x200special"

// No inherent burn damage, half as powerful as the other one, less range than incendiary shells, and doesn't last that long.
/obj/item/ammo_casing/x200special/incendiary
	special_name = NPS10_INCENDIARY
	explanation = "Concentrated incendiary particle spray, longer range but less effective than an ordinary flamethrower."
	radial_sprite = "ishell-live"
	projectile_type = /obj/projectile/bullet/incendiary/nps10_incendiary_special

/obj/projectile/bullet/incendiary/nps10_incendiary_special
	name = "incendiary blast"
	damage = 10
	damage_type = BURN
	fire_stacks = 2
	projectile_piercing = PASSMOB | PASSMACHINE
	projectile_phasing = PASSBLOB | PASSANOMALY
	suppressed = SUPPRESSED_VERY
	hitsound = null
	bleed_force = 0

	range = 8
	speed = 0.8

// Shotgun but: Worse armor pen, worse damage, higher spread, but also more uniform spread.
/obj/item/ammo_casing/x200special/shotgun
	special_name = NPS10_SHOTGUN
	explanation = "Lead-composite pellet ejection for wide area saturation."
	radial_sprite = "gnshell-live"
	projectile_type = /obj/projectile/bullet/pellet/nps10_shotgun_special
	pellets = 10
	variance = 45
	even_distribution = TRUE

/obj/projectile/bullet/pellet/nps10_shotgun_special
	name = "buckshot pellet"
	damage = 6
	tile_dropoff = 0.25
	ricochets_max = 1
	ricochet_chance = 80
	ricochet_incidence_leeway = 40
	ricochet_decay_chance = 0.75
	armour_penetration = 0

// Pretty big nerf on regular breaching rounds in exchange for a mediocre explosive effect.
/obj/item/ammo_casing/x200special/breach
	special_name = NPS10_BREACH
	explanation = "A Titanium-tipped anti-material high-explosive payload. Great for breaching airlocks and windows."
	radial_sprite = "breacher-live"
	projectile_type = /obj/projectile/bullet/nps10_breaching_special

/obj/projectile/bullet/nps10_breaching_special
	name = "breaching round"
	desc = "A Titanium-tipped anti-material high-explosive payload. Great for breaching airlocks and windows."
	damage = 10
	bleed_force = BLEED_SURFACE

/obj/projectile/bullet/nps10_breaching_special/on_hit(atom/target)
	new /obj/effect/temp_visual/explosion/fast(target.loc)

	if(isstructure(target) || ismachinery(target))
		damage = 250
	if (isturf(target))
		damage = 100
	explosion(target, -1, -1, 1, 2)

	..()

// Visual shock effect but no actual shock stun. You take 10 damage, get a bit jittery, take 20 stamina damage, and are stunned for a fraction of a second second.
/obj/item/ammo_casing/x200special/shock
	special_name = NPS10_SHOCK
	explanation = "High speed electrical discharge device, designed for the delivery of an instantaneus shock to a target."
	radial_sprite = "lshell-live"
	projectile_type = /obj/projectile/bullet/nps10_shock_special

/obj/projectile/bullet/nps10_shock_special
	name = "shock round"
	desc = "High speed electrical discharge device, designed for the delivery of an instantaneus shock to a target."
	icon_state = "bolter"
	damage = 5
	damage_type = BURN
	bleed_force = 0
	stun = 5
	stamina = 20

/obj/projectile/bullet/nps10_shock_special/on_hit(atom/target)
	if(isliving(target))
		var/mob/living/M = target
		M.electrocute_act(5, src, 1, flags = SHOCK_NOGLOVES | SHOCK_NOSTUN)
		M.emote("scream")
		playsound(src, 'sound/weapons/zapbang.ogg', 80)
	..()

// HIRR baton slugs from cm13. Fun. While I did look at how they did it, that was fucking WACK complicated. I did my own shizzazz using dirs and not angles. Less accurate, but who gives a shit.
/obj/item/ammo_casing/x200special/impact
	special_name = NPS10_IMPACT
	explanation = "Rubberized baton-slug with metal core. Useful for breaking people's ribs into their lungs."
	radial_sprite = "stunshell"
	projectile_type = /obj/projectile/bullet/nps10_impact_special

/obj/projectile/bullet/nps10_impact_special
	name = "impact round"
	desc = "Rubberized baton-slug with metal core. Useful for breaking people's ribs into their lungs."
	icon_state = "impact_slug"
	damage = 10
	damage_type = BRUTE
	bleed_force = 0

	knockdown = 10
	stutter = 20
	stamina = 15

/obj/projectile/bullet/nps10_impact_special/on_hit(atom/target)
	if(isliving(target))
		var/mob/living/smacked = target

		var/obj/item/trash/impact_slug/garbo = new /obj/item/trash/impact_slug(get_turf(target))
		garbo.update_appearance()
		garbo.SpinAnimation(10, 1)

		// We check which turf is one step away from our target, in the direction of the angle of the bullet. Christ. We do this twice, for range.
		var/temp_turf = get_turf(get_step(smacked.loc, angle2dir(Angle)))
		var/target_turf = get_turf(get_step(temp_turf, angle2dir(Angle)))

		smacked.throw_at(target_turf, 2, 1, spin = FALSE)
		playsound(src, 'sound/weapons/cqchit2.ogg', 100, falloff_distance = 5)
	..()

/obj/item/trash/impact_slug
	icon = 'icons/obj/janitor.dmi'
	icon_state = "impact_slug"
	name = "Impact slug"
	desc = "This is rubbish. Painful rubbish."
	resistance_flags = INDESTRUCTIBLE
	throwforce = 10

// Literally just the weak ion shot. Except massively ammo limited and basically no real rate of fire.
/obj/item/ammo_casing/x200special/ion
	special_name = NPS10_ION
	explanation = "Bi-Charge weaved electrodynamic projectile. Disables most technology on impact."
	radial_sprite = "ionshell-live"
	projectile_type = /obj/projectile/ion/weak

#undef NPS10_INCENDIARY
#undef NPS10_SHOTGUN
#undef NPS10_BREACH
#undef NPS10_SHOCK
#undef NPS10_IMPACT
#undef NPS10_ION
