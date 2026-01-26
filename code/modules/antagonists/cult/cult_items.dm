/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON

/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	block_power = 0
	canblock = FALSE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 15
	throwforce = 12 // unlike normal daggers, this one is curved and not designed to be thrown
	armour_penetration = 35

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/blood.dmi' , icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", silicon_image)

	var/examine_text = {"Allows the scribing of blood runes of the cult of Nar'Sie.
Hitting a cult structure will unanchor or reanchor it. Cult Girders will be destroyed in a single blow.
Can be used to scrape blood runes away, removing any trace of them.
Striking another cultist with it will purge all holy water from them and transform it into unholy water.
Striking a noncultist, however, will tear their flesh."}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text))

/obj/item/melee/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	w_class = WEIGHT_CLASS_BULKY
	canblock = TRUE

	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	force = 23

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!IS_CULTIST(user))
		user.visible_message(span_warning("[user] cringes as they strike [target]!"), \
							span_userdanger("Your arm throbs and your brain hurts!"))
		user.adjustStaminaLoss(rand(force/2,force))
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(force/10,force/2))
	if (target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		force = 15
	else
		force = 22
	..()

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL | ISWEAPON
	flags_1 = NONE

/obj/item/melee/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))

/datum/action/innate/dash/cult
	name = "Rend the Veil"
	desc = "Use the sword to shear open the flimsy fabric of this reality and teleport to your target."
	button_icon = 'icons/hud/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/is_available(feedback = FALSE)
	if(IS_CULTIST(owner) && current_charges)
		return TRUE
	else
		return FALSE

/obj/item/restraints/legcuffs/bola/cult
	name = "\improper Nar'Sien bola"
	desc = "A strong bola, bound with dark magic that allows it to pass harmlessly through Nar'Sien cultists. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	inhand_icon_state = "bola_cult"
	breakouttime = 6 SECONDS
	knockdown = 2 SECONDS

/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return
	var/mob/living/living_target = hit_atom
	if(IS_CULTIST(living_target))
		return
	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		living_target.visible_message("[src] passes right through [living_target]!")
		return
	. = ..()

//THE DRIP


/obj/item/clothing/head/hooded/cult_hoodie
	name = "ancient cultist hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/hooded_cult_hoodie
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT


/datum/armor/hooded_cult_hoodie
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "cultrobes"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/hooded_cultrobes
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT

/obj/item/clothing/suit/hooded/cultrobes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)


/datum/armor/hooded_cultrobes
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/head/hooded/cult_hoodie/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar'Sie."
	icon_state = "cult_hoodalt"
	inhand_icon_state = null

/obj/item/clothing/suit/hooded/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar'Sie."
	icon_state = "cultrobesalt"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/alt

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	icon_state = "magus"
	inhand_icon_state = null
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor_type = /datum/armor/wizard_magus
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH


/datum/armor/wizard_magus
	melee = 50
	bullet = 30
	laser = 50
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 50
	bleed = 50

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	icon = 'icons/obj/clothing/suits/wizard.dmi'
	worn_icon = 'icons/mob/clothing/suits/wizard.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/suit_magusred
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/datum/armor/suit_magusred
	melee = 50
	bullet = 30
	laser = 50
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 50
	bleed = 20

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cult_sharpener"
	used = 0
	increment = 5
	max = 30
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "A set of runed armour scribbed with blood rites which shimmer in the light, reflecting projectiles."
	icon_state = "cult_armor"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	armor_type = /datum/armor/cultrobes_cult_shield
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	/// if anyone can equip this. used by the prefs menu
	var/allow_any = FALSE


/datum/armor/cultrobes_cult_shield
	melee = 40
	bullet = 30
	laser = 40
	energy = 30
	bomb = 50
	bio = 30
	fire = 50
	acid = 60
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/anyone
	allow_any = TRUE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/Initialize(mapload)
	. = ..()
	// note that these charges don't regenerate
	AddComponent(/datum/component/shielded, \
		max_integrity = 100, \
		charge_recovery = 0 SECONDS, \
		shield_icon_file = 'icons/effects/cult_effects.dmi', \
		shield_icon = "shield-cult", \
		shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES, \
		shield_alpha = 120, \
		run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)) \
		)

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, current_integrity)
	wearer.visible_message(span_danger("[wearer]'s robes neutralize [attack_text] in a burst of blood-red sparks!"))
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(current_integrity == 0)
		wearer.visible_message(span_danger("The runed shield around [wearer] suddenly disappears!"))

/obj/item/clothing/head/hooded/cult_hoodie/cult_shield
	name = "empowered cultist helmet"
	desc = "A runed helmet scribbed with blood rites which shimmer in the light, reflecting projectiles."
	icon_state = "cult_hoodalt"
	armor_type = /datum/armor/cult_hoodie_cult_shield


/datum/armor/cult_hoodie_cult_shield
	melee = 40
	bullet = 30
	laser = 40
	energy = 30
	bomb = 50
	bio = 100
	fire = 50
	acid = 60
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user) && !allow_any)
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of reduced protection."
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/cultrobes_berserker
	slowdown = -0.4
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/berserkerhood


/datum/armor/cultrobes_berserker
	melee = 10
	bullet = 20
	laser = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/head/hooded/cult_hoodie/berserkerhood
	name = "flagellant's hood"
	desc = "Blood-soaked hood infused with dark magic."
	armor_type = /datum/armor/cult_hoodie_berserkerhood


/datum/armor/cult_hoodie_berserkerhood
	melee = 10
	bullet = 20
	laser = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "may Nar'Sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_FLASH
	vision_correction = 1

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"You want to be blind, do you?\""))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)
		user.adjust_blindness(30)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
	var/static/curselimit = 0

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(100)
		to_chat(user, span_warning("A powerful force shoves you away from [src]!"))
		return
	if(curselimit > 1)
		to_chat(user, span_notice("We have exhausted our ability to curse the shuttle."))
		return
	if(locate(/obj/eldritch/narsie) in GLOB.poi_list)
		to_chat(user, span_warning("Nar'Sie is already on this plane, there is no delaying the end of all things."))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 1800
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = SSsecurity_level.get_current_level_as_number()
		var/set_coefficient = 1
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergencyCallTime * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		to_chat(user, span_danger("You shatter the orb! A dark essence spirals into the air, then disappears."))
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, 1)
		qdel(src)
		sleep(20)
		var/static/list/curses
		if(!curses)
			curses = list("A fuel technician just slit his own throat and begged for death.",
			"The shuttle's navigation programming was replaced by a file containing just two words: IT COMES.",
			"The shuttle's custodian was found washing the windows with their own blood.",
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh.",
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine.",
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh.",
			"The shuttle's transponder is emitting the encoded message 'FEAR THE OLD BLOOD' in lieu of its assigned identification signal.")
		var/message = pick_n_take(curses)
		message += " The shuttle will be delayed by three minutes."
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), message, "Priority Alert", 'sound/misc/announce_syndi.ogg', null, "Nanotrasen Department of Transportation: Central Command"), rand(2 SECONDS, 6 SECONDS))
		curselimit++

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic instantly teleports you, and anything you're pulling, forward by a moderate distance."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += span_cult("It has [uses] use\s remaining.")
	else
		. += span_cult("It seems drained.")

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		do_teleport(pulled, T, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, span_warning("\The [src] is dull and unmoving in your hands."))
		return
	if(!IS_CULTIST(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, span_warning("\The [src] flickers out of your hands, your connection to this dimension is too strong!"))
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/destination = get_teleport_loc(mobloc,C,9,1,0,3,1,0,1)

	if(destination)
		uses--
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		if(do_teleport(C, destination, channel = TELEPORT_CHANNEL_CULT))
			if(pulled)
				C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull
			new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
			playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
			playsound(destination, "sparks", 50, 1)

	else
		to_chat(C, span_danger("The veil cannot be torn here!"))

/obj/item/flashlight/flare/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful brethren."
	w_class = WEIGHT_CLASS_SMALL
	light_range = 1
	icon_state = "torch"
	inhand_icon_state = "torch"
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	on = TRUE
	var/charges = 5

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!IS_CULTIST(user))
		to_chat(user, "That doesn't seem to do anything useful.")
		return

	if(istype(A, /obj/item))

		var/list/cultists = list()
		for(var/datum/mind/cult_mind in get_antag_minds(/datum/antagonist/cult))
			if(cult_mind.current?.stat != DEAD)
				cultists |= cult_mind.current
		var/mob/living/cultist_to_receive = input(user, "Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in (cultists - user)
		if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
			return
		if(!cultist_to_receive)
			to_chat(user, span_cultitalic("You require a destination!"))
			log_game("Void torch failed - no target")
			return
		if(cultist_to_receive.stat == DEAD)
			to_chat(user, span_cultitalic("[cultist_to_receive] has died!"))
			log_game("Void torch failed  - target died")
			return
		if(!IS_CULTIST(cultist_to_receive))
			to_chat(user, span_cultitalic("[cultist_to_receive] is not a follower of the Geometer!"))
			log_game("Void torch failed - target was deconverted")
			return
		if(A in user.GetAllContents())
			to_chat(user, span_cultitalic("[A] must be on a surface in order to teleport it!"))
			return
		to_chat(user, span_cultitalic("You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]!"))
		cultist_to_receive.put_in_hands(A)
		charges--
		to_chat(user, "\The [src] now has [charges] charge\s.")
		if(charges == 0)
			qdel(src)

	else
		..()
		to_chat(user, span_warning("\The [src] can only transport items!"))


/obj/item/cult_spear
	name = "blood halberd"
	desc = "A sickening spear composed entirely of crystallized blood."
	icon_state = "bloodspear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	slot_flags = 0
	force = 17
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30

	attack_verb_continuous = list("attacks", "impales", "stabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "impale", "stab", "tear", "lacerate", "gore")
	sharpness = SHARP
	bleed_force = BLEED_CUT
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/datum/action/innate/cult/spear/spear_act

/obj/item/cult_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 100, 90)
	AddComponent(/datum/component/two_handed, force_unwielded=17, force_wielded=24, icon_wielded="bloodspear1")

/obj/item/cult_spear/update_icon()
	icon_state = "bloodspear0"
	..()

/obj/item/cult_spear/Destroy()
	if(spear_act)
		qdel(spear_act)
	..()

/obj/item/cult_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(IS_CULTIST(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.can_block_magic(MAGIC_RESISTANCE_HOLY))
				L.Knockdown(50)
			break_spear(T)
	else
		..()

/obj/item/cult_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message(span_warning("[src] shatters and melts back into blood!"))
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/datum/action/innate/cult/spear
	name = "Bloody Bond"
	desc = "Call the blood spear back to your hand!"
	background_icon_state = "bg_demon"
	button_icon_state = "bloodspear"
	var/obj/item/cult_spear/spear
	var/cooldown = 0

/datum/action/innate/cult/spear/Grant(mob/user, obj/blood_spear)
	. = ..()
	spear = blood_spear

/datum/action/innate/cult/spear/on_activate()
	if(owner == spear.loc || cooldown > world.time)
		return
	var/ST = get_turf(spear)
	var/OT = get_turf(owner)
	if(get_dist(OT, ST) > 10)
		to_chat(owner,span_cult("The spear is too far away!"))
	else
		cooldown = world.time + 20
		if(isliving(spear.loc))
			var/mob/living/L = spear.loc
			L.dropItemToGround(spear)
			L.visible_message(span_warning("An unseen force pulls the blood spear from [L]'s hands!"))
		spear.throw_at(owner, 10, 2, owner)


/obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	weapon_weight = WEAPON_LIGHT
	equip_time = 0
	has_weapon_slowdown = FALSE

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/projectile/magic/arcane_barrage/blood
	firing_effect_type = /obj/effect/temp_visual/cult/sparks

/obj/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "mini_leaper"
	nondirectional_sprite = TRUE
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)

	if(isliving(target))
		var/mob/living/living_target = target
		if(IS_CULTIST(living_target))
			if(ishuman(living_target))
				var/mob/living/carbon/human/H = living_target
				if(H.stat != DEAD)
					H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
			if(isshade(living_target) || isconstruct(living_target))
				var/mob/living/simple_animal/M = living_target
				if(M.health+5 < M.maxHealth)
					M.adjustHealth(-5)
			new /obj/effect/temp_visual/cult/sparks(T)
			qdel(src)
		else
			..()

/obj/item/blood_beam
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/blood_beam/afterattack(atom/A, mob/living/user, flag, params)
	. = ..()
	if(firing || charging)
		return
	var/C = user.client
	if(ishuman(user) && C)
		angle = get_angle(get_turf(src), get_turf(A))
	else
		qdel(src)
		return
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user)
	if(do_after(user, 90, target = user))
		firing = TRUE
		INVOKE_ASYNC(src, PROC_REF(pewpew), user, params)
		var/obj/structure/emergency_shield/invoker/N = new(user.loc)
		if(do_after(user, 90, target = user))
			user.Paralyze(40)
			to_chat(user, span_cultitalic("You have exhausted the power of this spell!"))
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, 1)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(15)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, params)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(15)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in get_line(targets_from,temp_target))
			if (T.is_holy())
				temp_target = T
				playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 50, 1)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(IS_CULTIST(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/simple_animal/M = target
						if(M.health+15 < M.maxHealth)
							M.adjustHealth(-15)
						else
							M.health = M.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.Paralyze(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, 1)
						L.emote("scream")
		user.Beam(temp_target, icon_state="blood_beam", time = 7, beam_type = /obj/effect/ebeam/blood)


/obj/effect/ebeam/blood
	name = "blood beam"

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by Nar'Sien sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon_state = "mirror_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	max_integrity = 50
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bumps", "prods")
	attack_verb_simple = list("bump", "prod")
	hitsound = 'sound/weapons/smash.ogg'
	var/illusions = 4

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(IS_CULTIST(owner))
		if (attack_type == MELEE_ATTACK && ishuman(hitby.loc))
			// Cannot block someone who has the bible on their side
			var/mob/living/carbon/human/attacker = hitby.loc
			if (attacker.can_block_magic(MAGIC_RESISTANCE_HOLY))
				owner.visible_message(span_danger("[owner] fails to block the attack from [attacker]!"), span_userdanger("You fail to block the empowered attack!"))
				return FALSE
		. = ..()
		if(.)
			if(illusions > 0)
				illusions--
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list(FACTION_CULT)
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.cached_multiplicative_slowdown
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.cached_multiplicative_slowdown, E.minimum_distance)
			return TRUE
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list(FACTION_CULT)
			H.GiveTarget(owner)
			H.move_to_delay = owner.cached_multiplicative_slowdown
			to_chat(owner, span_danger("<b>[src] betrays you!</b>"))
		return FALSE

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(IS_CULTIST(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message(span_warning("[L] catches [src] out of the air!"))
			else
				L.visible_message(span_warning("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(!L.can_block_magic(MAGIC_RESISTANCE_HOLY))
				L.Knockdown(30)
				if(D?.thrower)
					for(var/mob/living/Next in orange(2, T))
						if(!Next.density || IS_CULTIST(Next))
							continue
						throw_at(Next, 3, 1, D.thrower)
						return
					throw_at(D.thrower, 7, 1, null)
	else
		..()
