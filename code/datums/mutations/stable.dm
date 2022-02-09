//Grants 20 stability, but 20 instability. You must use an activator or chromosome to get any effect.
/datum/mutation/human/stable_genetics
	name = "Stable Genetics"
	desc = "The specimen's genome can handle more mutations before melting, reducing instability by 20 if activated."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel healthy.</span>"
	instability = 20 //Must be activated from your base SE, this isn't completely free stability
	difficulty = 20 //Good luck solving this without a handheld sequencer

/datum/mutation/human/stable_genetics/on_acquiring(mob/living/carbon/human/H)
	if(..())
		return
	H.dna.base_stability += 20

/datum/mutation/human/stable_genetics/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.dna.base_stability -= 20
