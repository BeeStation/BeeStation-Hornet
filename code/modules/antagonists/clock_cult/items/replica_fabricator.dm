#define BRASS_POWER_COST 10

/obj/item/clockwork/replica_fabricator
	name = "replica fabricator"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "replica_fabricator"
	desc = "A strange, brass device with many twisting cogs and vents."
	clockwork_desc = span_brass("A device used to rapidly fabricate brass.")

/obj/item/clockwork/replica_fabricator/examine(mob/user)
	. = ..()
	if(IS_SERVANT_OF_RATVAR(user))
		. += span_brass("Use on brass to convert it into power.")
		. += span_brass("Use on other materials to convert them into brass.")
		. += span_brass("Use on an empty floor to fabricate brass for 10W/sheet")
		. += span_brass("Use on damaged clockwork structures to repair them.")

/obj/item/clockwork/replica_fabricator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_SERVANT_OF_RATVAR(user))
		return
	if(istype(target, /obj/item/stack/sheet/brass/cyborg))	//nooooO!!!! you can't just suck up your cyborg brass!!! nooooo!!!!!!
		return
	if(istype(target, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/B = target
		qdel(B)
		GLOB.clockcult_power += B.amount * BRASS_POWER_COST
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_nzcrentr("You convert [B.amount] brass into [B.amount * BRASS_POWER_COST] watts of power."))
	else if(istype(target, /obj/item/stack/sheet))
		var/obj/item/stack/S = target
		var/obj/item/stack/sheet/brass/B = new(get_turf(S))
		B.amount = FLOOR(S.amount * 0.5, 1)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_nzcrentr("You convert [S.amount] [S] into [S.amount] brass."))
		qdel(target)
	else if(isopenturf(target))
		fabricate_sheets(target, user)
	else if(istype(target, /obj/structure/destructible/clockwork))
		var/obj/structure/destructible/clockwork/C = target
		if(!C.can_be_repaired)
			to_chat(user, span_nzcrentr("You cannot repair [C]!"))
			return
		if(GLOB.clockcult_power < 200)
			to_chat(user, span_nzcrentr("You need [200 - GLOB.clockcult_power]W more to repair the [C]..."))
			return
		if(C.max_integrity == C.get_integrity())
			to_chat(user, span_nzcrentr("\The [C] is already repaired!"))
			return
		to_chat(user, span_nzcrentr("You begin repairing [C]..."))
		if(do_after(user, 60, target=target))
			if(C.max_integrity == C.get_integrity())
				to_chat(user, span_nzcrentr("\The [C] is already repaired!"))
				return
			if(GLOB.clockcult_power < 200)
				to_chat(user, span_nzcrentr("You need [200 - GLOB.clockcult_power]W more to repair the [C]..."))
				return
			GLOB.clockcult_power -= 200
			to_chat(user, span_nzcrentr("You repair some of the damage on \the [C]."))
			C.repair_damage(clamp(C.get_integrity() + 15, 0, C.max_integrity))
		else
			to_chat(user, span_nzcrentr("You fail to repair the damage of \the [C]..."))

/obj/item/clockwork/replica_fabricator/proc/fabricate_sheets(turf/target, mob/user)
	var/sheets = FLOOR(clamp(GLOB.clockcult_power / BRASS_POWER_COST, 0, 50), 1)
	if(sheets == 0)
		return
	GLOB.clockcult_power -= sheets * BRASS_POWER_COST
	new /obj/item/stack/sheet/brass(target, sheets)
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, span_brass("You fabricate [sheets] brass."))

#undef BRASS_POWER_COST
