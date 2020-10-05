//Ratvarian spear: A relatively fragile spear from the Celestial Derelict. Deals extreme damage to silicons and enemy cultists, but doesn't last long when summoned.
/obj/item/clockwork/weapon/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	icon = 'icons/obj/clockwork_objects.dmi'
	block_upgrade_walk = 1
	block_level = 1
	force = 15 //Extra damage is dealt to targets in attack()
	throwforce = 25
	armour_penetration = 10
	sharpness = IS_SHARP_ACCURATE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	var/bonus_burn = 5

/obj/item/clockwork/weapon/ratvarian_spear/attack(mob/living/target, mob/living/carbon/human/user)
	. = ..()
	if(!QDELETED(target) && target.stat != DEAD && !target.anti_magic_check(major = FALSE)) //we do bonus damage on attacks unless they're a servant, have a null rod, or are dead!!!
		var/bonus_damage = bonus_burn //normally a total of 20 damage, 30 with ratvar
		if(issilicon(target))
			target.visible_message("<span class='warning'>[target] shudders violently at [src]'s touch!</span>", "<span class='userdanger'>ERROR: Temperature rising!</span>")
			bonus_damage *= 5 //total 40 damage on borgs, 70 with ratvar
		else if(iscultist(target) || isconstruct(target))
			to_chat(target, "<span class='userdanger'>Your body flares with agony at [src]'s presence!</span>")
			bonus_damage *= 3 //total 30 damage on cultists, 50 with ratvar

/obj/item/clockwork/weapon/ratvarian_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(!..())
			if(!L.anti_magic_check())
				if(issilicon(L) || iscultist(L))
					L.Paralyze(100)
				else
					L.Paralyze(40)
			break_spear(T)
	else
		..()

/obj/item/clockwork/weapon/ratvarian_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T) //make sure we're not in null or something
			T.visible_message("<span class='warning'>[src] [pick("cracks in two and fades away", "snaps in two and dematerializes")]!</span>")
			new /obj/effect/temp_visual/ratvar/spearbreak(T)
			qdel(src)
