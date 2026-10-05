/datum/component/armor_plate
	var/amount = 0
	var/maxamount = 3
	var/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide
	var/datum/armor/armor_mod = /datum/armor/armor_plate

/datum/armor/armor_plate
	melee = 10

/datum/component/armor_plate/Initialize(maxamount, obj/item/upgrade_item, datum/armor/added_armor)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(apply_plate))
	RegisterSignal(parent, COMSIG_PREQDELETED, PROC_REF(dropplates))
	if(istype(parent, /obj/vehicle/sealed/mecha/ripley))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_mech_overlays))

	if(maxamount)
		src.maxamount = maxamount
	if(upgrade_item)
		src.upgrade_item = upgrade_item
	if(added_armor)
		armor_mod = added_armor

/datum/component/armor_plate/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/typecast = upgrade_item
	var/upgrade_name = initial(typecast.name)

	if(ismecha(parent))
		if(amount)
			if(amount < maxamount)
				examine_list += span_notice("Its armor is enhanced with [amount] [upgrade_name].")
			else
				examine_list += span_notice("It's wearing a fearsome carapace entirely composed of [upgrade_name] - its pilot must be an experienced monster hunter.")
		else
			examine_list += span_notice("It has attachment points for strapping monster hide on for added protection.")
	else
		if(amount)
			examine_list += span_notice("It has been strengthened with [amount]/[maxamount] [upgrade_name].")
		else
			examine_list += span_notice("It can be strengthened with up to [maxamount] [upgrade_name].")

/datum/component/armor_plate/proc/apply_plate(atom/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if(!istype(tool, upgrade_item))
		return NONE
	if(amount >= maxamount)
		to_chat(user, span_warning("You can't improve [parent] any further!"))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/stack))
		tool.use(1)
	else
		if(length(tool.contents))
			to_chat(user, span_warning("[tool] cannot be used for armoring while there's something inside!"))
			return ITEM_INTERACT_BLOCKING
		qdel(tool)

	var/obj/owner = parent
	amount++
	owner.set_armor(owner.get_armor().add_other_armor(armor_mod))

	if(ismecha(owner))
		var/obj/vehicle/sealed/mecha/mech_owner = owner
		mech_owner.update_appearance()
		to_chat(user, span_info("You strengthen [mech_owner], improving its resistance against melee, bullet and laser damage."))
	else
		to_chat(user, span_info("You strengthen [owner], improving its resistance against melee attacks."))
	return ITEM_INTERACT_SUCCESS

/datum/component/armor_plate/proc/dropplates(datum/source, force)
	SIGNAL_HANDLER

	if(ismecha(parent)) //items didn't drop the plates before and it causes erroneous behavior for the time being with collapsible helmets
		var/obj/parent_as_obj = parent
		var/atom/drop_loc = parent_as_obj.drop_location()
		if(ispath(upgrade_item, /obj/item/stack))
			new upgrade_item(drop_loc, amount)
		else
			for(var/i in 1 to amount)
				new upgrade_item(drop_loc)

/datum/component/armor_plate/proc/apply_mech_overlays(obj/vehicle/sealed/mecha/mech, list/overlays)
	SIGNAL_HANDLER

	if(amount)
		var/overlay_string = "ripley-g"
		if(amount >= 3)
			overlay_string += "-full"
		if(!LAZYLEN(mech.occupants))
			overlay_string += "-open"
		overlays += overlay_string
