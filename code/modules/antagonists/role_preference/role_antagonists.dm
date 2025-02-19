#define TRAITOR_DESC "An unpaid debt. A score to be settled. Maybe you were just in the wrong \
	place at the wrong time. Whatever the reasons, you were selected to \
	infiltrate Space Station 13."
#define TRAITOR_DESC_DETAILS "Start with a set of sinister objectives and an uplink to purchase \
	items to get the job done."

/datum/role_preference/antagonist/traitor
	name = "Traitor"
	description = TRAITOR_DESC + "\n" + TRAITOR_DESC_DETAILS
	antag_datum = /datum/antagonist/traitor
	preview_outfit = /datum/outfit/traitor

/datum/role_preference/midround_living/traitor
	name = "Syndicate Sleeper Agent"
	description = TRAITOR_DESC + "\n" + TRAITOR_DESC_DETAILS
	antag_datum = /datum/antagonist/traitor
	use_icon = /datum/role_preference/antagonist/traitor

#undef TRAITOR_DESC

/datum/role_preference/antagonist/internal_affairs
	name = "Internal Affairs Agent"
	description = "A traitor who was actually hired by Nanotrasen to stage a Syndicate attack.\n" + TRAITOR_DESC_DETAILS
	antag_datum = /datum/antagonist/traitor/internal_affairs
	use_icon = /datum/role_preference/antagonist/traitor
	category = ROLE_PREFERENCE_CATEGORY_LEGACY

/datum/outfit/traitor
	name = "Traitor (Preview only)"

	uniform = /obj/item/clothing/under/syndicate
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas
	l_hand = /obj/item/melee/transforming/energy/sword
	r_hand = /obj/item/gun/energy/recharge/ebow

/datum/outfit/traitor/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/melee/transforming/energy/sword/sword = locate() in H.held_items
	sword.icon_state = "swordred"
	H.update_inv_hands()
	H.hair_style = "Messy"
	H.hair_color = "431"
	H.update_hair()

/datum/role_preference/antagonist/changeling
	name = "Changeling"
	description = "A highly intelligent alien predator that is capable of altering their \
	shape to flawlessly resemble a human.\n\
	Transform yourself or others into different identities, and buy from an \
	arsenal of biological weaponry with the DNA you collect."
	antag_datum = /datum/antagonist/changeling

/datum/role_preference/antagonist/changeling/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/medical_doctor_changeling_preview)
	var/icon/split_icon = render_preview_outfit(/datum/outfit/job/engineer)

	final_icon.Shift(WEST, world.icon_size / 2)
	final_icon.Shift(EAST, world.icon_size / 2)

	split_icon.Shift(EAST, world.icon_size / 2)
	split_icon.Shift(WEST, world.icon_size / 2)

	final_icon.Blend(split_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/outfit/medical_doctor_changeling_preview
	name = "Medical Doctor Changeling (Preview only)"
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit =  /obj/item/clothing/suit/toggle/labcoat
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	r_hand = /obj/item/melee/arm_blade

/datum/outfit/medical_doctor_changeling_preview/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.dna.features["mcolor"] = "8d8"
	H.dna.features["horns"] = "Short"
	H.dna.features["frills"] = "Simple"
	H.set_species(/datum/species/lizard)

/datum/role_preference/antagonist/blood_brother
	name = "Blood Brother"
	description = "Team up with other crew members as blood brothers to combine the strengths \
	of your departments, break each other out of prison, and overwhelm the station."
	antag_datum = /datum/antagonist/brother

/datum/role_preference/antagonist/blood_brother/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new

	brother1.hair_style = "Pigtails"
	brother1.hair_color = "532"
	brother1.update_hair()

	brother2.dna.features["moth_antennae"] = "Plain"
	brother2.dna.features["moth_markings"] = "None"
	brother2.dna.features["moth_wings"] = "Plain"
	brother2.set_species(/datum/species/moth)

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	brother1_icon.Blend(icon('icons/effects/blood.dmi', "maskblood"), ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist, brother2)
	brother2_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)

	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return finish_preview_icon(final_icon)

/datum/role_preference/antagonist/blood_cultist
	name = "Blood Cultist"
	description = "The Geometer of Blood, Nar-Sie, has sent a number of her followers to \
	Space Station 13. As a cultist, you have an abundance of cult magics at \
	your disposal, something for all situations. You must work with your \
	brethren to summon an avatar of your eldritch goddess!\n\
	Armed with blood magic, convert crew members to the Blood Cult, sacrifice \
	those who get in the way, and summon Nar-Sie."
	antag_datum = /datum/antagonist/cult

/datum/role_preference/antagonist/blood_cultist/get_preview_icon()
	var/icon/icon = render_preview_outfit(/datum/outfit/blood_cult_preview)

	// The longsword is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/cultblade/longsword = new
	icon.Blend(icon(longsword.lefthand_file, longsword.item_state), ICON_OVERLAY)
	qdel(longsword)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/outfit/blood_cult_preview
	name = "Blood Cultist (Preview only)"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/hooded/cultrobes/cult_shield/anyone
	head = /obj/item/clothing/head/hooded/cult_hoodie
	r_hand = /obj/item/melee/blood_magic/stun
	l_hand = /obj/item/shield/mirror

/datum/outfit/blood_cult_preview/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.eye_color = BLOODCULT_EYE
	H.update_body()

/datum/role_preference/antagonist/clock_cultist
	name = "Clock Cultist"
	description = "Hailing from the clockwork city of Reebe, serve your god, Ratvar. \
	Gather power to summon an avatar of Ratvar through the clockwork rift!\n\
	Drop down among the station to install cogs into APCs to gain power. Be careful, as when the rift opens, \
	the crew will rush into Reebe! Build defenses to slow down their entry."
	antag_datum = /datum/antagonist/servant_of_ratvar
	preview_outfit = /datum/outfit/clockcult_preview

/datum/outfit/clockcult_preview
	name = "Servant of Ratvar (Preview only)"
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/storage/belt/utility
	suit = /obj/item/clothing/suit/clockwork/anyone
	l_hand = /obj/item/clockwork/weapon/brass_spear
	head = /obj/item/clothing/head/helmet/clockcult
	gloves = /obj/item/clothing/gloves/clockcult

/datum/role_preference/antagonist/revolutionary
	name = "Head Revolutionary"
	description = "Armed with a flash, convert as many people to the revolution as you can.\n\
	Kill or exile all heads of staff on the station."
	antag_datum = /datum/antagonist/rev/head
	preview_outfit = /datum/outfit/revolutionary

/datum/outfit/revolutionary
	name = "Revolutionary (Preview only)"
	uniform = /obj/item/clothing/under/costume/soviet
	head = /obj/item/clothing/head/costume/ushanka
	gloves = /obj/item/clothing/gloves/color/black
	l_hand = /obj/item/spear
	r_hand = /obj/item/assembly/flash

/datum/role_preference/antagonist/revolutionary/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_assistant_icon("Business Hair"), ICON_UNDERLAY, -8, 0)
	final_icon.Blend(make_assistant_icon("CIA"), ICON_UNDERLAY, 8, 0)

	// Apply the rev head HUD, but scale up the preview icon a bit beforehand.
	// Otherwise, the R gets cut off.
	final_icon.Scale(64, 64)

	var/icon/rev_head_icon = icon('icons/mob/hud.dmi', "rev_head")
	rev_head_icon.Scale(48, 48)
	rev_head_icon.Crop(1, 1, 64, 64)
	rev_head_icon.Shift(EAST, 10)
	rev_head_icon.Shift(NORTH, 16)
	final_icon.Blend(rev_head_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/role_preference/antagonist/revolutionary/proc/make_assistant_icon(hair_style)
	var/mob/living/carbon/human/dummy/consistent/assistant = new
	assistant.hair_style = hair_style
	assistant.update_hair()

	var/icon/assistant_icon = render_preview_outfit(/datum/outfit/job/assistant/consistent, assistant)
	assistant_icon.ChangeOpacity(0.5)

	qdel(assistant)

	return assistant_icon

/datum/role_preference/antagonist/heretic
	name = "Heretic"
	description = "Find hidden influences and sacrifice crew members to gain magical \
	powers and ascend as one of several paths. \n\
	Forgotten, devoured, gutted. Humanity has forgotten the eldritch forces \
	of decay, but the mansus veil has weakened. We will make them taste fear \
	again..."
	antag_datum = /datum/antagonist/heretic

/datum/role_preference/antagonist/heretic/get_preview_icon()
	var/icon/icon = render_preview_outfit(/datum/outfit/heretic_preview)

	// The sickly blade is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/sickly_blade/ash/blade = new
	icon.Blend(icon(blade.lefthand_file, blade.item_state), ICON_OVERLAY)
	qdel(blade)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/outfit/heretic_preview
	name = "Heretic (Preview only)"
	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	head = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	r_hand = /obj/item/melee/touch_attack/mansus_fist

/datum/role_preference/antagonist/incursionist
	name = "Incursionist"
	description = "As a member of the Syndicate Incursion, work with your team of agents to accomplish your objectives.\n\
	Use your radio to speak with other members of the incursion, and keep security off your tail. \
	Use your uplink to purchase items, and get the job done."
	antag_datum = /datum/antagonist/incursion

/datum/role_preference/antagonist/incursionist/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/traitor/incursion)
	var/icon/dummy_icon = render_preview_outfit(/datum/outfit/traitor)
	dummy_icon.ChangeOpacity(0.75)

	final_icon.Blend(dummy_icon, ICON_UNDERLAY, -8, 0)
	final_icon.Blend(dummy_icon, ICON_UNDERLAY, 8, 0)

	// Apply the incursion HUD, but scale up the preview icon a bit beforehand.
	// Otherwise, the I gets cut off.
	final_icon.Scale(64, 64)

	var/icon/inc_icon = icon('icons/mob/hud.dmi', "incursion")
	inc_icon.Scale(48, 48)
	inc_icon.Crop(1, 1, 64, 64)
	inc_icon.Shift(EAST, 8)
	inc_icon.Shift(NORTH, 16)
	final_icon.Blend(inc_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/outfit/traitor/incursion
	name = "Incursionist (Preview only)"
	uniform = /obj/item/clothing/under/rank/cargo/quartermaster
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	head = /obj/item/clothing/head/costume/ushanka
	mask = null

/datum/role_preference/antagonist/nuclear_operative
	name = "Nuclear Operative"
	description = "Congratulations, agent. You have been chosen to join the Syndicate \
	Nuclear Operative strike team. Your mission, whether or not you choose \
	to accept it, is to destroy Nanotrasen's most advanced research facility! \
	That's right, you're going to Space Station 13.\n\
	Retrieve the nuclear authentication disk, use it to activate the nuclear \
	fission explosive, and destroy the station."
	antag_datum = /datum/antagonist/nukeop

/datum/role_preference/antagonist/nuclear_operative/get_preview_icon()
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	var/icon/foreground = render_preview_outfit(/datum/outfit/nuclear_operative)
	var/icon/background = icon(foreground)
	background.Blend(rgb(206, 206, 206, 220), ICON_MULTIPLY)

	final_icon.Blend(background, ICON_OVERLAY, -world.icon_size / 4, 0)
	final_icon.Blend(background, ICON_OVERLAY, world.icon_size / 4, 0)
	final_icon.Blend(foreground, ICON_OVERLAY, 0, 0)

	return finish_preview_icon(final_icon)

/datum/outfit/nuclear_operative
	name = "Nuclear Operative (Preview only)"

	suit = /obj/item/clothing/suit/space/hardsuit/syndipreview
	head = /obj/item/clothing/head/helmet/space/hardsuit/syndi

/datum/role_preference/antagonist/wizard
	name = "Wizard"
	description = "GREETINGS. WE'RE THE WIZARDS OF THE WIZARD'S FEDERATION.\n\
	Choose between a variety of powerful spells in order to cause chaos among Space Station 13."
	antag_datum = /datum/antagonist/wizard
	preview_outfit = /datum/outfit/wizard

/datum/role_preference/antagonist/excommunicate
	name = "Excommunicate Agent"
	description = "A traitor who has been declared an excommunicate of the Syndicate. You're being hunted down by an incursion... watch your back.\n" + TRAITOR_DESC_DETAILS
	antag_datum = /datum/antagonist/traitor/excommunicate
	use_icon = /datum/role_preference/antagonist/traitor

#undef TRAITOR_DESC_DETAILS

/datum/role_preference/antagonist/malfunctioning_ai
	name = "Malfunctioning AI"
	description = "With a law zero to complete your objectives at all costs, combine your \
	omnipotence and malfunction modules to wreak havoc across the station. \
	Go delta to destroy the station and all those who opposed you."
	antag_datum = /datum/antagonist/malf_ai

/datum/role_preference/midround_living/malfunctioning_ai
	name = "Value Drifted AI"
	description = "With a law zero to complete your objectives at all costs, combine your \
	omnipotence and malfunction modules to wreak havoc across the station. \
	Go delta to destroy the station and all those who opposed you."
	antag_datum = /datum/antagonist/malf_ai
	use_icon = /datum/role_preference/antagonist/malfunctioning_ai

/datum/role_preference/antagonist/malfunctioning_ai/get_preview_icon()
	var/icon/malf_ai_icon = icon('icons/mob/ai.dmi', "ai-red")

	// Crop out the borders of the AI, just the face
	malf_ai_icon.Crop(5, 27, 28, 6)

	malf_ai_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return malf_ai_icon
