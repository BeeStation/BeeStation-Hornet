/obj/structure/scp151
	name = "Strange Painting"
	icon = 'Oasis/SCP_MAIN/icons/scpobj/SCP151.dmi'
	desc = "<b><span class='warning'><big>SCP-151</big></span></b> - A painting depicting a rising wave."
	icon_state = ""
	anchored = TRUE
	density = TRUE
	var/last_regen = 0
	var/gen_time = 300 //how long we wait between hurting victims
	var/list/victims = list()

/obj/structure/scp151/examine(mob/user)
	. = ..()


/obj/structure/scp151/proc/hurt_victims() //simulate drowning
	for(var/mob/living/user in victims)
		var/turf/open/T = user.loc
		if(user.health <= 0)
			victims -= user

		else if(user.health <= 60)
			user.adjustOxyLoss(30)
			to_chat(user, "<span class='warning'>Your lungs begin to feel tight, and the briny taste of seawater permeates your mouth.</span>")
			user.visible_message("<span class = \"danger\"><em>[user] vomits up some sea water!</em></span>")
			T.atmos_spawn_air("water_vapor=30")
			for(var/mob/living/carbon/Carb in victims)
				Carb.vomit(30, blood = TRUE, distance = 2, message = FALSE)
		else
			user.adjustOxyLoss(30)
			to_chat(user, "<span class='warning'>Your lungs begin to feel tight, and the briny taste of seawater permeates your mouth.</span>")
			user.emote(pick("cough","gag","gasp"))
			if (prob(20))
				user.visible_message("<span class = \"danger\"><em>[user] vomits up some sea water!</em></span>")
				T.atmos_spawn_air("water_vapor=15")
				for(var/mob/living/carbon/Carb in victims)
					Carb.vomit(30, blood = TRUE, distance = 2, message = FALSE)


/obj/structure/scp151/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time

/obj/structure/scp151/process()
	if(world.time > last_regen + gen_time) //hurt victims after time
		hurt_victims()
		last_regen = world.time

/obj/structure/scp151/examine(mob/living/user)
	. = ..()
	if(!(user in victims) && istype(user))
		victims += user //on examine, adds user into victims list
	if (user in victims)
		spawn(2 SECONDS)
			to_chat(user, "<span class='warning'>Your lungs begin to feel tight, and the briny taste of seawater permeates your mouth.</span>")
		spawn(2 SECONDS)
			user.emote(pick("cough","gag","gasp"))
