#define STARTING_PAYCHECKS 5

#define PAYCHECK_ASSISTANT 10
#define PAYCHECK_MINIMAL 10
#define PAYCHECK_EASY 15
#define PAYCHECK_MEDIUM 40
#define PAYCHECK_HARD 70
#define PAYCHECK_COMMAND 100
#define PAYCHECK_VIP 2000
/*	Note: The current intention for crazy amount of money to VIP is that they can be a rich shitter
		  or be targeted by antags for their money - oh, my, being rich isn't always good.
		  The first buff to their money was to 2,000 credits. Nerf is fine if you think it's necessary,
		  but if you decrease their payment too much, they'll be no longer interested.
		  I recommend to nerf their gimmick spawn chance instead. */


#define PAYCHECK_WELFARE 20 //NEETbucks

#define ACCOUNT_CIV "Civilian"
#define ACCOUNT_CIV_NAME "Civil Budget"
#define ACCOUNT_ENG "Engineering"
#define ACCOUNT_ENG_NAME "Engineering Budget"
#define ACCOUNT_SCI "Science"
#define ACCOUNT_SCI_NAME "Scientific Budget"
#define ACCOUNT_MED "Medical"
#define ACCOUNT_MED_NAME "Medical Budget"
#define ACCOUNT_SRV "Service"
#define ACCOUNT_SRV_NAME "Service Budget"
#define ACCOUNT_CAR "Cargo"
#define ACCOUNT_CAR_NAME "Cargo Budget"
#define ACCOUNT_SEC "Security"
#define ACCOUNT_SEC_NAME "Defense Budget"
#define ACCOUNT_VIP "VIP"
#define ACCOUNT_VIP_NAME "Nanotrasen VIP Expense Account Budget"

#define ACCOUNT_CIV_FLAG (1<<0)
#define ACCOUNT_ENG_FLAG (1<<1)
#define ACCOUNT_SCI_FLAG (1<<2)
#define ACCOUNT_MED_FLAG (1<<3)
#define ACCOUNT_SRV_FLAG (1<<4)
#define ACCOUNT_CAR_FLAG (1<<5)
#define ACCOUNT_SEC_FLAG (1<<6)
#define ACCOUNT_COM_FLAG (1<<7) // for Commander only vender items
#define ACCOUNT_VIP_FLAG (1<<8) // for VIP only vender items

#define NO_FREEBIES "commies go home"

/// How much mail the Economy SS will create per minute, regardless of firing time.
#define MAX_MAIL_PER_MINUTE 3
/// Probability of using letters of envelope sprites on all letters.
#define FULL_CRATE_LETTER_ODDS 70
