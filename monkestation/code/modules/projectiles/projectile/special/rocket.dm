/obj/item/projectile/bullet/SRN_rocket
	name = "SRN rocket"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	hitsound = "sound/effects/meteorimpact.ogg"
	damage = 10
	ricochets_max = 0 //it's a MISSILE

/obj/item/projectile/bullet/SRN_rocket/on_hit(atom/target, blocked = FALSE)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		playsound(src.loc, "pierce", 100, 1)
		M.oxyloss = 5
		M.hallucination = 15
		to_chat(M, "<span class='alert'>You are struck by a spatial nullifier! Thankfully it didn't affect you... much.</span>")
		M.emote("scream")
	else
		playsound(src.loc, "sparks", 100, 1)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/SRN_rocket/Impact(atom/A)
	. = ..()
	if(istype(A, /obj/singularity))
		var/mob/living/user = firer
		user.client.give_award(/datum/award/achievement/misc/singularity_buster, user)
		user.emote("scream")

		for(var/mob/player as anything in GLOB.player_list)
			SEND_SOUND(player, 'sound/magic/charge.ogg')
			to_chat(player, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
			shake_camera(player, 15, 3)

		new/obj/singularity/spatial_rift(A.loc)
		qdel(A)

	return
