/datum/clockcult/scripture/create_structure/stargazer
	name = "Stargazer"
	desc = "Allows you to enchant your weapons and armor, however enchanting can have risky side effects."
	tip = "Make your gear more powerful by enchanting them with stargazers."
	button_icon_state = "Stargazer"
	power_cost = 300
	invokation_time = 8 SECONDS
	invokation_text = list("A light of Eng'ine shall empower my armaments!")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/stargazer
	cogs_required = 2

//Stargazer structure
/obj/structure/destructible/clockwork/gear_base/stargazer
	name = "stargazer"
	desc = "A small pedestal, glowing with a divine energy."
	clockwork_desc = "A small pedestal, glowing with a divine energy. Used to provide special powers and abilities to items."
	icon_state = "stargazer"
	anchored = TRUE
	break_message = span_warning("The stargazer collapses.")

	/// How long inbetween enchants
	var/cooldown_time = 3 MINUTES

	COOLDOWN_DECLARE(enchant_cooldown)

/obj/structure/destructible/clockwork/gear_base/stargazer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/gear_base/stargazer/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/stargazer/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user.combat_mode || !IS_SERVANT_OF_RATVAR(user))
		return ..()

	if(!anchored)
		balloon_alert(user, "not anchored!")
		return
	if(!istype(attacking_item, /obj/item) || istype(attacking_item, /obj/item/clothing) || !attacking_item.force)
		balloon_alert(user, "not enchantable!")
		return
	if(HAS_TRAIT(attacking_item, TRAIT_STARGAZED))
		balloon_alert(user, "already enchanted!")
		return
	if(!COOLDOWN_FINISHED(src, enchant_cooldown))
		balloon_alert(user, "on cooldown!")
		return

	// Enchant the item
	if(do_after(user, 6 SECONDS, target = attacking_item))
		COOLDOWN_START(src, enchant_cooldown, cooldown_time)

		balloon_alert(user, "enchanted!")
		enchant_weapon(attacking_item)
	else
		balloon_alert(user, "interrupted!")

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/enchant_weapon(obj/item/weapon)
	// Prevent re-enchanting
	ADD_TRAIT(weapon, TRAIT_STARGAZED, STARGAZER_TRAIT)

	// Add a glowy colour
	weapon.add_atom_colour(rgb(243, 227, 183), ADMIN_COLOUR_PRIORITY)

	//Pick a random effect
	var/static/list/possible_components = subtypesof(/datum/component/enchantment)
	weapon.AddComponent(pick(possible_components))
