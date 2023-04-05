/obj/item/pitchfork
	icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	block_level = 1
	block_upgrade_walk = 1
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	max_integrity = 200
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30, STAMINA = 0)
	resistance_flags = FIRE_PROOF

/obj/item/pitchfork/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=7, force_wielded=15, block_power_wielded=25, icon_wielded="pitchfork1")

/obj/item/pitchfork/update_icon()
	icon_state = "pitchfork0"
	..()

/obj/item/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24

/obj/item/pitchfork/demonic/Initialize(mapload)
	. = ..()
	set_light(3,6,LIGHT_COLOR_RED)

/obj/item/pitchfork/demonic/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=19, force_wielded=25, block_power_wielded=25)

/obj/item/pitchfork/demonic/greater
	force = 24
	throwforce = 50

/obj/item/pitchfork/demonic/greater/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=24, force_wielded=34, block_power_wielded=25)

/obj/item/pitchfork/demonic/ascended
	force = 100
	throwforce = 100

/obj/item/pitchfork/demonic/ascended/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=100, force_wielded=500000) // Kills you DEAD

/obj/item/pitchfork/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] impales [user.p_them()]self in [user.p_their()] abdomen with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/pitchfork/demonic/pickup(mob/living/user)
	..()
	if(isliving(user) && user.mind && user.owns_soul() && !is_devil(user))
		var/mob/living/U = user
		U.visible_message("<span class='warning'>As [U] picks [src] up, [U]'s arms briefly catch fire.</span>", \
			"<span class='warning'>\"As you pick up [src] your arms ignite, reminding you of all your past sins.\"</span>")
		if(ishuman(U))
			var/mob/living/carbon/human/H = U
			H.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			U.adjustFireLoss(rand(force/2,force))

/obj/item/pitchfork/demonic/attack(mob/target, mob/living/carbon/human/user)
	if(user.mind && user.owns_soul() && !is_devil(user))
		to_chat(user, "<span class='warning'>[src] burns in your hands.</span>")
		user.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	..()

/obj/item/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !ISWIELDED(src))
		return
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		user.visible_message("<span class='danger'>[user] blasts \the [target] with \the [src]!</span>")
		playsound(target, 'sound/magic/disintegrate.ogg', 100, TRUE)
		W.break_wall()
		W.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return
