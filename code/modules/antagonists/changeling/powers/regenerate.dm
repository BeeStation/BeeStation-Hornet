/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs and vital internal organs, as well as removing shrapnel and restoring blood volume. Costs 10 chemicals."
	helptext = "Will alert nearby crew if any external limbs are regenerated. Can be used while unconscious."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = 1
	req_stat = UNCONSCIOUS

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>You feel an itching, both inside and \
		outside as your tissues knit and reknit.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/list/missing = C.get_missing_limbs()
		if(missing.len)
			playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
			C.visible_message("<span class='warning'>[user]'s missing limbs \
				reform, making a loud, grotesque sound!</span>",
				"<span class='userdanger'>Your limbs regrow, making a \
				loud, crunchy sound and giving you great pain!</span>",
				"<span class='italics'>You hear organic matter ripping \
				and tearing!</span>")
			C.emote("scream")
			C.regenerate_limbs(1)
		if(!user.getorganslot(ORGAN_SLOT_BRAIN))
			var/obj/item/organ/brain/B
			if(C.has_dna() && C.dna.species.mutant_brain)
				B = new C.dna.species.mutant_brain()
			else
				B = new()
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE
			B.Insert(C)
		C.regenerate_organs()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
	return TRUE

/datum/action/changeling/limbsnake
	name = "Limb Snake"
	desc = "We turn our limbs into a slithering snake. The poison of this creatures can paralyze attackers. Costs 15 chemicals."
	helptext = "We reform one of our limbs as a hostile snake-like creature. This grotesque display may ward off attackers, and the creature will inject them with incapacitating poison."
	button_icon_state = "last_resort"
	chemical_cost = 15
	dna_cost = 1
	req_human = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE

/datum/action/changeling/limbsnake/sting_action(mob/user)
	var/mob/living/carbon/C = user
	var/list/parts = list()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.body_part != HEAD && BP.body_part != CHEST)
			if(BP.dismemberable)
				parts += BP
	if(!parts.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)	//copy_paste from regenerate
		C.visible_message("<span class='warning'>[user]'s missing limbs \
			reform, making a loud, grotesque sound!</span>",
			"<span class='userdanger'>Your limbs regrow, making a \
			loud, crunchy sound and giving you great pain!</span>",
			"<span class='italics'>You hear organic matter ripping \
			and tearing!</span>")
		C.regenerate_limbs(1)
		return
	//limb related actions
	var/obj/item/bodypart/BP = pick(parts)
	C.visible_message("<span class='warning'>[user]'s [BP] detaches itself and takes the form of a snake!</span>",
			"<span class='userdanger'>Our [BP] forms into a horrifying snake and heads towards our attackers!</span>")
	BP.Destroy()	
	//Deploy limbsnake
	var/mob/living/snek = new /mob/living/simple_animal/hostile/retaliate/poison/snake/limb(get_turf(user))		
	//assign faction
	var/list/factions = user.faction.Copy()
	snek.faction = factions
	//text message
	

/mob/living/simple_animal/hostile/retaliate/poison/snake/limb
        name = "limb snake"
        desc = "This is no snake at all! It looks like someone's limb grew fangs out of it's fingers and it's out to bite anyone!"
        
		health = 20
		maxHealth = 20
		melee_damage = 6
        faction = list("creature")
        poison_per_bite = 3
        poison_type = /datum/reagent/toxin/staminatoxin