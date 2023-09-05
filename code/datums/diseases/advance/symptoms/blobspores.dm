/datum/symptom/blobspores
	name = "Blob Spores"
	desc = "This symptom causes the host to produce blob spores, which will leave the host at the later stages, and if the host dies, all of the spores will erupt from the host at the same time, while also producing a blob tile."
	stealth = 1
	resistance = 6
	stage_speed = -2
	transmission = 1
	level = 9
	severity = 3
	prefixes = list("Xeno", "Sporing ")
	bodies = list("Blob")
	var/ready_to_pop
	var/factory_blob
	var/strong_blob
	var/node_blob
	threshold_desc = "<b>Resistance 11:</b> There is a chance to spawn a factory blob, instead of a normal blob.<br> \
					  <b>Resistance 8:</b> Spawns a strong blob instead of a normal blob \
					  <b>Resistance 14:</b> Has a chance to spawn a blob node instead of a normal blob<br>"

/datum/symptom/blobspores/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 14)
		severity += 1


/datum/symptom/blobspores/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 11)
		factory_blob = TRUE
	if(A.resistance >= 8)
		strong_blob = TRUE
		if(A.resistance >= 14)
			node_blob = TRUE

/datum/symptom/blobspores/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(2))
				to_chat(M, "<span class='notice'>You feel bloated.</span>")

			if(prob(3) && !M.jitteriness) //We dont want to stack this with other effects.
				to_chat(M, "<span class='notice'>You feel a bit jittery.</span>")
				M.Jitter(10)
		if(2)
			if(prob(1) && iscarbon(M))
				var/mob/living/carbon/C = M
				C.vomit(5, TRUE, FALSE)
		if(3, 4)
			if(prob(10))
				to_chat(M, "<span class='notice'>You feel blobby?</span>")
				M.reagents.add_reagent(pick(subtypesof(/datum/reagent/blob/)), 5) //Completely harmless due to how blob chemicals work, still gives some good flavour
		if(5)
			ready_to_pop = TRUE
			if(prob(5))
				M.visible_message("<span class='warning'>[M] coughs blood!</span>")
				M.add_splatter_floor(M.loc)
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					C.bleed(rand(1, 10))


/datum/symptom/blobspores/OnDeath(datum/disease/advance/A)
	if(neutered) //Stops this symptom from making people scared even if this is useless
		return FALSE
	var/mob/living/M = A.affected_mob
	M.visible_message("<span class='danger'>[M] starts swelling grotesquely!</span>")
	addtimer(CALLBACK(src, PROC_REF(blob_the_mob), A, M), 10 SECONDS)

/datum/symptom/blobspores/proc/blob_the_mob(datum/disease/advance/A, mob/living/M)
	if(!A || !M)
		return
	var/list/blob_options = list(/obj/structure/blob/normal)
	if(factory_blob)
		blob_options += /obj/structure/blob/factory/lone
	if(strong_blob)
		blob_options += /obj/structure/blob/shield/
	if(node_blob)
		blob_options += /obj/structure/blob/node/lone
	var/pick_blob = pick(blob_options)
	if(ready_to_pop)
		for(var/i in 1 to rand(1, 6))
			var/mob/living/simple_animal/hostile/blob/blobspore/spore = new(M.loc)//Spores update their health on update_icon, we cant change their colour
			spore.spore_diseases.Cut()
			spore.spore_diseases += A//instead, they contain the disease that was in this
		if(prob(A.resistance))
			var/atom/blobbernaut = new /mob/living/simple_animal/hostile/blob/blobbernaut/(M.loc)
			blobbernaut.add_atom_colour(pick(BLOB_STRAIN_COLOR_LIST), FIXED_COLOUR_PRIORITY)
		var/atom/blob_tile = new pick_blob(M.loc)
		blob_tile.add_atom_colour(pick(BLOB_STRAIN_COLOR_LIST), FIXED_COLOUR_PRIORITY) //A random colour for the blob, as this blob isn't going to get a overmind colour
	M.visible_message("<span class='danger'>A huge mass of blob and blob spores burst out of [M]!</span>")
