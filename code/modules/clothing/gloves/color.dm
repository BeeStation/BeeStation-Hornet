/obj/item/clothing/gloves/color

/obj/item/clothing/gloves/color/yellow
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	worn_icon_state = "ygloves"
	siemens_coefficient = 0
	armor_type = /datum/armor/color_yellow
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut


/datum/armor/color_yellow
	bio = 50

/obj/item/clothing/gloves/color/black/equipped(mob/user, slot)
	. = ..()
	if((slot == ITEM_SLOT_GLOVES) && (user.mind?.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "sec_black_gloves", /datum/mood_event/sec_black_gloves)

/obj/item/clothing/gloves/color/black/dropped(mob/living/carbon/user)
	..()
	if(user.gloves != src)
		return
	if(user.mind?.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "sec_black_gloves")

/obj/item/clothing/gloves/color/yellow/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		if(user.mind?.assigned_role == JOB_NAME_ASSISTANT)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "assistant_insulated_gloves", /datum/mood_event/assistant_insulated_gloves)
		if(user.mind?.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "sec_insulated_gloves", /datum/mood_event/sec_insulated_gloves)

/obj/item/clothing/gloves/color/yellow/dropped(mob/living/carbon/user)
	..()
	if(user.gloves != src)
		return
	if(user.mind?.assigned_role == JOB_NAME_ASSISTANT)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "assistant_insulated_gloves")
	if(user.mind?.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "sec_insulated_gloves")


/obj/item/clothing/gloves/color/fyellow //Cheap Chinese Crap
	desc = "These gloves are cheap knockoffs of the coveted ones - no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	worn_icon_state = "ygloves"
	siemens_coefficient = 1 //Set to a default of 1, gets overridden in Initialize()
	armor_type = /datum/armor/color_fyellow
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut


/datum/armor/color_fyellow
	bio = 25

/obj/item/clothing/gloves/color/fyellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/cut
	desc = "These gloves would protect the wearer from electric shock... if the fingers were covered."
	name = "fingerless insulated gloves"
	icon_state = "yellowcut"
	inhand_icon_state = "ygloves"
	worn_icon_state = "ygloves"
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/cut/heirloom
	desc = "The old gloves your great grandfather stole from Engineering, many moons ago. They've seen some tough times recently."

/obj/item/clothing/gloves/color/black
	desc = "These gloves are thick and fire-resistant."
	name = "black gloves"
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	worn_icon_state = "blackgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	clothing_flags = THICKMATERIAL
	cut_type = /obj/item/clothing/gloves/fingerless

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	inhand_icon_state = "orangegloves"
	worn_icon_state = "orangegloves"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	inhand_icon_state = "redgloves"
	worn_icon_state = "redgloves"

/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves provide protection against electric shock."
	siemens_coefficient = 0
	armor_type = /datum/armor/none
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	inhand_icon_state = "rainbowgloves"
	worn_icon_state = "rainbowgloves"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	inhand_icon_state = "bluegloves"
	worn_icon_state = "bluegloves"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	inhand_icon_state = "purplegloves"
	worn_icon_state = "purplegloves"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	inhand_icon_state = "greengloves"
	worn_icon_state = "greengloves"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	inhand_icon_state = "graygloves"
	worn_icon_state = "graygloves"

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	inhand_icon_state = "lightbrowngloves"
	worn_icon_state = "lightbrowngloves"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	inhand_icon_state = "browngloves"
	worn_icon_state = "browngloves"

/obj/item/clothing/gloves/color/denied
	name = "ERROR gloves"
	desc = "With these gloves you will be like the legendary Midas. Except instead of turning to gold everthing you touch will become -REDACTED-."
	icon_state = "denied"
	inhand_icon_state = "redgloves"
	worn_icon_state = "deniedgloves"

/obj/item/clothing/gloves/color/captain
	desc = "Regal blue gloves, with a nice gold trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	inhand_icon_state = "egloves"
	worn_icon_state = "egloves"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor_type = /datum/armor/color_captain
	clothing_flags = THICKMATERIAL


/datum/armor/color_captain
	bio = 90
	fire = 70
	acid = 50

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex. Transfers minor paramedic knowledge to the user via budget nanochips."
	icon_state = "latex"
	inhand_icon_state = "latex"
	worn_icon_state = "latex"
	siemens_coefficient = 0.3
	armor_type = /datum/armor/color_latex
	clothing_traits = list(TRAIT_QUICK_CARRY)
	resistance_flags = NONE

/datum/armor/color_latex
	bio = 100

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are stronger than latex. Transfers intimate paramedic knowledge into the user via nanochips."
	icon_state = "nitrile"
	inhand_icon_state = "nitrilegloves"
	worn_icon_state = "nitrilegloves"
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_FASTMED)

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	inhand_icon_state = "wgloves"
	worn_icon_state = "wgloves"

/obj/item/clothing/gloves/color/color_yellow
	name = "yellow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "white"
	inhand_icon_state = "wgloves"
	worn_icon_state = "wgloves"
	color = "#ffe14d"

/obj/item/clothing/gloves/maid
	name = "maid arm covers"
	desc = "Cylindrical looking tubes that go over your arm, weird."
	icon_state = "maid_arms"
	inhand_icon_state = "maid_arms"
	worn_icon_state = "maid_arms"
