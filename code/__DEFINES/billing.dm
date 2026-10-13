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
/// Suit sensors
#define BILLING_PERIOD_SUIT_SENSORS 5 MINUTES

// Max outstanding bills for gated agents
/// Techfab
#define BILLING_MAX_OUTSTANDING_FAB 5
/// Area Power Control
#define BILLING_MAX_OUTSTANDING_APC 2
/// Suit sensors
#define BILLING_MAX_OUTSTANDING_SENSORS 2

/// Generic services cost
#define BILLING_UPKEEP_GENERIC 125

// Tags / bitflags for bills
#define BILL_TAG_PAID (1<<0)
#define BILL_TAG_UNPAID (1<<1)

#define BILL_TAG_POWER (1<<2)
#define BILL_TAG_CUSTOM (1<<3)
#define BILL_TAG_UPKEEP (1<<4)
#define BILL_TAG_FEE (1<<5)

//TODO: Move this to a signals file - Racc

#define COMSIG_BILLING_NEW_BILL "COMSIG_BILLING_NEW_BILL"

#define COMSIG_BILLING_DEFAULT_SERVER_FOUND "COMSIG_BILLING_DEFAULT_SERVER_FOUND"

#define COMSIG_BILLING_BILL_AGENT_GENERIC "COMSIG_BILLING_BILL_AGENT_GENERIC"
#define COMSIG_BILLING_BILL_AGENT_DESIGN "COMSIG_BILLING_BILL_AGENT_DESIGN"
#define COMSIG_BILLING_BILL_AGENT_MATERIAL "COMSIG_BILLING_BILL_AGENT_MATERIAL"

#define COMSIG_BILLING_BILL_PAID "COMSIG_BILLING_BILL_PAID"
#define COMSIG_BILLING_BILL_UNDRAFT "COMSIG_BILLING_BILL_UNDRAFT"

// UI types for billing settings
/// Generic single numbers & upper / lower
#define BILLING_SETTING_TYPE_NUMBERS "BILLING_SETTING_TYPE_NUMBERS"
