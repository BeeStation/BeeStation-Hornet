/datum/role_preference/midround_ghost/blob
	name = "Blob"
	description = "The blob infests the station and destroys everything in its path, including \
	hull, fixtures, and creatures.\n\
	Spread your mass, collect resources, and \
	consume the entire station. Make sure to prepare your defenses, because the \
	crew will be alerted to your presence!"
	antag_datum = /datum/antagonist/blob

/datum/role_preference/midround_ghost/blob/get_preview_icon()
	var/datum/blobstrain/reagent/reactive_spines/reactive_spines = /datum/blobstrain/reagent/reactive_spines

	var/icon/icon = icon('icons/mob/blob.dmi', "blob_core")
	icon.Blend(initial(reactive_spines.color), ICON_MULTIPLY)
	icon.Blend(icon('icons/mob/blob.dmi', "blob_core_overlay"), ICON_OVERLAY)
	icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/datum/role_preference/midround_ghost/xenomorph
	name = "Xenomorph"
	description = "Become the extraterrestrial xenomorph. Start as a larva, and progress \
	your way up the caste, including even the Queen!"
	antag_datum = /datum/antagonist/xeno

/datum/role_preference/midround_ghost/xenomorph/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/alien.dmi', "alienh"))

/datum/role_preference/midround_ghost/nightmare
	name = "Nightmare"
	description = "Use your light eater to break sources of light to survive and thrive. \
	Jaunt through the darkness and seek your prey with night vision."
	antag_datum = /datum/antagonist/nightmare
	preview_outfit = /datum/outfit/nightmare

/datum/outfit/nightmare
	name = "Nightmare (Preview only)"

/datum/outfit/nightmare/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/shadow/nightmare)

/datum/role_preference/midround_ghost/space_dragon
	name = "Space Dragon"
	description = "Become a ferocious space dragon. Breathe fire, summon an army of space \
	carps, crush walls, and terrorize the station."
	antag_datum = /datum/antagonist/space_dragon

/datum/role_preference/midround_ghost/space_dragon/get_preview_icon()
	var/icon/icon = icon('icons/mob/spacedragon.dmi', "spacedragon")

	icon.Blend("#7848bb", ICON_MULTIPLY)
	icon.Blend(icon('icons/mob/spacedragon.dmi', "overlay_base"), ICON_OVERLAY)

	icon.Crop(10, 9, 54, 53)
	icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/datum/role_preference/midround_ghost/nuclear_operative
	name = "Nuclear Operative (Midround)"
	description = "Congratulations, agent. You have been chosen to join the Syndicate \
	Nuclear Operative strike team. Your mission, whether or not you choose \
	to accept it, is to destroy Nanotrasen's most advanced research facility! \
	That's right, you're going to Space Station 13.\n\
	Retrieve the nuclear authentication disk, use it to activate the nuclear \
	fission explosive, and destroy the station."
	antag_datum = /datum/antagonist/nukeop
	use_icon = /datum/role_preference/antagonist/nuclear_operative

/datum/role_preference/midround_ghost/wizard
	name = "Wizard (Midround)"
	description = "GREETINGS. WE'RE THE WIZARDS OF THE WIZARD'S FEDERATION.\n\
	Choose between a variety of powerful spells in order to cause chaos among Space Station 13."
	antag_datum = /datum/antagonist/wizard
	use_icon = /datum/role_preference/antagonist/wizard

/datum/role_preference/midround_ghost/abductor
	name = "Abductor"
	description = "Abductors are technologically advanced alien society set on cataloging \
	all species in the system. Unfortunately for their subjects their methods \
	are quite invasive. \n\
	You and a partner will become the abductor scientist and agent duo. \
	As an agent, abduct unassuming victims and bring them back to your UFO. \
	As a scientist, scout out victims for your agent, keep them safe, and \
	operate on whoever they bring back."
	antag_datum = /datum/antagonist/abductor

/datum/role_preference/midround_ghost/abductor/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/scientist = new
	var/mob/living/carbon/human/dummy/consistent/agent = new

	scientist.set_species(/datum/species/abductor)
	agent.set_species(/datum/species/abductor)

	var/icon/scientist_icon = render_preview_outfit(/datum/outfit/abductor/scientist, scientist)
	scientist_icon.Shift(WEST, 8)

	var/icon/agent_icon = render_preview_outfit(/datum/outfit/abductor/agent, agent)
	agent_icon.Shift(EAST, 8)

	var/icon/final_icon = scientist_icon
	final_icon.Blend(agent_icon, ICON_OVERLAY)

	qdel(scientist)
	qdel(agent)

	return finish_preview_icon(final_icon)

/datum/role_preference/midround_ghost/space_pirate
	name = "Space Pirate"
	description = "Gather your crewmates and infiltrate Space Station 13's vault. \
	Loot that booty, and don't get gunned down in the process!"
	antag_datum = /datum/antagonist/pirate

/datum/role_preference/midround_ghost/space_pirate/get_preview_icon()
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	var/icon/foreground = render_preview_outfit(/datum/outfit/pirate_space_preview/captain)
	var/icon/background = render_preview_outfit(/datum/outfit/pirate_space_preview)
	background.Blend(rgb(206, 206, 206, 220), ICON_MULTIPLY)

	final_icon.Blend(background, ICON_OVERLAY, -world.icon_size / 4, 0)
	final_icon.Blend(background, ICON_OVERLAY, world.icon_size / 4, 0)
	final_icon.Blend(foreground, ICON_OVERLAY, 0, 0)

	return finish_preview_icon(final_icon)

/datum/outfit/pirate_space_preview
	name = "Space Pirate (Preview only)"
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	glasses = /obj/item/clothing/glasses/eyepatch

/datum/outfit/pirate_space_preview/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.set_species(/datum/species/skeleton)

/datum/outfit/pirate_space_preview/captain
	name = "Space Pirate Captain (Preview only)"
	head = /obj/item/clothing/head/helmet/space/pirate

/datum/role_preference/midround_ghost/revenant
	name = "Revenant"
	description = "Become the mysterious revenant. Break windows, overload lights, and eat \
	the crew's life force, all while talking to your old community of disgruntled ghosts."
	antag_datum = /datum/antagonist/revenant

/datum/role_preference/midround_ghost/revenant/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/mob.dmi', "revenant_revealed"))

/datum/role_preference/midround_ghost/spider
	name = "Spider"
	description = "Swarm and spread your webs accross every corner of the station. \
	Work with your cluster of fellow spiders, each with different roles - melee, venom, webbing, and egg-laying."
	antag_datum = /datum/antagonist/spider

/datum/role_preference/midround_ghost/spider/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/animal.dmi', "broodmother"))

/datum/role_preference/midround_ghost/swarmer
	name = "Swarmer"
	description = "A swarmer is a small robot that replicates itself autonomously with \
	nearby given materials and prepare structures that they come \
	across for the following invasion force. \n\
	Consume machines, structures, walls, anything to get materials. Replicate \
	as many swarmers as you can to repeat the process."
	antag_datum = /datum/antagonist/swarmer

/datum/role_preference/midround_ghost/swarmer/get_preview_icon()
	var/icon/swarmer_icon = icon('icons/mob/swarmer.dmi', "swarmer")
	swarmer_icon.Shift(NORTH, 8)
	return finish_preview_icon(swarmer_icon)

/datum/role_preference/midround_ghost/morph
	name = "Morph"
	description = "Eat everything in your sights, confuse the crew with your shapeshifting abilities and hallucination toxin, \
	and chow down on dead things to heal."
	antag_datum = /datum/antagonist/morph

/datum/role_preference/midround_ghost/morph/get_preview_icon()
	var/icon/morph_icon = icon('icons/mob/animal.dmi', "morph")
	morph_icon.Shift(NORTH, 8)
	return finish_preview_icon(morph_icon)

/datum/role_preference/midround_ghost/prisoner
	name = "prisoner"
	description = "You are a Prisoner, sent to the station brig by Nanotrasen. \
	You have a chance to escape, but be careful, the security officers are on high alert."
	antag_datum = /datum/antagonist/prisoner
	preview_outfit = /datum/outfit/prisoner

/datum/role_preference/midround_ghost/fugitive
	name = "Fugitive"
	description = "You're a fugitive, escaped from imprisonment. You've managed to make it to Space Station 13. \
	Now is the time to run and hide. But be careful, the Fugitive Hunters are hot on your tail."
	antag_datum = /datum/antagonist/fugitive
	preview_outfit = /datum/outfit/waldo

/datum/role_preference/midround_ghost/fugitive_hunter
	name = "Fugitive Hunter"
	description = "You've been hired to hunt down the Fugitives who have escaped aboard Space Station 13. \
	Find them, and bring them to the bluespace capture console aboard your shuttle. Cooperate with the station crew if necessary."
	antag_datum = /datum/antagonist/fugitive_hunter

/datum/role_preference/midround_ghost/fugitive_hunter/get_preview_icon()
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	var/icon/foreground = render_preview_outfit(/datum/outfit/bounty/hook)
	var/icon/background = render_preview_outfit(/datum/outfit/russian_hunter/leader)
	var/icon/background_2 = render_preview_outfit(/datum/outfit/spacepol/sergeant)
	background.Blend(rgb(206, 206, 206, 220), ICON_MULTIPLY)
	background_2.Blend(rgb(206, 206, 206, 220), ICON_MULTIPLY)

	final_icon.Blend(background, ICON_OVERLAY, -world.icon_size / 4, 0)
	final_icon.Blend(background_2, ICON_OVERLAY, world.icon_size / 4, 0)
	final_icon.Blend(foreground, ICON_OVERLAY, 0, 0)

	return finish_preview_icon(final_icon)

/datum/role_preference/midround_ghost/ninja
	name = "Ninja"
	description = "Become a conniving space ninja, equipped with a teleporting katana, gloves to hack \
	into airlocks and APCs, a suit to make you go near-invisible, \
	as well as a variety of abilities in your kit. Capture beings in your net and get on your way!"
	antag_datum = /datum/antagonist/ninja
	preview_outfit = /datum/outfit/ninja_preview

/datum/outfit/ninja_preview
	name = "Space Ninja (Preview only)"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/space/space_ninja
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/space_ninja
	head = /obj/item/clothing/head/helmet/space/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	back = /obj/item/tank/jetpack/carbondioxide
	// No katana because it has trouble GCing
	//belt = /obj/item/energy_katana

/datum/role_preference/midround_ghost/slaughter_demon
	name = "Slaughter Demon"
	description = "Use your blood jaunt to terrorize the crew, and drag them all to hell."
	antag_datum = /datum/antagonist/slaughter

/datum/role_preference/midround_ghost/slaughter_demon/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/mob.dmi', "daemon"))

/datum/role_preference/midround_living/obsessed
	name = "Obsessed"
	description = "You're obsessed with someone! Your obsession may begin to notice their \
	personal items are stolen and their coworkers have gone missing, \
	but will they realize they are your next victim in time?"
	antag_datum = /datum/antagonist/obsessed

/datum/role_preference/midround_living/obsessed/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/victim_dummy = new
	victim_dummy.hair_color = "b96" // Brown
	victim_dummy.hair_style = "Messy"
	victim_dummy.update_hair()

	var/icon/obsessed_icon = render_preview_outfit(/datum/outfit/obsessed)
	obsessed_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	var/icon/final_icon = finish_preview_icon(obsessed_icon)

	final_icon.Blend(
		icon('icons/ui_icons/antags/obsessed.dmi', "obsession"),
		ICON_OVERLAY,
		ANTAGONIST_PREVIEW_ICON_SIZE - 30,
		20,
	)

	return final_icon

/datum/outfit/obsessed
	name = "Obsessed (Preview only)"

	uniform = /obj/item/clothing/under/misc/overalls
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	neck = /obj/item/camera
	suit = /obj/item/clothing/suit/apron

/datum/outfit/obsessed/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	H.regenerate_icons()
