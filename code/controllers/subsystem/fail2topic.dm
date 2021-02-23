SUBSYSTEM_DEF(fail2topic)
	name = "Fail2Topic"
	init_order = INIT_ORDER_FAIL2TOPIC
	flags = SS_BACKGROUND
	runlevels = ALL

	var/list/rate_limiting = list()
	var/list/fail_counts = list()
	var/list/active_bans = list()
	var/list/currentrun = list()

	var/rate_limit
	var/max_fails
	var/rule_name
	var/enabled = FALSE

/datum/controller/subsystem/fail2topic/Initialize(timeofday)
	rate_limit = ((CONFIG_GET(number/topic_rate_limit)) SECONDS)
	max_fails = CONFIG_GET(number/topic_max_fails)
	rule_name = CONFIG_GET(string/topic_rule_name)
	enabled = CONFIG_GET(flag/topic_enabled)

	DropFirewallRule() // Clear the old bans if any still remain

	if (world.system_type == UNIX && enabled)
		enabled = FALSE
		WARNING("Fail2topic subsystem disabled. UNIX is not supported.")


	if (!enabled)
		can_fire = FALSE

	. = ..()

/datum/controller/subsystem/fail2topic/fire(resumed = 0)
	if(!resumed)
		currentrun = rate_limiting.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/ip = current_run[current_run.len]
		var/last_attempt = current_run[ip]
		current_run.len--

		// last_attempt list housekeeping
		if(world.time - last_attempt > rate_limit)
			rate_limiting -= ip
			fail_counts -= ip

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/fail2topic/Shutdown()
	DropFirewallRule()

/datum/controller/subsystem/fail2topic/proc/IsRateLimited(ip)
	var/last_attempt = rate_limiting[ip]

	if (config.fail2topic_whitelisted_ips[ip])
		return FALSE

	if (active_bans[ip])
		return TRUE

	rate_limiting[ip] = world.time

	if (isnull(last_attempt))
		return FALSE

	if (world.time - last_attempt > rate_limit)
		fail_counts -= ip
		return FALSE
	else
		var/failures = fail_counts[ip]

		if (isnull(failures))
			fail_counts[ip] = 1
			return TRUE
		else if (failures > max_fails)
			BanFromFirewall(ip)
			return TRUE
		else
			fail_counts[ip] = failures + 1
			return TRUE

/datum/controller/subsystem/fail2topic/proc/BanFromFirewall(ip)
	if (!enabled)
		return

	active_bans[ip] = world.time
	fail_counts -= ip
	rate_limiting -= ip

	. = shell("netsh advfirewall firewall add rule name=\"[rule_name]\" dir=in interface=any action=block remoteip=[ip]")

	if (.)
		WARNING("Fail2topic failed to ban [ip]. Exit code: [.].")
	else if (isnull(.))
		WARNING("Fail2topic failed to invoke ban script.")
	else
		log_world("Fail2topic banned [ip].")

/datum/controller/subsystem/fail2topic/proc/DropFirewallRule()
	if (!enabled)
		return

	active_bans = list()

	. = shell("netsh advfirewall firewall delete rule name=\"[rule_name]\"")

	if (.)
		WARNING("Fail2topic failed to drop firewall rule. Exit code: [.].")
	else if (isnull(.))
		WARNING("Fail2topic failed to invoke ban script.")
	else
		log_world("Fail2topic firewall rule dropped.")
