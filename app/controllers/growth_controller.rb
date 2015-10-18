class GrowthController < ApplicationController
	def show
		days = current_user.read_attribute(:days)

		if days < 1
			redirect_to edit_user_registration_path
		end

		id = params[:id]
		task_status = params[:task_status]
		twitter_status = params[:twitter_status]
		reset = params[:reset]
		clear = params[:clear]

		if id == "grow_tweet"
			if clear == "TRUE"
				current_user.update_attribute(:tweet, "")
				redirect_to "/scheduler"
			end
			if reset == "TRUE"
				current_user.update_attribute(:twitter_status, "")
				redirect_to '/growth'
			end
			if task_status == "INACTIVE"
				user = current_user
				user.update_attribute(:task_status, "INACTIVE")

				redirect_to '/growth'
			end
			if task_status == "AUTHORISED"
				@twitter_access_token = params[:twitter_key]
				@twitter_secret = params[:twitter_secret]
				hashtag = params[:hashtag]
				message = params[:message]
				user = current_user
				user.update_attribute(:task_status, "AUTHORISED")

				TaskEngine.grow_tweet(@twitter_access_token, @twitter_secret, hashtag, message, user).deliver_now

				redirect_to '/growth'
			else
				if twitter_status == "PENDING"
					token = params[:twitter_token]
					secret = params[:twitter_token_secret]
					verifier = params[:twitter_verifier]

					client = TwitterOAuth::Client.new(
					    :consumer_key => "#{@twitter_consumer_key}",
					    :consumer_secret => "#{@twitter_consumer_secret}"
					)

					access_token = client.authorize(
					  token,
					  secret,
					  :oauth_verifier => verifier
					)

					current_user.update_attribute(:twitter_key, access_token.token)
					current_user.update_attribute(:twitter_secret, access_token.secret)
					current_user.update_attribute(:twitter_status, "AUTHORISED")
					redirect_to '/growth'
				elsif twitter_status == "AUTHORISED"
					current_user.update_attribute(:twitter_status, "")

					redirect_to '/growth'
				elsif twitter_status == "NONE"
					@twitter_consumer_key = "8hEQiXtfU9vkGhNBylHICITLf"
					@twitter_consumer_secret = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"

					@twitter_callback_url = "http://metaaa.org/growth"

					client = TwitterOAuth::Client.new(
					    :consumer_key => "#{@twitter_consumer_key}",
					    :consumer_secret => "#{@twitter_consumer_secret}"
					)

					request_token = client.request_token(:oauth_callback => "#{@twitter_callback_url}")

					url = request_token.authorize_url

					session[:twitter_client] = client
					session[:twitter_token] = request_token.token
					session[:twitter_token_secret] = request_token.secret
					current_user.update_attribute(:twitter_status, "PENDING")
					redirect_to "#{url}"
				end
			end
		end
	end
end
