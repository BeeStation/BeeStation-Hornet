/obj/item/projectile/bullet/SRN_rocket
	name = "SRN rocket"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	hitsound = "sound/effects/meteorimpact.ogg"
	damage = 10
	ricochets_max = 0 //it's a MISSILE

/obj/item/projectile/bullet/SRN_rocket/on_hit(atom/target, mob/living/carbon/human/M)
	..()
	if(ishuman(target))
		playsound(src.loc, "pierce", 100, 1)
		M.oxyloss = 5
		M.hallucination = 15
		to_chat(M, "<span class='alert'>You are struck by a spatial nullifier! Thankfully it didn't affect you... much.</span>")
		M.emote("scream")
	else
		playsound(src.loc, "sparks", 100, 1)
	return BULLET_ACT_HIT
