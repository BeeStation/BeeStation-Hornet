/obj/item/melee/energy
	icon = 'icons/obj/transforming_energy.dmi'
	max_integrity = 200
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30, STAMINA = 0, BLEED = 0)
	attack_verb_continuous = list("hits", "taps", "pokes")
	attack_verb_simple = list("hit", "tap", "poke")
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_on = FALSE
	//bare_wound_bonus = 20
	stealthy_audio = TRUE
	w_class = WEIGHT_CLASS_SMALL

	/// The color of this energy based sword, for use in editing the icon_state.
	var/sword_color_icon
	/// Whether our blade is active or not.
	var/blade_active = FALSE
	/// Force while active.
	var/active_force = 30
	/// Throwforce while active.
	var/active_throwforce = 20
	/// Force while active.
	var/active_bleedforce = NONE
	/// Sharpness while active.
	var/active_sharpness = IS_SHARP
	/// Hitsound played attacking while active.
	var/active_hitsound = 'sound/weapons/blade1.ogg'
	/// Weight class while active.
	var/active_w_class = WEIGHT_CLASS_BULKY
	/// The heat given off when active.
	var/active_heat = 3500

/obj/item/melee/energy/Initialize()
	. = ..()
	make_transformable()
	AddComponent(/datum/component/butchering, _speed = 5 SECONDS, _butcher_sound = active_hitsound)

/obj/item/melee/energy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/*
 * Gives our item the transforming component, passing in our various vars.
 */
/obj/item/melee/energy/proc/make_transformable()
	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		throw_speed_on = 4, \
		bleedforce_on = active_bleedforce, \
		sharpness_on = active_sharpness, \
		hitsound_on = active_hitsound, \
		w_class_on = active_w_class, \
		attack_verb_continuous_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts"), \
		attack_verb_simple_on = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut"))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/energy/suicide_act(mob/living/user)
	if(!blade_active)
		attack_self(user)
	user.visible_message("<span class='suicide'>[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/energy/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/energy/process(delta_time)
	if(heat)
		open_flame()

/obj/item/melee/energy/ignition_effect(atom/A, mob/user)
	if(!heat && !blade_active)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [C.p_their()] nose"
	. = "<span class='warning'>[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Updates our icon to have the correct color,
 * updates the amount of heat our item gives out,
 * enables / disables embedding, and
 * starts / stops processing.
 *
 * Also gives feedback to the user and activates or deactives the glow.
 */
/obj/item/melee/energy/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	blade_active = active
	if(active)
		if(sword_color_icon)
			icon_state = "[icon_state]_[sword_color_icon]"
		if(embedding)
			updateEmbedding()
		heat = active_heat
		START_PROCESSING(SSobj, src)
	else
		if(embedding)
			disableEmbedding()
		heat = initial(heat)
		STOP_PROCESSING(SSobj, src)

	balloon_alert(user, "[name] [active ? "enabled":"disabled"]")
	playsound(user ? user : src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 35, TRUE)
	set_light_on(active)
	return COMPONENT_NO_DEFAULT_MESSAGE

/// Energy axe - extremely strong.
/obj/item/melee/energy/axe
	name = "energy axe"
	desc = "An energized battle axe."
	icon_state = "axe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "chop", "cleave", "tear", "lacerate", "cut")
	force = 40
	throwforce = 25
	throw_speed = 3
	throw_range = 5
	armour_penetration = 100
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_NORMAL
	flags_1 = CONDUCT_1
	light_color = LIGHT_COLOR_LIGHT_CYAN

	active_force = 150
	active_throwforce = 30
	active_w_class = WEIGHT_CLASS_HUGE

/obj/item/melee/energy/axe/make_transformable()
	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		throw_speed_on = throw_speed, \
		sharpness_on = sharpness, \
		w_class_on = active_w_class)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/energy/axe/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS|FIRELOSS)

/// Energy swords.
/obj/item/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "e_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = "swing_hit"
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	armour_penetration = 35
	block_level = 1
	block_upgrade_walk = 1
	block_power = 35
	block_sound = 'sound/weapons/egloves.ogg'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	embedding = list("embed_chance" = 200, "armour_block" = 60, "max_pain_mult" = 15)

	active_throwforce = 35 // Does a lot of damage on throw, but will embed
	active_bleedforce = BLEED_DEEP_WOUND

/obj/item/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(blade_active)
		return ..()
	return FALSE

/obj/item/melee/energy/sword/esaw //Energy Saw on it's own
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 18
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = IS_SHARP
	light_color = LIGHT_COLOR_LIGHT_CYAN
	tool_behaviour = TOOL_SAW
	toolspeed = 0.7 // Faster than a normal saw.

	active_force = 30
	active_bleedforce = BLEED_DEEP_WOUND
	sword_color_icon = null // Stops icon from breaking when turned on.

/obj/item/melee/energy/sword/cyborg
	name = "cyborg energy sword"
	sword_color_icon = "red"
	/// The cell cost of hitting something.
	var/hitcost = 50

/obj/item/melee/energy/sword/cyborg/attack(mob/target, mob/living/silicon/robot/user)
	if(!user.cell)
		return

	var/obj/item/stock_parts/cell/our_cell = user.cell
	if(blade_active && !(our_cell.use(hitcost)))
		attack_self(user)
		balloon_alert(user, "Your [name] is out of charge.")
		return
	return ..()

/obj/item/melee/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "implant-esaw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 18
	hitcost = 75 // Costs more than a standard cyborg esword.
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = IS_SHARP
	light_color = LIGHT_COLOR_LIGHT_CYAN
	tool_behaviour = TOOL_SAW
	toolspeed = 0.7 // Faster than a normal saw.

	active_force = 30
	active_bleedforce = BLEED_DEEP_WOUND
	sword_color_icon = null // Stops icon from breaking when turned on.

/obj/item/melee/energy/sword/cyborg/saw/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return FALSE

/obj/item/melee/energy/sword/esaw/implant //Energy Saw Arm Implant
	icon_state = "implant-esaw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'


// The colored energy swords we all know and love.
/obj/item/melee/energy/sword/saber
	/// Assoc list of all possible saber colors to color define.
	var/list/possible_colors = list(
		"red" = COLOR_SOFT_RED,
		"blue" = LIGHT_COLOR_LIGHT_CYAN,
		"green" = LIGHT_COLOR_GREEN,
		"purple" = LIGHT_COLOR_LAVENDER,
		"yellow" = COLOR_YELLOW,
		)
	/// Whether this saber has beel multitooled.
	var/hacked = FALSE

/obj/item/melee/energy/sword/saber/Initialize(mapload)
	. = ..()
	if(!sword_color_icon && LAZYLEN(possible_colors))
		sword_color_icon = pick(possible_colors)

	if(sword_color_icon)
		set_light_color(possible_colors[sword_color_icon])

/obj/item/melee/energy/sword/saber/process()
	. = ..()
	if(hacked)
		set_light_color(possible_colors[pick(possible_colors)])

/obj/item/melee/energy/sword/saber/red
	sword_color_icon = "red"

/obj/item/melee/energy/sword/saber/blue
	sword_color_icon = "blue"

/obj/item/melee/energy/sword/saber/green
	sword_color_icon = "green"

/obj/item/melee/energy/sword/saber/purple
	sword_color_icon = "purple"

/obj/item/melee/energy/sword/saber/attackby(obj/item/weapon, mob/living/user, params)
	if(weapon.tool_behaviour == TOOL_MULTITOOL)
		if(hacked)
			balloon_alert(user, "It's already fabulous!")
		else
			hacked = TRUE
			sword_color_icon = "rainbow"
			balloon_alert(user, "RNBW_ENGAGE")
			if(force >= active_force)
				icon_state = "[initial(icon_state)]_on_rainbow"
				user.update_inv_hands()
	else
		return ..()

/obj/item/melee/energy/sword/bee  //yeah its fucking stupid but I wanted a yellow esword which is weaker than what we have
	name = "Bee Sword"
	desc = "Channel the might of the bees with this powerful sword"
	force = 0
	throwforce = 0
	sword_color_icon = "yellow"

	active_force = 22
	active_throwforce = 16

/obj/item/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "e_cutlass"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	light_color = COLOR_RED

/// Energy blades, which are effectively perma-extended energy swords
/obj/item/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/blade1.ogg'
	throw_speed = 3
	throw_range = 1
	sharpness = IS_SHARP
	bleed_force = BLEED_DEEP_WOUND //it doesnt transform, bacon. Why would it be bleedforce_on?
	heat = 3500
	w_class = WEIGHT_CLASS_BULKY
	blade_active = TRUE
	/// Our linked spark system that emits from our sword.
	var/datum/effect_system/spark_spread/spark_system

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/melee/energy/blade/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	START_PROCESSING(SSobj, src)

/obj/item/melee/energy/blade/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/melee/energy/blade/make_transformable()
	return FALSE

/obj/item/melee/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	item_state = "lightblade"
