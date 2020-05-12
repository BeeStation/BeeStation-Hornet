//Clockwork armor: High melee protection but weak to lasers
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACE
	armor = list("melee" = 60, "bullet" = 70, "laser" = -25, "energy" = 0, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == SLOT_HEAD)
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off [user.p_their()] head!</span>", "<span class='warning'>The helmet flickers off your head, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
		else
			to_chat(user, "<span class='heavy_brass'>\"Do you have a hole in your head? You're about to.\"</span>")
			to_chat(user, "<span class='userdanger'>The helmet tries to drive a spike through your head as you scramble to remove it!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
			user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1) //equipped happens before putting stuff on(but not before picking items up), 1). thus, we need to wait for it to be on before forcing it off.

/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS
	cold_protection = CHEST|GROIN|LEGS
	heat_protection = CHEST|GROIN|LEGS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 60, "bullet" = 70, "laser" = -25, "energy" = 0, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	allowed = list(/obj/item/clockwork)

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == SLOT_WEAR_SUIT)
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off [user.p_their()] body!</span>", "<span class='warning'>The cuirass flickers off your body, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
		else
			to_chat(user, "<span class='heavy_brass'>\"I think this armor is too hot for you to handle.\"</span>")
			to_chat(user, "<span class='userdanger'>The cuirass emits a burst of flame as you scramble to get it off!</span>")
			user.emote("scream")
			user.apply_damage(15, BURN, BODY_ZONE_CHEST)
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1)

/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, shock-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	item_color = null //So they don't wash.
	strip_delay = 50
	equip_delay_other = 30
	body_parts_covered = ARMS
	cold_protection = ARMS
	heat_protection = ARMS
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 80, "bullet" = 70, "laser" = -25, "energy" = 0, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)

/obj/item/clothing/gloves/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	return 0

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == SLOT_GLOVES)
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off [user.p_their()] arms!</span>", "<span class='warning'>The gauntlets flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
		else
			to_chat(user, "<span class='heavy_brass'>\"Did you like having arms?\"</span>")
			to_chat(user, "<span class='userdanger'>The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BRUTE, BODY_ZONE_L_ARM)
			user.apply_damage(7, BRUTE, BODY_ZONE_R_ARM)
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1)

/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	w_class = WEIGHT_CLASS_NORMAL
	strip_delay = 50
	equip_delay_other = 30
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/clockwork/negates_gravity()
	return TRUE

/obj/item/clothing/shoes/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	return 0

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == SLOT_SHOES)
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off [user.p_their()] feet!</span>", "<span class='warning'>The treads flicker off your feet, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
		else
			to_chat(user, "<span class='heavy_brass'>\"Let's see if you can dance with these.\"</span>")
			to_chat(user, "<span class='userdanger'>The treads turn searing hot as you scramble to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BURN, BODY_ZONE_L_LEG)
			user.apply_damage(7, BURN, BODY_ZONE_R_LEG)
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1)
