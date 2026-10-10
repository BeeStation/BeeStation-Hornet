// Cost bases / modifiers
/// Generic techfab design
#define BILLING_COST_FAB_DESIGN 25
/// generic Techfab material
#define BILLING_COST_FAB_MATERIAL 0.025
/// Electricity in whatever unit
#define BILLING_COST_ELECTRICITY 0.0003

// Billing periods
/// Generic billing period for power
#define BILLING_PERIOD_POWER 16.1 MINUTES
/// Departments like medical / service / security that provide an ongoing service that isn't billable yet
#define BILLING_PERIOD_UPKEEP 8 MINUTES

// Max outstanding bills for gated agents
/// Techfab
#define BILLING_MAX_OUTSTANDING_FAB 5
/// Area Power Control
#define BILLING_MAX_OUTSTANDING_APC 2

/// Generic services cost
#define BILLING_UPKEEP_GENERIC 280

// Tags / bitflags for bills
#define BILL_TAG_POWER (1<<0)
#define BILL_TAG_CUSTOM (1<<1)
#define BILL_TAG_UPKEEP (1<<2)
#define BILL_TAG_FEE (1<<3)

//TODO: Move this to a signals file - Racc

#define COMSIG_BILLING_NEW_BILL "COMSIG_BILLING_NEW_BILL"
#define COMSIG_BILLING_BILL_UNDRAFT "COMSIG_BILLING_BILL_UNDRAFT"
#define COMSIG_BILLING_DEFAULT_SERVER_FOUND "COMSIG_BILLING_DEFAULT_SERVER_FOUND"

#define COMSIG_BILLING_BILL_AGENT_GENERIC "COMSIG_BILLING_BILL_AGENT_GENERIC"
