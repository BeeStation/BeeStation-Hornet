/datum/team/holoparasites
	name = "holoparasites"
	member_name = "holoparasite"
	var/datum/holoparasite_holder/holder
	var/blackbox_recorded = FALSE

/datum/team/holoparasites/New(starting_members, datum/holoparasite_holder/holder)
	. = ..()
	if(!holder)
		CRASH("Attempted to create holoparasite team without holder")
	if(holder.team)
		CRASH("Attempted to create duplicate holoparasite team for the holder of [key_name(holder.owner)]")
	src.holder = holder
	holder.team = src
	objectives += new /datum/objective/holoparasite(holder.owner, src)

/datum/team/holoparasites/get_team_name()
	return "Holoparasites of [holder.owner.name]"

/datum/team/holoparasites/roundend_report()
	// bleh I don't like doing this here, but there's no other place to do it without adding new signals, and I've added WAY too many signals already...
	record_to_blackbox()

	var/list/parts = list()

	parts += "<span class='header'>[holder.owner.name] had the following holoparasite[is_solo() ? "" : "s"]:</span>"
	parts += print_all_holoparas()

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/holoparasites/proc/print_holopara(datum/mind/holopara_mind)
	var/mob/living/simple_animal/hostile/holoparasite/holoparasite = holopara_mind?.current
	if(!istype(holoparasite))
		return
	var/list/parts = list()
	parts += "<b>[holopara_mind.key]</b> was <b>[holoparasite.color_name]</b>, the <b>[holoparasite.theme.name]</b>"
	parts += generate_stat_chart(holoparasite)
	return parts.Join("<br>")

/datum/team/holoparasites/proc/print_all_holoparas()
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/mind in members)
		parts += "<li>[print_holopara(mind)]</li>"
	parts += "</ul>"
	return parts.Join()

/datum/team/holoparasites/proc/record_to_blackbox()
	if(blackbox_recorded)
		return
	blackbox_recorded = TRUE
	var/list/info = list(
		"stat" = "dead",
		"crit" = FALSE,
		"escaped" = holder.owner.force_escaped,
		"objectives" = list(
			"greentext" = TRUE,
			"total" = 0,
			"complete" = 0
		)
	)
	var/list/datum/objective/owner_objectives = holder.owner.get_all_antag_objectives()
	if(length(owner_objectives))
		for(var/datum/objective/objective in owner_objectives)
			info["objectives"]["total"]++
			if(objective.check_completion())
				info["objectives"]["complete"]++
			else
				info["objectives"]["greentext"] = FALSE
	if(!QDELETED(holder.owner.current))
		var/mob/living/summoner = holder.owner.current
		var/turf/summoner_turf = get_turf(summoner)
		info["escaped"] = holder.owner.force_escaped || summoner_turf.onCentCom() || summoner_turf.onSyndieBase()
		if(summoner.stat != DEAD)
			info["stat"] = "alive"
			info["crit"] = summoner.InCritical()
	SSblackbox.record_feedback("associative", "holoparasite_user_roundend_stat", 1, info)
	SSblackbox.record_feedback("tally", "holoparasites_per_summoner", 1, length(members))

/datum/team/holoparasites/proc/generate_stat_chart(mob/living/simple_animal/hostile/holoparasite/holoparasite)
	var/datum/holoparasite_stats/stats = holoparasite.stats
	var/id = ckey(REF(holoparasite))
	var/list/side_stats = list("<b>Weapon</b>: [stats.weapon.name]")
	if(stats.ability)
		side_stats += "<b>Special Ability</b>: [stats.ability.name]"
	for(var/datum/holoparasite_ability/lesser/ability as() in stats.lesser_abilities)
		side_stats += "<b>Lesser Ability</b>: [ability.name]"
	return {"
	<div class="holopara-info-container">
		<div class="holopara-info-item">
			<svg id="holopara-radar-[id]" width="220" height="220"></svg>
		</div>
		<div class="holopara-info-item">
			[side_stats.Join("<br>")]
		</div>
	</div>
	<script type='text/javascript'>
		document.addEventListener("DOMContentLoaded", function() {
			drawRadarChart("holopara-radar-[id]", {
				axes: \['Damage', 'Defense', 'Speed', 'Potential', 'Range'\],
				stages: \['1', '2', '3', '4', '5'\],
				values: \[[stats.damage], [stats.defense], [stats.speed], [stats.potential], [stats.range]\],
				color: "[holoparasite.accent_color]"
			});
		});
	</script>
	"}

/datum/objective/holoparasite
	name = "protect holoparasite summoner"
	explanation_text = "Protect and serve your summoner."

/datum/objective/holoparasite/New(datum/mind/summoner, datum/team/holoparasites/holopara_team)
	if(!istype(summoner))
		CRASH("Attempted to create holoparasite objective without summoner!")
	if(!istype(holopara_team))
		CRASH("Attempted to create holoparasite objective without team!")
	target = summoner
	team = holopara_team
	update_explanation_text()

/datum/objective/holoparasite/update_explanation_text()
	explanation_text = "Protect and serve [target.name], your summoner."

/datum/objective/holoparasite/check_completion()
	return considered_alive(target, enforce_human = FALSE)
