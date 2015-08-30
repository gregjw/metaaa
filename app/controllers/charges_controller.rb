class ChargesController < ApplicationController
	def index
	end

	def create
		plan = params[:plan]
		email = params[:stripeEmail]


		if plan == "monthly"
			@amount = 499

			customer = Stripe::Customer.create(
				:email => "#{email}",
				:card => params[:stripeToken]
			)

			charge = Stripe::Charge.create(
			    :customer    => customer.id,
			    :amount      => @amount,
			    :description => 'Meta Monthly',
			    :currency    => 'gbp'
			)

			days = current_user.read_attribute(:days)
			days = days + 31
			current_user.update_attribute(:days, days) 
			redirect_to "/"
		end

		if plan == "yearly"
			@amount = 4999

			customer = Stripe::Customer.create(
				:email => "#{email}",
				:card => params[:stripeToken]
			)

			charge = Stripe::Charge.create(
			    :customer    => customer.id,
			    :amount      => @amount,
			    :description => 'Meta Yearly',
			    :currency    => 'gbp'
			)

			days = current_user.read_attribute(:days)
			days = days + 365
			current_user.update_attribute(:days, days) 
			redirect_to "/"
		end
	rescue Stripe::CardError => e
		flash[:error] = e.message
		redirect_to charges_path
	end
end
