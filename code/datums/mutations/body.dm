//These mutations change your overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/epilepsy
	name = "Epilepsy"
	desc = "A genetic defect that sporadically causes seizures."
	quality = NEGATIVE
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/epilepsy/on_life()
	if(prob(1 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS)
		owner.visible_message("<span class='danger'>[owner] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		owner.Unconscious(200 * GET_MUTATION_POWER(src))
		owner.Jitter(1000 * GET_MUTATION_POWER(src))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "epilepsy", /datum/mood_event/epilepsy)
		addtimer(CALLBACK(src, PROC_REF(jitter_less)), 9 SECONDS)

/datum/mutation/epilepsy/proc/jitter_less()
	if(owner)
		owner.jitteriness = 10


//Unstable DNA induces random mutations!
/datum/mutation/bad_dna
	name = "Unstable DNA"
	desc = "Strange mutation that causes the holder to randomly mutate."
	quality = NEGATIVE
	locked = TRUE

/datum/mutation/bad_dna/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	var/mob/new_mob
	if(prob(95))
		if(prob(50))
			new_mob = owner.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		else
			new_mob = owner.randmuti()
	else
		new_mob = owner.easy_randmut(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/cough
	name = "Cough"
	desc = "A chronic cough."
	quality = MINOR_NEGATIVE
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/cough/on_life()
	if(prob(5 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")
		if(GET_MUTATION_POWER(src) > 1)
			var/cough_range = GET_MUTATION_POWER(src) * 4
			var/turf/target = get_ranged_target_turf(owner, turn(owner.dir, 180), cough_range)
			owner.throw_at(target, cough_range, GET_MUTATION_POWER(src))

/datum/mutation/paranoia
	name = "Paranoia"
	desc = "Subject is easily terrified, and may suffer from hallucinations."
	quality = NEGATIVE

/datum/mutation/paranoia/on_life()
	if(prob(5) && owner.stat == CONSCIOUS)
		owner.emote("scream")
		if(prob(25))
			owner.hallucination += 20

//Dwarfism shrinks your body and lets you pass tables.
/datum/mutation/dwarfism
	name = "Dwarfism"
	desc = "A mutation believed to be the cause of dwarfism."
	quality = POSITIVE
	difficulty = 16
	instability = 5
	conflicts = list(GIGANTISM)
	locked = TRUE    // Default intert species for now, so locked from regular pool.

/datum/mutation/dwarfism/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.resize = 0.8
	owner.update_transform()
	passtable_on(owner, GENETIC_MUTATION)
	owner.visible_message("<span class='danger'>[owner] suddenly shrinks!</span>", "<span class='notice'>Everything around you seems to grow..</span>")

/datum/mutation/dwarfism/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.resize = 1.25
	owner.update_transform()
	passtable_off(owner, GENETIC_MUTATION)
	owner.visible_message("<span class='danger'>[owner] suddenly grows!</span>", "<span class='notice'>Everything around you seems to shrink..</span>")


//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/clumsy
	name = "Clumsiness"
	desc = "A genome that inhibits certain brain functions, causing the holder to appear clumsy. Honk"
	quality = MINOR_NEGATIVE
	traits = TRAIT_CLUMSY

//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/tourettes
	name = "Tourette's Syndrome"
	desc = "A chronic twitch that forces the user to scream bad words." //definitely needs rewriting
	quality = NEGATIVE
	synchronizer_coeff = 1

/datum/mutation/tourettes/on_life()
	if(prob(10 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS && !owner.IsStun())
		owner.Stun(20)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]", forced="tourette's syndrome")
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2, 2)
		var/y_offset = owner.pixel_y + rand(-1, 1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)


//Deafness makes you deaf.
/datum/mutation/deaf
	name = "Deafness"
	desc = "The holder of this genome is completely deaf."
	quality = NEGATIVE
	traits = TRAIT_DEAF

/datum/mutation/deaf/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	SEND_SOUND(owner, sound(null))

//Monified turns you into a monkey.
/datum/mutation/race
	name = "Monkified"
	desc = "A strange genome, believed to be what differentiates monkeys from humans."
	quality = NEGATIVE
	mobtypes_allowed = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	locked = TRUE //Species specific, keep out of actual gene pool
	var/datum/species/original_species = /datum/species/human

/datum/mutation/race/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	original_species = owner.dna.species.type
	. = owner.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE | TR_KEEPAI, FALSE, TRUE)

/datum/mutation/race/on_losing(mob/living/carbon/monkey/owner)
	if(istype(owner) && owner.stat != DEAD && !..())
		. = owner.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE | TR_KEEPAI, TRUE, original_species)

/datum/mutation/glow
	name = "Glowy"
	desc = "You permanently emit a light with a random color and intensity."
	quality = POSITIVE
	instability = 5
	power_coeff = 1
	conflicts = list(ANTIGLOWY)
	var/obj/effect/dummy/luminescent_glow/glowth //shamelessly copied from luminescents
	var/glow = 2.5
	var/range = 2.5

/datum/mutation/glow/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	glowth = new(owner)
	modify()

/datum/mutation/glow/modify()
	if(QDELETED(glowth))
		return
	var/power = GET_MUTATION_POWER(src)
	glowth.set_light_range_power_color(range * power, glow * power, "#[dna.features["mcolor"]]")

/datum/mutation/glow/on_losing(mob/living/carbon/owner)
	if(..())
		return
	QDEL_NULL(glowth)

/datum/mutation/glow/anti
	name = "Anti-Glow"
	desc = "Your skin seems to attract and absorb nearby light creating 'darkness' around you."
	glow = -3.5 //Slightly stronger, since negating light tends to be harder than making it.
	conflicts = list(GLOWY)
	locked = TRUE

/datum/mutation/strong
	name = "Strength"
	desc = "The user's muscles slightly expand."
	quality = POSITIVE
	difficulty = 16

/datum/mutation/insulated
	name = "Insulated"
	desc = "The affected person does not conduct electricity."
	quality = POSITIVE
	difficulty = 16
	instability = 25
	traits = TRAIT_SHOCKIMMUNE

/datum/mutation/fire
	name = "Fiery Sweat"
	desc = "The user's skin will randomly combust, but is generally alot more resilient to burning."
	quality = NEGATIVE
	difficulty = 14
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/fire/on_life()
	if(prob((1+(100-dna.stability)/10)) * GET_MUTATION_SYNCHRONIZER(src))
		owner.adjust_fire_stacks(2 * GET_MUTATION_POWER(src))
		owner.IgniteMob()

/datum/mutation/fire/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.burn_mod *= 0.5

/datum/mutation/fire/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.burn_mod *= 2

/datum/mutation/badblink
	name = "Spatial Instability"
	desc = "The victim of the mutation has a very weak link to spatial reality, and may be displaced. Often causes extreme nausea."
	quality = NEGATIVE
	difficulty = 18//high so it's hard to unlock and abuse
	instability = 10
	synchronizer_coeff = 1
	energy_coeff = 1
	power_coeff = 1
	var/warpchance = 0

/datum/mutation/badblink/on_life()
	if(prob(warpchance))
		var/warpmessage = pick(
			"<span class='warning'>With a sickening 720 degree twist of their back, [owner] vanishes into thin air.</span>",
			"<span class='warning'>[owner] does some sort of strange backflip into another dimension. It looks pretty painful.</span>",
			"<span class='warning'>[owner] does a jump to the left, a step to the right, and warps out of reality.</span>",
			"<span class='warning'>[owner]'s torso starts folding inside out until it vanishes from reality, taking [owner] with it.</span>",
			"<span class='warning'>One moment, you see [owner]. The next, [owner] is gone.</span>")
		owner.visible_message(warpmessage, "<span class='userdanger'>You feel a wave of nausea as you fall through reality!</span>")
		var/warpdistance = rand(10, 15) * GET_MUTATION_POWER(src)
		do_teleport(owner, get_turf(owner), warpdistance, channel = TELEPORT_CHANNEL_BLINK)
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (warpchance * warpdistance))
		warpchance = 0
		owner.visible_message("<span class='danger'>[owner] appears out of nowhere!</span>")
	else
		warpchance += 0.25 * GET_MUTATION_ENERGY(src)

/datum/mutation/acidflesh
	name = "Acidic Flesh"
	desc = "Subject has acidic chemicals building up underneath their skin. This is often lethal."
	quality = NEGATIVE
	difficulty = 18//high so it's hard to unlock and use on others
	COOLDOWN_DECLARE(message_cooldown)

/datum/mutation/acidflesh/on_life()
	if(prob(25))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(owner, "<span class='danger'>Your acid flesh bubbles...</span>")
			COOLDOWN_START(src, message_cooldown, 20 SECONDS)
		if(prob(15))
			owner.acid_act(rand(30, 50), 10)
			owner.visible_message("<span class='warning'>[owner]'s skin bubbles and pops.</span>", "<span class='userdanger'>Your bubbling flesh pops! It burns!</span>")
			playsound(owner, 'sound/weapons/sear.ogg', vol = 50, vary = TRUE)

/datum/mutation/gigantism
	name = "Gigantism"//negative version of dwarfism
	desc = "The cells within the subject spread out to cover more area, making them appear larger."
	quality = MINOR_NEGATIVE
	difficulty = 12
	conflicts = list(DWARFISM)

/datum/mutation/gigantism/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.resize = 1.25
	owner.update_transform()
	owner.visible_message("<span class='danger'>[owner] suddenly grows!</span>", "<span class='notice'>Everything around you seems to shrink..</span>")

/datum/mutation/gigantism/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.resize = 0.8
	owner.update_transform()
	owner.visible_message("<span class='danger'>[owner] suddenly shrinks!</span>", "<span class='notice'>Everything around you seems to grow..</span>")

/datum/mutation/spastic
	name = "Spastic"
	desc = "Subject suffers from muscle spasms."
	quality = NEGATIVE
	difficulty = 16

/datum/mutation/spastic/on_acquiring()
	if(..())
		return
	owner.apply_status_effect(STATUS_EFFECT_SPASMS)

/datum/mutation/spastic/on_losing()
	if(..())
		return
	owner.remove_status_effect(STATUS_EFFECT_SPASMS)

/datum/mutation/extrastun
	name = "Two Left Feet"
	desc = "A mutation that disrupts coordination in the legs. It makes standing up after getting knocked down very difficult."
	quality = NEGATIVE
	difficulty = 16
	COOLDOWN_DECLARE(stun_cooldown)

/datum/mutation/extrastun/on_life()
	if(!COOLDOWN_FINISHED(src, stun_cooldown))
		return
	var/knockdown = owner.AmountKnockdown()
	var/stun = owner.AmountStun()
	if(knockdown || stun)
		owner.SetKnockdown(knockdown * 2)
		owner.SetStun(stun * 2)
		owner.visible_message("<span class='danger'>[owner] tries to stand up, but trips!</span>", "<span class='userdanger'>You trip over your own feet!</span>")
		COOLDOWN_START(src, stun_cooldown, 30 SECONDS)

/datum/mutation/strongwings
	name = "Strengthened Wings"
	desc = "Subject's wing muscle volume rapidly increases."
	quality = POSITIVE
	locked = TRUE
	difficulty = 12
	instability = 15
	power_coeff = 1
	species_allowed = list(SPECIES_APID, SPECIES_MOTH)

/datum/mutation/strongwings/on_acquiring()
	if(..())
		return
	var/obj/item/organ/wings/wings = owner.getorganslot(ORGAN_SLOT_WINGS)
	if(!wings)
		to_chat(owner, "<span class='warning'>You don't have wings to strengthen!</span>")
		return
	if(istype(wings, /obj/item/organ/wings/moth))
		var/obj/item/organ/wings/moth/moth_wings = wings
		moth_wings.flight_level += 1
		moth_wings.Refresh(owner)
	else if(istype(wings, /obj/item/organ/wings/bee))
		var/obj/item/organ/wings/bee/bee_wings = wings
		bee_wings.jumpdist = initial(bee_wings.jumpdist) + (6 * GET_MUTATION_POWER(src)) - 3
	else
		to_chat(owner, "<span class='warning'>Those wings are incompatible with the mutation!</span>")
		return
	to_chat(owner, "<span class='notice'>Your wings feel stronger.</span>")

/datum/mutation/strongwings/on_losing()
	if(..())
		return
	var/obj/item/organ/wings/wings = owner.getorganslot(ORGAN_SLOT_WINGS)
	if(!wings)
		return
	if(istype(wings, /obj/item/organ/wings/moth))
		var/obj/item/organ/wings/moth/moth_wings = wings
		moth_wings.flight_level -= 1
		moth_wings.Refresh(owner)
		to_chat(owner, "<span class='warning'>Your wings feel weak.</span>")
	else if(istype(wings, /obj/item/organ/wings/bee))
		var/obj/item/organ/wings/bee/bee_wings = wings
		bee_wings.jumpdist = initial(bee_wings.jumpdist)
		to_chat(owner, "<span class='warning'>Your wings feel weak.</span>")

/datum/mutation/strongwings/modify()
	..()
	var/obj/item/organ/wings/bee/bee_wings = owner.getorganslot(ORGAN_SLOT_WINGS)
	if(istype(bee_wings))
		bee_wings.jumpdist = initial(bee_wings.jumpdist) + (6 * GET_MUTATION_POWER(src)) - 3
/datum/mutation/catclaws
	name = "Cat Claws"
	desc = "Subject's hands grow sharpened claws."
	quality = POSITIVE
	locked = TRUE
	difficulty = 12
	instability = 25
	power_coeff = 1
	species_allowed = list(SPECIES_FELINID)
	var/added_damage = 6

/datum/mutation/catclaws/on_acquiring()
	if(..())
		return
	added_damage = min(17, initial(added_damage) * GET_MUTATION_POWER(src) + owner.dna.species.punchdamage) - owner.dna.species.punchdamage
	owner.dna.species.punchdamage += added_damage
	owner.dna.species.attack_verb = "slash"
	owner.dna.species.attack_sound = 'sound/weapons/slash.ogg'
	owner.dna.species.miss_sound = 'sound/weapons/slashmiss.ogg'
	to_chat(owner, "<span class='notice'>Claws extend from your fingertips.</span>")

/datum/mutation/catclaws/on_losing()
	if(..())
		return
	to_chat(owner, "<span class='warning'> Your claws retract into your hand.</span>")
	owner.dna.species.punchdamage -= added_damage
	owner.dna.species.attack_verb = initial(owner.dna.species.attack_verb)
	owner.dna.species.attack_sound = initial(owner.dna.species.attack_sound)
	owner.dna.species.miss_sound = initial(owner.dna.species.miss_sound)

/datum/mutation/catclaws/modify()
	..()
	if(added_damage)
		owner.dna.species.punchdamage -= added_damage
	added_damage = min(17, initial(added_damage) * GET_MUTATION_POWER(src) + owner.dna.species.punchdamage) - owner.dna.species.punchdamage
	owner.dna.species.punchdamage += added_damage
