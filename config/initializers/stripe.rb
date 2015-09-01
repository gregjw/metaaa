Rails.configuration.stripe = {
	:publishable_key => "pk_live_x1IT6fBOSyZylizTTj2wIVZe",
	:secret_key 	 => "sk_live_2MUQgDAqSU7kSo4aCbXcTmgc"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]