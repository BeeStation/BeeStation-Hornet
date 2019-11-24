// Chaplains begone!
/obj/item/nullrod/scythe/vibro
	name = "high fronquency bladd"

/obj/item/melee/hfblade
	name = "high frequency blade"
	desc = "RULES OF NATURE"
	icon_state = "hfblade"
	item_state = "hfblade"
	icon = 'icons/obj/hfblade.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 0
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = IS_SHARP
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 10000)
	light_color = "#40ceff"
	var/rules_of_nature = TRUE // Turn this off to break the rules, and watch the horrors of no proximity flags unfold.
	var/brazil = FALSE
	var/brightness = 5

/obj/item/melee/hfblade/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 95, 5)
	set_light(brightness)
	START_PROCESSING(SSobj, src)

/obj/item/melee/hfblade/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/hfblade/hit_reaction(mob/living/carbon/human/owner, mob/living/carbon/human/attacker, datum/martial_art/attacker_style, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	if(attack_type == MELEE_ATTACK) // It really is not a good idea to get close to this thing.
		final_block_chance = 50
		var/hideandseeklogic = rand(1,5) // YES, ADD MORE RNG TO COMBAT.
		if(hideandseeklogic == 1 || HAS_TRAIT(attacker, TRAIT_CLUMSY))
			attacker.visible_message("<span class = 'warning'>[attacker] attempts to attack [owner] and accidentally slices their arm off! What an idiot!</span>")
			var/which_hand = (attacker.active_hand_index % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
			var/obj/item/bodypart/disarm_arm = attacker.get_bodypart(which_hand)
			disarm_arm.dismember()
			playsound(attacker,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
	return ..()

/obj/item/melee/hfblade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag && rules_of_nature)
		return
	var/list/parts = list()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/BP = X
			if(BP.body_part != HEAD && BP.body_part != CHEST)
				if(BP.dismemberable)
					parts += BP
	if(parts)
		if(!parts.len)
			return FALSE
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/BP = pick(parts)
		BP.dismember()
		playsound(C,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		C.adjustBruteLoss(-15) //dismembering a limb deals 15 brute, this heals you instantly after that
		user.changeNext_move(CLICK_CD_CLICK_ABILITY)
		return ..()
	. = ..()

/obj/item/melee/hfblade/on_exit_storage()
	..()
	playsound(src, 'sound/items/unsheath.ogg', 25, 1)

/obj/item/melee/hfblade/on_enter_storage()
	..()
	playsound(src, 'sound/items/sheath.ogg', 25, 1)


/obj/item/melee/hfblade/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/multitool))
		if(!brazil)
			to_chat(user, "<span class = 'notice'>You enable the buttrock speakers on the sword. Its new red color faintly reminds you of brazil, for some reason.")
			desc = "Said to have been passed down from several british weeaboos, and one of them outfitted the sword with speakers to play music.\
			<br><span class = 'comradio'>come to brazil</span>"
			icon_state = "hfblade-red"
			item_state = "hfblade-red"
			brightness = 7
			light_color = "red"
			brazil = TRUE
			user.update_inv_hands()
			playsound(user, 'sound/vehicles/clowncar_fart.ogg', 50, 1)
		else
			to_chat(user, "<span class = 'notice'>Don't get edgier than this, son.</span>")

/obj/item/storage/belt/hfblade
	name = "edgelord's sheath"
	desc = "A strange sheath designed to hold an electric blade of some sort. One could only imagine how edgy this guy's musical preference is."
	icon = 'icons/obj/hfblade.dmi'
	alternate_worn_icon = 'icons/mob/hfblade.dmi'
	icon_state = "sheath"
	item_state = "sheath"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/hfblade/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/melee/hfblade
		))

/obj/item/storage/belt/hfblade/examine(mob/user)
	..()
	if(length(contents))
		to_chat(user, "<span class='notice'>Alt-click it to quickly draw the blade.</span>")

/obj/item/storage/belt/hfblade/AltClick(mob/user)
	if(!iscarbon(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", "<span class='notice'>You take [I] out of [src].</span>")
		user.put_in_hands(I)
		update_icon()
	else
		to_chat(user, "[src] is empty.")

/obj/item/storage/belt/hfblade/update_icon()
	icon_state = "sheath"
	item_state = "sheath"
	if(contents.len)
		icon_state += "-sabre"
		item_state += "-sabre"
	if(loc && isliving(loc))
		var/mob/living/L = loc
		L.regenerate_icons()
	..()

/obj/item/storage/belt/hfblade/PopulateContents()
	new /obj/item/melee/hfblade(src)
	update_icon()
