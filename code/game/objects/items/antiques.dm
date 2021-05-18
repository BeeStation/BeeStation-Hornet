#define GOT_ATHEIST 0
#define GOD_YOUTH 1
#define GOD_SIGHT 2
#define GOD_MIND 3
#define GOD_CLEANSE 4
#define GOD_MEND 5
#define GOD_CAUTERIZE 6
#define GOD_BLIND 7
#define GOD_MUTE 8
#define GOD_STUPID 9
#define GOD_HURT 10
#define GOD_BURN 11
#define GOD_PARALIZE 12
#define GOD_DISABLE 13
#define GOD_EMP 14
#define GOD_MADNESS 15
#define GODS_MAX 15

/obj/item/antique
	name = "antique"
	desc = "An antique item of some sort..."
	icon = 'icons/obj/wizard.dmi'	//placeholder
	icon_state = "lovestone"
	var/inUse = FALSE
	var/deity = -1
	var/last_use = 0
	var/godname = "C'Thulhu"
	var/activated = FALSE

/obj/item/antique/first	
	name = "antique broche"
	desc = "It looks pretty!"

/obj/item/antique/cursed/Initialize()
	..()
	deity = rand(1,GODS_MAX)
	switch (deity)
		if (GOD_YOUTH)
			godname = "Lobon"
		if (GOD_SIGHT)
			godname = "Nath-Horthath"
		if (GOD_MIND)
			godname = "Oukranos"
		if (GOD_CLEANSE)
			godname = "Tamash"
		if (GOD_MEND)
			godname = "Karakal"
		if (GOD_CAUTERIZE)
			godname = "D’endrrah"
		if (GOD_BLIND)
			godname = "Azathoth"
		if (GOD_MUTE)
			godname = "Abhoth"
		if (GOD_STUPID)
			godname = "Aiueb Gnshal"
		if (GOD_HURT)
			godname = "Ialdagorth"
		if (GOD_BURN)
			godname = "Tulzscha"
		if (GOD_PARALIZE)
			godname = "C'thalpa"
		if (GOD_DISABLE)
			godname = "Mh'ithrha"
		if (GOD_EMP)
			godname = "Shabbith-Ka"
		if (GOD_MADNESS)
			godname = "Yomagn'tho"

/obj/item/artifact/examine(mob/user)
	. = ..()
	if (!ashes)
		var/mob/living/carbon/C = user		
		if((C.job in list("Curator")) || IS_HERETIC(C))
			if (deity <= 6)
				. += "You identify it as an avatar of [godname], one of the earth's weak gods."	//the weak gods of earth watch out for their creations, so they offer beneficial boons
			else
				. += "You identify it as an avatar of [godname], one of the forbidden gods."				//forbidden gods on the other side...
		if (IS_HERETIC(C))
			if (!activated)
				. += "Use in hand to perform a ritual for [godname], granting this [src] magical powers."
			else
				var/boon = "The [name] will offer the boon of [godname], "
				switch (deity)
					if (GOD_YOUTH)
						boon += "fixing one's organs."
					if (GOD_SIGHT)
						boon += "bringing back one's vision."
					if (GOD_MIND)
						boon += "restoring one's sanity and mind."
					if (GOD_CLEANSE)
						boon += "purging one's body of inpurities."
					if (GOD_MEND)
						boon += "healing one's burned flesh."
					if (GOD_CAUTERIZE)
						boon += "bringing back one's vision."
					if (GOD_BLIND)
						boon += "making one blind."
					if (GOD_MUTE)
						boon += "halting one's speech."
					if (GOD_STUPID)
						boon += "making one stupid."
					if (GOD_HURT)
						boon += "inflicting wounds."
					if (GOD_BURN)
						boon += "causing one's skin to burn."
					if (GOD_PARALIZE)
						boon += "crippling one's legs."
					if (GOD_DISABLE)
						boon += "crippling one's hands."
					if (GOD_EMP)
						boon += "crippling one's hands."
					if (GOD_MADNESS)
						boon += "bringing madness into one's mind."
				. += boon

			var/datum/antagonist/heretic/her = user.mind.has_antag_datum(/datum/antagonist/heretic)
			if (!ashes && !her.has_deity(deity))
				. += "Performing a ritual for [godname] will also grant you favor."

/obj/item/artifact/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(world.time > last_use && proximity_flag)
		if (HAS_TRAIT(target,TRAIT_WARDED))
			user.visible_message("<span class='notice'>You hex [target] with the blessing of [godname]!</span>","<span class='danger'>[user] performs a strange ritual with the [src]!</span>")
			to_chat(user,"<span class='warning'>[target] is warded against your cruse!</span>")
			to_chat(target,"<span class='warning'>Your crucifix protects you against [user]'s curse!</span>")
		else if (infuse_blessing(user,target))
			user.visible_message("<span class='notice'>You hex [target] with the blessing of [godname]!</span>","<span class='danger'>[user] performs a strange ritual with the [src]!</span>")
		last_use = world.time + 10 SECONDS

/obj/item/artifact/attack_self(mob/user)
	. = ..()
	if (!inUse)
		inUse = TRUE
		if (!activated && IS_HERETIC(user))
			var/datum/antagonist/heretic/her = user.mind.has_antag_datum(/datum/antagonist/heretic)
			to_chat(user,"<span class='notice'>You start a praying towards [godname]!</span>")
			if (do_after(user,5 SECONDS))
				var/result = "The prayer is complete"
				if (!activated)
					result += ". You activated the [src] with the blessing of [godname]"
				if (!her.has_deity(deity))
					result += " and you gained the favor of [godname]"
					her.gain_favor(1)
				to_chat(user,"<span class='notice'>[result].</span>")
				activated = TRUE
				her.gain_deity(deity)
				return TRUE
		else if (infuse_blessing(user,user))
			user.visible_message("<span class='notice'>You strike yourself with the blessing of [godname]!</span>","<span class='danger'>[user] performs a strange ritual with the [src]!</span>")
		inUse = FALSE
	if (ashes)
		qdel(src)

/obj/item/artifact/proc/infuse_blessing(mob/living/user,mob/living/carbon/human/target)
	if (!activated)
		return FALSE
	switch (deity)
		if (GOD_YOUTH)
			target.adjustOrganLoss(ORGAN_SLOT_HEART,-5)
			target.adjustOrganLoss(ORGAN_SLOT_LIVER,-5)
			target.adjustOrganLoss(ORGAN_SLOT_STOMACH,-5)
			target.adjustOrganLoss(ORGAN_SLOT_LUNGS,-5)
			to_chat(target,"<span class='notice'>You feel younger!</span>")
		if (GOD_SIGHT)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,-10)
			to_chat(target,"<span class='notice'>Your vision feels sharper!</span>")
		if (GOD_MIND)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,-10)
			to_chat(target,"<span class='notice'>You can think more clearly!</span>")
		if (GOD_CLEANSE)
			target.adjustToxLoss(-10)
			to_chat(target,"<span class='notice'>You feel refreshed!</span>")
		if (GOD_MEND)
			target.adjustFireLoss(-10)
			to_chat(target,"<span class='notice'>Your skin tickles!</span>")
		if (GOD_CAUTERIZE)
			target.adjustBruteLoss(-10)
			to_chat(target,"<span class='notice'>Your bruises heal!</span>")
		if (GOD_BLIND)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,10)
			to_chat(target,"<span class='warning'>Your eyes sting!</span>")
		if (GOD_MUTE)
			target.adjustOrganLoss(ORGAN_SLOT_TONGUE,8)
			target.silent += 3 SECONDS
		if (GOD_STUPID)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,8)
			to_chat(target,"<span class='warning'>Your feel confused!</span>")
		if (GOD_HURT)
			target.adjustBruteLoss(5)
			to_chat(target,"<span class='warning'>Your flesh hurts!</span>")
		if (GOD_BURN)
			target.adjustFireLoss(5)
			to_chat(target,"<span class='warning'>Your skin burns!</span>")
		if (GOD_PARALIZE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == LEG_RIGHT || organ.body_part == LEG_LEFT)
					organ.receive_damage(stamina = 5)
			to_chat(target,"<span class='warning'>Your legs tingle!</span>")
		if (GOD_DISABLE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == ARM_RIGHT || organ.body_part == ARM_LEFT)
					organ.receive_damage(stamina = 5)
			to_chat(target,"<span class='warning'>Your arms tingle!</span>")
		if (GOD_EMP)
			target.emp_act(EMP_LIGHT)
			to_chat(target,"<span class='warning'>That was weird!</span>")
		if (GOD_MADNESS)
			if(HAS_TRAIT(target, TRAIT_PACIFISM))
				REMOVE_TRAIT(target, TRAIT_PACIFISM,TRAIT_GENERIC)	//remove any and all?
			to_chat(target,"<span class='warning'>Your feel that evil overcomes you!</span>")
	return TRUE

/obj/item/artifact/ashes/infuse_blessing(mob/living/user,mob/living/carbon/human/target)
	switch (deity)
		if (GOD_YOUTH)
			target.adjustOrganLoss(ORGAN_SLOT_HEART,-100)
			target.adjustOrganLoss(ORGAN_SLOT_LIVER,-100)
			target.adjustOrganLoss(ORGAN_SLOT_STOMACH,-100)
			target.adjustOrganLoss(ORGAN_SLOT_LUNGS,-100)
		if (GOD_SIGHT)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,-80)
		if (GOD_MIND)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,-50)
			target.SetSleeping(0)
		if (GOD_CLEANSE)
			target.adjustToxLoss(-50)
		if (GOD_MEND)
			target.adjustFireLoss(-50)
		if (GOD_CAUTERIZE)
			target.adjustBruteLoss(-50)
		if (GOD_BLIND)
			target.adjustOrganLoss(ORGAN_SLOT_EYES,40)
		if (GOD_MUTE)
			target.adjustOrganLoss(ORGAN_SLOT_TONGUE,50)
			target.silent += 10 SECONDS
		if (GOD_STUPID)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN,15)
			target.SetSleeping(10 SECONDS)
		if (GOD_HURT)
			target.adjustBruteLoss(20)
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			if(!target.anchored)
				target.throw_at(throw_target, rand(4,8), 14, user)
		if (GOD_BURN)
			target.adjustFireLoss(20)
			target.IgniteMob()
		if (GOD_PARALIZE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == LEG_RIGHT || organ.body_part == LEG_LEFT)
					organ.receive_damage(stamina = 200)
		if (GOD_DISABLE)
			for(var/obj/item/bodypart/organ in target.bodyparts)
				if(organ.body_part == ARM_RIGHT || organ.body_part == ARM_LEFT)
					organ.receive_damage(stamina = 200)
		if (GOD_EMP)
			target.electrocute_act(12, safety=TRUE, stun = FALSE)
			target.emp_act(EMP_HEAVY)	//was gonna make it emag, but I figured this is just as good
		if (GOD_MADNESS)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			if (master)
				master.enslave(target)

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, target)
	smoke.start()

	return TRUE

#undef GOT_ATHEIST
#undef GOD_YOUTH
#undef GOD_SIGHT
#undef GOD_MIND
#undef GOD_CLEANSE
#undef GOD_MEND
#undef GOD_CAUTERIZE
#undef GOD_BLIND
#undef GOD_MUTE
#undef GOD_STUPID
#undef GOD_HURT
#undef GOD_BURN
#undef GOD_PARALIZE
#undef GOD_DISABLE
#undef GOD_EMP
#undef GOD_MADNESS
#undef GODS_MAX