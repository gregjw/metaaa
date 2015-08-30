Rails.configuration.stripe = {
	:publishable_key => "pk_test_Req3j4Bb7Qc6CqURLndvxC9p",
	:secret_key 	 => "sk_test_uomDZVjZAHztUpgl3ZhtnzIe"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]