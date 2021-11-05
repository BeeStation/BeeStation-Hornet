/datum/guardian_ability/major/special/onewayroad // a cookie for you if you get the reference
	name = "Absolution"
	desc = "The guardian forms an absolute shield around it's user, protecting them from all harm."
	ui_icon = "shield-alt"
	cost = 5

/datum/guardian_ability/major/special/onewayroad/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/guardian_ability/major/special/onewayroad/Destroy()
	..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/guardian_ability/major/special/onewayroad/Manifest()
	update_status()

/datum/guardian_ability/major/special/onewayroad/Recall()
	update_status()

/datum/guardian_ability/major/special/onewayroad/Berserk()
	if(!HAS_TRAIT(guardian, TRAIT_ONEWAYROAD))
		ADD_TRAIT(guardian, TRAIT_ONEWAYROAD, GUARDIAN_TRAIT)

/datum/guardian_ability/major/special/onewayroad/process()
	if(!guardian?.summoner?.current)
		return
	update_status()
	if(isopenturf(guardian.summoner.current.loc))
		var/turf/open/T = guardian.summoner.current.loc
		T.air?.parse_gas_string("o2=22;n2=82;TEMP=293.15")
		for(var/obj/effect/particle_effect/smoke/S in T)
			S.visible_message("<span class='danger'>\The [S] is dispersed into a million tiny particles!</span>")
			qdel(S)
		for(var/obj/effect/particle_effect/foam/F in T)
			F.visible_message("<span class='danger'>\The [F] is dispersed into a million tiny particles!</span>")
			qdel(F)

/datum/guardian_ability/major/special/onewayroad/proc/update_status()
	if(!guardian?.summoner?.current)
		return
	if(!guardian.is_deployed())
		if(HAS_TRAIT(guardian.summoner.current, TRAIT_ONEWAYROAD))
			REMOVE_TRAIT(guardian.summoner.current, TRAIT_ONEWAYROAD, GUARDIAN_TRAIT)
		if(HAS_TRAIT(guardian.summoner.current, TRAIT_NOBREATH))
			REMOVE_TRAIT(guardian.summoner.current, TRAIT_NOBREATH, GUARDIAN_TRAIT)
	else
		ADD_TRAIT(guardian.summoner.current, TRAIT_ONEWAYROAD, GUARDIAN_TRAIT)
		ADD_TRAIT(guardian.summoner.current, TRAIT_NOBREATH, GUARDIAN_TRAIT) // this kinda simulates the "Absolution filters out harmful gases around the user" thing better than constantly parsing gas strings

// STUFF

/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		var/atom/movable/oldfirer = P.firer
		P.firer = src
		P.original = oldfirer
		P.setAngle(Get_Angle(src, oldfirer))
		visible_message("<span class='danger'>The air around [src] diverts \the [P] back towards [oldfirer]!</span>")
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return M.attack_animal(M)
	return ..()

/mob/living/simple_animal/hostile/guardian/attack_animal(mob/living/simple_animal/M)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return M.attack_animal(M)
	return ..()

/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return user.attack_hulk(user)
	return ..()

/mob/living/simple_animal/hostile/guardian/attack_hulk(mob/living/carbon/human/user)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return user.attack_hulk(user)
	return ..()

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return M.attack_alien(M)
	return ..()

/mob/living/simple_animal/hostile/guardian/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return M.attack_alien(M)
	return ..()

/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return M.attack_paw(M)
	return ..()

/mob/living/simple_animal/hostile/guardian/attack_paw(mob/living/carbon/monkey/M)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return M.attack_paw(M)
	return ..()

/mob/living/simple_animal/hostile/guardian/bullet_act(obj/item/projectile/P)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		var/atom/movable/oldfirer = P.firer
		P.firer = src
		P.original = oldfirer
		P.setAngle(Get_Angle(src, oldfirer))
		visible_message("<span class='danger'>The air around [src] diverts \the [P] back towards [oldfirer]!</span>")
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target, origin)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		visible_message("<span class='danger'>The air around [src] diverts the explosion!</span>")
		return
	return ..()

/mob/living/carbon/human/ex_act(severity, target, origin)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		visible_message("<span class='danger'>The air around [src] diverts the explosion!</span>")
		return
	return ..()

/mob/living/carbon/human/contents_explosion(severity, target)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		return
	return ..()

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		visible_message("<span class='danger'>The air around [src] diverts \the [AM] back towards [throwingdatum.thrower]!</span>")
		AM.throw_at(throwingdatum.thrower, throwingdatum.maxrange * 2, throwingdatum.speed * 2, src, TRUE)
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(HAS_TRAIT(src, TRAIT_ONEWAYROAD))
		visible_message("<span class='danger'>The air around [src] diverts \the [AM] back towards [throwingdatum.thrower]!</span>")
		AM.throw_at(throwingdatum.thrower, throwingdatum.maxrange * 2, throwingdatum.speed * 2, src, TRUE)
		return
	return ..()

/datum/martial_art/basic_hit(mob/living/carbon/human/A,mob/living/carbon/human/D)
	if(HAS_TRAIT(D, TRAIT_ONEWAYROAD))
		D = A
	return ..(A, D)
