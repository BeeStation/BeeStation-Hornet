#define EMP_RANDOMISE_TIME 300

/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/on_activate(mob/user, atom/target)
	// Damn our lack of abstract interfeces
	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		var/obj/item/clothing/head/chameleon/drone/X = target
		X.chameleon_action.random_look(owner)
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		var/obj/item/clothing/mask/chameleon/drone/Z = target
		Z.chameleon_action.random_look(owner)
	return TRUE

/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New(master)
	..()

	if (istype(master, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(master, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/on_activate(mob/user, atom/target)
	// No point making the code more complicated if no non-drone
	// is ever going to use one of these

	var/mob/living/simple_animal/drone/D

	if(istype(owner, /mob/living/simple_animal/drone))
		D = owner
	else
		return

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone()
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone()
	else
		to_chat(owner, span_warning("You shouldn't be able to toggle a camogear helmetmask if you're not wearing it"))
	if(new_headgear)
		// Force drop the item in the headslot, even though
		// it's has TRAIT_NODROP
		D.dropItemToGround(target, TRUE)
		qdel(old_headgear)
		// where is `ITEM_SLOT_HEAD` defined? WHO KNOWS
		D.equip_to_slot(new_headgear, ITEM_SLOT_HEAD)
	return TRUE

/datum/action/chameleon_outfit
	name = "Select Chameleon Outfit"
	button_icon_state = "chameleon_outfit"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED
	var/list/outfit_options //By default, this list is shared between all instances. It is not static because if it were, subtypes would not be able to have their own. If you ever want to edit it, copy it first.

/datum/action/chameleon_outfit/New()
	..()
	initialize_outfits()

/datum/action/chameleon_outfit/proc/initialize_outfits()
	var/static/list/standard_outfit_options
	if(!standard_outfit_options)
		standard_outfit_options = list()
		for(var/path in subtypesof(/datum/outfit/job))
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				standard_outfit_options[initial(O.name)] = path
		sortTim(standard_outfit_options, GLOBAL_PROC_REF(cmp_text_asc))
	outfit_options = standard_outfit_options

/datum/action/chameleon_outfit/on_activate(mob/user, atom/target)
	return select_outfit(user)

/datum/action/chameleon_outfit/proc/select_outfit(mob/user)
	if(!user || !is_available())
		return FALSE
	var/selected = input("Select outfit to change into", "Chameleon Outfit") as null|anything in outfit_options
	if(!is_available() || QDELETED(src) || QDELETED(user))
		return FALSE
	var/outfit_type = outfit_options[selected]
	if(!outfit_type)
		return FALSE
	var/datum/outfit/O = new outfit_type()
	var/list/outfit_types = O.get_chameleon_disguise_info()

	var/obj/item/card/id/syndicate/chamel_card // this is awful but this hardcoding is better than adding `obj/proc/get_chameleon_variable()` for every chalemon item
	for(var/datum/action/item_action/chameleon/change/A in user.chameleon_item_actions)
		if(istype(UNLINT(A.master), /obj/item/modular_computer))
			var/obj/item/modular_computer/comp = UNLINT(A.master)
			if(istype(comp.GetID(), /obj/item/card/id/syndicate))
				chamel_card = comp.GetID()

		var/done = FALSE
		for(var/T in outfit_types)
			for(var/name in A.chameleon_list)
				if(A.chameleon_list[name] == T)
					A.update_look(user, T)
					outfit_types -= T
					done = TRUE
					break
			if(done)
				break

	if(chamel_card) // changes chameleon card inside of PDA
		var/datum/action/item_action/chameleon/change/A = chamel_card.chameleon_action
		var/done = FALSE
		for(var/T in outfit_types)
			for(var/name in A.chameleon_list)
				if(A.chameleon_list[name] == T)
					A.update_look(user, T)
					outfit_types -= T
					done = TRUE
					break
			if(done)
				break

	//hardsuit helmets/suit hoods
	if(O.toggle_helmet && (ispath(O.suit, /obj/item/clothing/suit/space/hardsuit) || ispath(O.suit, /obj/item/clothing/suit/hooded)) && ishuman(user))
		var/mob/living/carbon/human/H = user
		//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
		if(istype(H.wear_suit, /obj/item/clothing/suit/chameleon) && istype(H.head, /obj/item/clothing/head/chameleon))
			var/helmet_type
			if(ispath(O.suit, /obj/item/clothing/suit/space/hardsuit))
				var/obj/item/clothing/suit/space/hardsuit/hardsuit = O.suit
				helmet_type = initial(hardsuit.helmettype)
			else
				var/obj/item/clothing/suit/hooded/hooded = O.suit
				helmet_type = initial(hooded.hoodtype)

			if(helmet_type)
				var/obj/item/clothing/head/chameleon/hat = H.head
				hat.chameleon_action.update_look(user, helmet_type)
	qdel(O)
	return TRUE


/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	var/list/chameleon_blacklist = list() //This is a typecache
	var/list/chameleon_list = list()
	var/chameleon_type = null
	var/chameleon_name = "Item"

	var/emp_timer

	var/hidden = FALSE

/datum/action/item_action/chameleon/change/Grant(mob/M)
	if(hidden)
		Remove(M)
		return
	if(M && (owner != M))
		if(!M.chameleon_item_actions)
			M.chameleon_item_actions = list(src)
			var/datum/action/chameleon_outfit/O = new /datum/action/chameleon_outfit()
			O.Grant(M)
		else
			M.chameleon_item_actions |= src
	..()

/datum/action/item_action/chameleon/change/Remove(mob/M)
	if(M && (M == owner))
		LAZYREMOVE(M.chameleon_item_actions, src)
		if(!LAZYLEN(M.chameleon_item_actions))
			var/datum/action/chameleon_outfit/O = locate(/datum/action/chameleon_outfit) in M.actions
			qdel(O)
	..()

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	chameleon_blacklist |= typecacheof(master.type)
	for(var/V in typesof(chameleon_type))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if(chameleon_blacklist[V] || (initial(I.item_flags) & ABSTRACT) || !initial(I.icon_state))
				continue
			var/chameleon_item_name = "[initial(I.name)] ([initial(I.icon_state)])"
			chameleon_list[chameleon_item_name] = I


/datum/action/item_action/chameleon/change/proc/select_look(mob/user)
	var/obj/item/picked_item
	var/picked_name
	picked_name = input("Select [chameleon_name] to change into", "Chameleon [chameleon_name]", picked_name) as null|anything in sort_list(chameleon_list, GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!picked_name)
		return
	picked_item = chameleon_list[picked_name]
	if(!picked_item)
		return
	update_look(user, picked_item)

/datum/action/item_action/chameleon/change/proc/random_look(mob/user)
	var/picked_name = pick(chameleon_list)
	var/obj/item/picked_item = chameleon_list[picked_name]
	// If a user is provided, then this item is in use, and we
	// need to update our icons and stuff

	if(user)
		update_look(user, picked_item, emp=TRUE)

	// Otherwise, it's likely a random initialisation, so we
	// don't have to worry

	else
		update_item(picked_item, emp=TRUE)

/datum/action/item_action/chameleon/change/proc/update_look(mob/user, obj/item/picked_item, emp=FALSE)
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return
		update_item(picked_item, emp=emp, item_holder=user)

		var/obj/item/thing = master
		thing.update_slot_icon()
	update_buttons()

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item, emp=FALSE, mob/item_holder=null)
	var/keepname = FALSE
	if(isitem(master))
		var/obj/item/clothing/I = master
		I.worn_icon = initial(picked_item.worn_icon)
		I.lefthand_file = initial(picked_item.lefthand_file)
		I.righthand_file = initial(picked_item.righthand_file)
		if(initial(picked_item.greyscale_colors))
			I.greyscale_colors = initial(picked_item.greyscale_colors)
			if(initial(picked_item.greyscale_config_worn))
				I.worn_icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_worn), initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_inhand_left))
				I.lefthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_left), initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_inhand_right))
				I.righthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_right), initial(picked_item.greyscale_colors))
		I.worn_icon_state = initial(picked_item.worn_icon_state)
		I.inhand_icon_state = initial(picked_item.inhand_icon_state)
		if(!keepname)
			I.name = initial(picked_item.name)
		I.desc = initial(picked_item.desc)
		I.icon_state = initial(picked_item.icon_state)
		if(isclothing(I) && ispath(picked_item, /obj/item/clothing))
			var/obj/item/clothing/CL = I
			var/obj/item/clothing/PCL = picked_item
			CL.flags_cover = initial(PCL.flags_cover)
		if(initial(picked_item.greyscale_config) && initial(picked_item.greyscale_colors))
			I.icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config), initial(picked_item.greyscale_colors))
		else
			I.icon = initial(picked_item.icon)
		if(isidcard(I) && ispath(picked_item, /obj/item/card/id))
			var/obj/item/card/id/ID = master
			var/obj/item/card/id/ID_from = picked_item
			ID.hud_state = initial(ID_from.hud_state)
			if(!emp)
				if(!ispath(picked_item, /obj/item/card/id/departmental_budget) && !ispath(picked_item, /obj/item/card/id/pass))
					keepname = TRUE
					var/mob/M = usr
					if(initial(ID_from.assignment))
						var/popup_input = alert(M, "Do you want to reforge the job title as the default one of the chosen chameleon card?", "Agent ID job name", "Yes", "No (Keep the current job title)")
						if(popup_input == "Yes")
							ID.assignment = initial(ID_from.assignment)
							ID.update_label()
			else
				keepname = TRUE
				ID.assignment = initial(ID_from.assignment) || "Unknown"
				ID.update_label()

			// we're going to find a PDA that this ID card is inserted into, then force-update PDA
			var/atom/current_holder = master
			if(istype(current_holder, /obj/item/computer_hardware/card_slot))
				current_holder = current_holder.loc
				if(istype(current_holder, /obj/item/modular_computer))
					var/obj/item/modular_computer/comp = current_holder
					if(comp)
						comp.saved_identification = ID.registered_name
						comp.saved_job = ID.assignment
						comp.update_id_display()

			update_mob_hud(item_holder)
		if(istype(master, /obj/item/modular_computer))
			var/obj/item/modular_computer/comp = master
			var/obj/item/card/id/id = comp.GetID()
			if(id)
				comp.saved_identification = id.registered_name
				comp.saved_job = id.assignment
				comp.update_id_display()
			keepname = TRUE // do not change PDA name unnecesarily
			update_mob_hud(item_holder)
		REMOVE_TRAIT(I, TRAIT_VALUE_MIMIC_PATH, FROM_CHAMELEON)
		ADD_VALUE_TRAIT(I, TRAIT_VALUE_MIMIC_PATH, FROM_CHAMELEON, initial(picked_item.type), PRIORITY_CHAMELEON_MIMIC)

/datum/action/item_action/chameleon/change/proc/update_mob_hud(atom/card_holder)
	// we're going to find a human, and store human ref to 'card_holder' by checking loc multiple time.
	if(!ishuman(card_holder))
		if(!card_holder)
			card_holder = master
		if(istype(card_holder, /obj/item/storage/wallet))
			card_holder = card_holder.loc // this should be human
		if(istype(card_holder, /obj/item/computer_hardware/card_slot))
			card_holder = card_holder.loc
			if(istype(card_holder, /obj/item/modular_computer/tablet))
				card_holder = card_holder.loc // tihs should be human
	if(!ishuman(card_holder))
		return
	var/mob/living/carbon/human/card_holding_human = card_holder
	card_holding_human.sec_hud_set_ID()

/datum/action/item_action/chameleon/change/on_activate(mob/user, atom/target)
	select_look(owner)
	return 1

/datum/action/item_action/chameleon/change/proc/emp_randomise(amount = EMP_RANDOMISE_TIME)
	START_PROCESSING(SSprocessing, src)
	random_look(owner)

	var/new_value = world.time + amount
	if(new_value > emp_timer)
		emp_timer = new_value

/datum/action/item_action/chameleon/change/process()
	if(world.time > emp_timer)
		return PROCESS_KILL
	random_look(owner)

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor_type = /datum/armor/under_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/under_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/under/chameleon/envirosuit
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy. It has a small dial on the wrist."
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	resistance_flags = FIRE_PROOF
	envirosealed = TRUE
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/chameleon/ratvar
	name = "ratvarian engineer's jumpsuit"
	desc = "A tough jumpsuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	inhand_icon_state = "engi_suit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/chameleon/envirosuit/ratvar
	name = "ratvarian engineer's envirosuit"
	desc = "A tough envirosuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	inhand_icon_state = "engineer_envirosuit"

/obj/item/clothing/under/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(
		/obj/item/clothing/under,
		/obj/item/clothing/under/color,
		/obj/item/clothing/under/rank,
		/obj/item/clothing/under/changeling,
	), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/under/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/under/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/under/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon jumpsuit ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon jumpsuit ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor_type = /datum/armor/suit_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/suit_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/suit/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.chameleon_blacklist = typecacheof(list(
		/obj/item/clothing/suit/armor/abductor,
		/obj/item/clothing/suit/changeling,
	), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/suit/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/suit/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/suit/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon suit ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon suit ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	inhand_icon_state = "meson"
	resistance_flags = NONE
	armor_type = /datum/armor/glasses_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/glasses_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/glasses/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/glasses/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/glasses/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon glasses ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon glasses ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/glasses/chameleon/flashproof
	name = "welding goggles"
	desc = "Protects the eyes from welders; approved by the mad scientist association."
	icon_state = "welding-g"
	inhand_icon_state = "welding-g"
	flash_protect = 3

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	worn_icon_state = "ygloves"

	resistance_flags = NONE
	armor_type = /datum/armor/gloves_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/gloves_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/gloves/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.chameleon_blacklist = typecacheof(list(
		/obj/item/clothing/gloves,
		/obj/item/clothing/gloves/color,
		/obj/item/clothing/gloves/changeling,
	), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/gloves/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/gloves/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/gloves/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon gloves ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon gloves ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/gloves/chameleon/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "cgloves"
	inhand_icon_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	armor_type = /datum/armor/chameleon_combat

/datum/armor/chameleon_combat
	melee = 10
	bullet = 10
	laser = 10
	bio = 50
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	clothing_flags = SNUG_FIT
	icon_state = "greysoft"
	resistance_flags = NONE
	armor_type = /datum/armor/head_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/head_chameleon
	melee = 5
	bullet = 5
	laser = 5
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/head/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/head/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/head/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/head/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon hat ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon hat ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/head/chameleon/envirohelm
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	inhand_icon_state = "mime_envirohelm"
	resistance_flags = FIRE_PROOF
	strip_delay = 80
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	bang_protect = 1
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/chameleon/envirohelm/ratvar
	name = "ratvarian engineer's envirosuit helmet"
	desc = "A tough envirohelm woven from alloy threads. It can take on the appearance of other headgear."
	//icon_state = "engineer_envirohelm"
	inhand_icon_state = "engineer_envirohelm"
	flash_protect = FLASH_PROTECTION_FLASH

/obj/item/clothing/head/chameleon/drone
	// The camohat, I mean, holographic hat projection, is part of the
	// drone itself.
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/none
	// which means it offers no protection, it's just air and light
	actions_types = list(
		/datum/action/item_action/chameleon/drone/togglehatmask,
		/datum/action/item_action/chameleon/drone/randomise
	)

/obj/item/clothing/head/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()

/datum/action/item_action/chameleon/tongue_change
	name = "Tongue Change"
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "tonguebone"
	var/static/list/tongue_list

/datum/action/item_action/chameleon/tongue_change/proc/generate_tongue_list()
	var/obj/item/found_item
	var/tongue_name
	var/static/list/predefined_tongues = typesof(/obj/item/organ/tongue)
	var/list/temporary_list = list()
	tongue_list = list()
	for(var/found_var in predefined_tongues)
		found_item = found_var
		if((initial(found_item.item_flags) & ABSTRACT) || !initial(found_item.icon_state))
			continue
		tongue_name = "[initial(found_item.name)] ([initial(found_item.icon_state)])"
		temporary_list[tongue_name] = found_item
	tongue_list = sort_list(temporary_list)

/datum/action/item_action/chameleon/tongue_change/on_activate(mob/user, atom/target)
	if(!isitem(target))
		return FALSE
	var/obj/item/clothing/mask/target_mask = target
	var/obj/item/organ/tongue/picked_tongue
	var/picked_name
	picked_name = tgui_input_list(owner,"select tongue to change into", "Chameleon tongue selection", tongue_list)
	if(!picked_name)
		return FALSE
	picked_tongue = tongue_list[picked_name]
	if(!picked_tongue)
		target_mask.chosen_tongue = null
		return FALSE
	target_mask.chosen_tongue = picked_tongue
	return TRUE

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	inhand_icon_state = "gas_alt"
	resistance_flags = NONE
	armor_type = /datum/armor/mask_chameleon
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	gas_transfer_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH

	voice_change = TRUE

	var/datum/action/item_action/chameleon/change/chameleon_action
	var/datum/action/item_action/chameleon/tongue_change/tongue_action

/datum/armor/mask_chameleon
	melee = 5
	bullet = 5
	laser = 5
	bio = 100
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/mask/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)
	tongue_action = new(src)
	if(!tongue_action.tongue_list)
		tongue_action.generate_tongue_list()

/obj/item/clothing/mask/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/mask/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	if(!chameleon_action.hidden)
		voice_change = !voice_change
		to_chat(user, span_notice("The voice changer is now [voice_change ? "on" : "off"]!"))
	else
		return ..()

/obj/item/clothing/mask/chameleon/get_name(mob/user, default_name)
	var/mob/living/carbon/human/H = user
	if(voice_change && H.wear_id)
		var/obj/item/card/id/idcard = H.wear_id.GetID()
		if(istype(idcard) && idcard.electric)
			return idcard.registered_name
	return default_name

/obj/item/clothing/mask/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			actions += tongue_action
			tongue_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon mask ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon mask ([name]) with [W]")
			tongue_action.Remove(user)
			return
	. = ..()

/obj/item/clothing/mask/chameleon/drone
	//Same as the drone chameleon hat, undroppable and no protection
	armor_type = /datum/armor/chameleon_drone
	// Can drones use the voice changer part? Let's not find out.
	voice_change = FALSE
	actions_types = list(
		/datum/action/item_action/chameleon/drone/togglehatmask,
		/datum/action/item_action/chameleon/drone/randomise
	)

/datum/armor/chameleon_drone
	bleed = 10

/obj/item/clothing/mask/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, span_notice("[src] does not have a voice changer."))

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	desc = "A pair of black shoes."
	resistance_flags = NONE
	armor_type = /datum/armor/shoes_chameleon

	var/datum/action/item_action/chameleon/change/chameleon_action

/datum/armor/shoes_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 90
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/shoes/chameleon/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/shoes/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/shoes/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon shoes ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon shoes ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/shoes/chameleon/noslip
	clothing_flags = NOSLIP | NOSLIP_ALL_WALKING
	can_be_bloody = FALSE

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/backpack/chameleon
	name = "backpack"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/backpack/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/storage/backpack/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/backpack/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/backpack/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon backpack ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon backpack ([name]) with [W]")
			return
	. = ..()

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/chameleon/Initialize(mapload)
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

	atom_storage.silent = TRUE

/obj/item/storage/belt/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/belt/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon belt ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon belt ([name]) with [W]")
			return
	. = ..()

/obj/item/radio/headset/chameleon
	name = "radio headset"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/radio/headset/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/radio/headset/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/radio/headset/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/radio/headset/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon headset ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon headset ([name]) with [W]")
			return
	. = ..()

/obj/item/radio/headset/chameleon/bowman
	name = "bowman headset"
	icon_state = "syndie_headset"
	inhand_icon_state = "syndie_headset"
	bang_protect = 3

/obj/item/modular_computer/tablet/pda/preset/chameleon
	name = "tablet"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/modular_computer/tablet/pda/preset/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/modular_computer/tablet/pda
	chameleon_action.chameleon_name = "tablet"
	chameleon_action.chameleon_blacklist = typecacheof(list(
		/obj/item/modular_computer/tablet/pda/preset/heads,
	), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/modular_computer/tablet/pda/preset/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/modular_computer/tablet/pda/preset/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/modular_computer/tablet/pda/preset/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon PDA ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon PDA ([name]) with [W]")
			return
	. = ..()

/obj/item/stamp/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/stamp/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/stamp
	chameleon_action.chameleon_name = "Stamp"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/stamp/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/stamp/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon stamp ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon stamp ([name]) with [W]")
			return
	. = ..()

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "blacktie"
	resistance_flags = NONE
	armor_type = /datum/armor/neck_chameleon

/datum/armor/neck_chameleon
	fire = 50
	acid = 50

/obj/item/clothing/neck/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/neck/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/neck
	chameleon_action.chameleon_name = "Neck Accessory"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/neck/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/neck/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(chameleon_action.hidden)
			chameleon_action.hidden = FALSE
			actions += chameleon_action
			chameleon_action.Grant(user)
			log_game("[key_name(user)] has removed the disguise lock on the chameleon necktie ([name]) with [W]")
			return
		else
			chameleon_action.hidden = TRUE
			actions -= chameleon_action
			chameleon_action.Remove(user)
			log_game("[key_name(user)] has locked the disguise of the chameleon necktie ([name]) with [W]")
			return
	. = ..()

#undef EMP_RANDOMISE_TIME
