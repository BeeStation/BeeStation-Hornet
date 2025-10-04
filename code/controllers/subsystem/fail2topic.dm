SUBSYSTEM_DEF(fail2topic)
	name = "Fail2Topic"
	init_stage = INITSTAGE_FIRST
	flags = SS_BACKGROUND
	runlevels = ALL

	var/list/rate_limiting = list()
	var/list/fail_counts = list()
	var/list/active_bans = list()
	var/list/currentrun = list()

	var/rate_limit
	var/max_fails
	var/enabled = FALSE

/datum/controller/subsystem/fail2topic/Initialize()
	rate_limit = ((CONFIG_GET(number/topic_rate_limit)) SECONDS)
	max_fails = CONFIG_GET(number/topic_max_fails)
	enabled = CONFIG_GET(flag/topic_enabled)

	DropFirewallRule() // Clear the old bans if any still remain

	if (world.system_type == UNIX && enabled)
		enabled = FALSE
		WARNING("Fail2topic subsystem disabled. UNIX is not supported.")


	if (!enabled)
		can_fire = FALSE

	return SS_INIT_SUCCESS

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
	if(!enabled)
		return FALSE

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
	var/static/regex/R = regex(@"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") // Anything that interacts with a shell should be parsed. Prevents direct call input tampering
	R.Find(ip)
	ip = R.match
	if(length(ip) > 15 || length(ip) < 8 )
		return FALSE

	active_bans[ip] = world.time
	fail_counts -= ip
	rate_limiting -= ip

	. = shell("netsh advfirewall firewall add rule name=\"[CONFIG_GET(string/topic_rule_name)]\" dir=in interface=any action=block remoteip=[ip]")

	if (.)
		log_topic("ERROR: Fail2topic failed to ban [ip]. Exit code: [.].")
	else if (isnull(.))
		log_topic("ERROR: Fail2topic failed to invoke ban script.")
	else
		log_topic("Fail2topic banned [ip].")

/datum/controller/subsystem/fail2topic/proc/DropFirewallRule()
	if (!enabled)
		return

	active_bans = list()

	. = shell("netsh advfirewall firewall delete rule name=\"[CONFIG_GET(string/topic_rule_name)]\"")

	if (.)
		log_topic("ERROR: Fail2topic failed to drop firewall rule. Exit code: [.].")
	else if (isnull(.))
		log_topic("ERROR: Fail2topic failed to invoke ban script.")
	else
		log_topic("Fail2topic firewall rule dropped.")
