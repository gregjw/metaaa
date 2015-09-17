class TasksController < ApplicationController
	before_action :find_pin, only: [:show, :edit, :update, :destroy]

	def index
		@tasks = Task.all.order("created_at DESC")
	end

	def new
		@task = Task.new
	end

	def create
		@task = Task.new(task_params)

		if @task.save
			redirect_to @task, notice: "Subscribed to task."
		else
			render 'new'
		end
	end

	def edit
	end

	def follow
		id = params[:id]

		task_status = params[:task_status]

		pocket_status = params[:pocket_status]
		evernote_status = params[:evernote_status]
		instagram_status = params[:instagram_status]
		facebook_status = params[:facebook_status]
		twitter_status = params[:twitter_status]
		dropbox_status = params[:dropbox_status]
		reset = params[:reset]
		clear = params[:clear]

		if id != "schedule_tweet" && id != "analyse_tweet"
			@task = Task.find(params[:id])
		end

		Instagram.configure do |config|
			config.client_id = "0474dcb817ed481d8f8e6104b7884004"
			config.client_secret = "c9bf4b46b22f498999e0611f02eeaf4d"
		end

		if id == "analyse_tweet"
			if clear == "TRUE"
				current_user.update_attribute(:tweet, "")
				redirect_to "/scheduler"
			end
			if reset == "TRUE"
				current_user.update_attribute(:twitter_status, "")
				redirect_to root_path
			end
			if task_status == "AUTHORISED"
				@twitter_access_token = params[:twitter_key]
				@twitter_secret = params[:twitter_secret]
				user = current_user
				user.update_attribute(:task_status, "AUTHORISED")

				TaskEngine.analyse_tweet(@twitter_access_token, @twitter_secret, user).deliver_now

				redirect_to root_path
			elsif task_status == "STOP"
				@twitter_access_token = params[:twitter_key]
				@twitter_secret = params[:twitter_secret]
				user = current_user
				user.update_attribute(:task_status, "STOP")

				redirect_to root_path
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
					redirect_to root_path
				elsif twitter_status == "AUTHORISED"
					current_user.update_attribute(:twitter_status, "")

					redirect_to root_path
				elsif twitter_status == "NONE"
					@twitter_consumer_key = "8hEQiXtfU9vkGhNBylHICITLf"
					@twitter_consumer_secret = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"

					@twitter_callback_url = "http://metaaa.org/"

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

		if id == "schedule_tweet"
			if clear == "TRUE"
				current_user.update_attribute(:tweet, "")
				redirect_to "/scheduler"
			end
			if reset == "TRUE"
				current_user.update_attribute(:twitter_status, "")
				redirect_to "/scheduler"
			end
			if task_status == "AUTHORISED"
				@twitter_access_token = params[:twitter_key]
				@twitter_secret = params[:twitter_secret]
				tweet = params[:tweet]
				time = params[:date]
				gmt = params[:gmt]
				user = current_user

				TaskEngine.schedule_tweet(@twitter_access_token, @twitter_secret, tweet, time, gmt, user).deliver_now

				redirect_to '/scheduler'
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
					redirect_to root_path
				elsif twitter_status == "AUTHORISED"
					current_user.update_attribute(:twitter_status, "")

					redirect_to root_path
				elsif twitter_status == "NONE"
					@twitter_consumer_key = "8hEQiXtfU9vkGhNBylHICITLf"
					@twitter_consumer_secret = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"

					@twitter_callback_url = "http://metaaa.org/scheduler"

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

		if id == "1"
			# Weather Forecast
			city = params[:city]
			country = params[:country]
			email = params[:email]

			user = current_user
			user.follow(@task)
			TaskEngine.task1(email, city, country, @task, user).deliver_now

			redirect_to root_path, notice: "Subscribed to task. #{email}"
		elsif id == "2"
			if pocket_status == "PENDING"
				consumer_key = params[:pocket_key]
				request_code = params[:pocket_token]

				auth = HTTParty.post("https://getpocket.com/v3/oauth/authorize",
				                        body: {
				                          consumer_key: consumer_key,
				                          code: request_code
				                        }.to_json,
				                        headers: { 'Content-Type' => 'application/json' }
				                        )
				
				response = auth.body
				str1 = "access_token="
				str2 = "&"
				access_code = response[/#{str1}(.*?)#{str2}/m, 1]

				get = HTTParty.get("https://getpocket.com/v3/get",
										body: {
											consumer_key: consumer_key,
											access_token: access_code,
											state: 'all',
											sort: 'newest'
										}.to_json,
										headers: { 'Content-Type' => 'application/json' }
										)

				test = get.body
				redirect_to "http://metaaa.org/tasks/2/"
			elsif pocket_status == "AUTHORISED"
				session[:pocket_status] = ""
				redirect_to root_path
			elsif pocket_status == "NONE"
				pocket_consumer_key = "44125-e102090031e5edfb9e613f70"
				pocket_callback_url = "http://metaaa.org/tasks/2/"
				
				request = HTTParty.post("https://getpocket.com/v3/oauth/request",
										body: {
											consumer_key: pocket_consumer_key,
											redirect_uri: pocket_callback_url
										}.to_json,
										headers: { 'Content-Type' => 'application/json'}
										)

				request_code = request.body.gsub("code=",'')
				session[:pocket_status] = "PENDING"
				session[:pocket_key] = pocket_consumer_key
				session[:pocket_token] = request_code 
				redirect_to "https://getpocket.com/auth/authorize?request_token=#{request_code}&redirect_uri=#{pocket_callback_url}"
			end

			if evernote_status == "PENDING"
				@evernote_request_token = session[:evernote_token]
				
				@evernote_access_token = @evernote_request_token.get_access_token(:oauth_verifier => params[:evernote_verifier])
				
				user = current_user
				user.follow(@task)
				user.update_attribute(:evernote_key, @evernote_access_token)

				TaskEngine.task2(@evernote_access_token, @task, user).deliver_now

				session[:evernote_status] = "AUTHORISED"
				redirect_to root_path
			elsif evernote_status == "AUTHORISED"
				session[:evernote_status] = ""
				redirect_to root_path
			elsif evernote_status == "NONE"
				@evernote_consumer_key = "greg2055"
				@evernote_consumer_secret = "52b654652375c7c3"

				@evernote_callback_url = "http://metaaa.org/tasks/2/"

				@evernote_consumer = OAuth::Consumer.new(@evernote_consumer_key, @evernote_consumer_secret, {
						    :site               => "https://sandbox.evernote.com/",
						    :request_token_path => "/oauth",
						    :access_token_path  => "/oauth",
							:authorize_path     => "/OAuth.action"
							})

				@evernote_request_token = @evernote_consumer.get_request_token(:oauth_callback => @evernote_callback_url)
				url = @evernote_request_token.authorize_url(:oauth_callback => @evernote_callback_url)

				session[:evernote_status] = "PENDING"
				session[:evernote_token] = @evernote_request_token

				redirect_to "#{url}"
			end
		elsif id == "3"
			if reset == "TRUE"
				current_user.update_attribute(:twitter_status, "")
				redirect_to root_path
			end
			if task_status == "AUTHORISED"
				@twitter_access_token = params[:twitter_key]
				@twitter_secret = params[:twitter_secret]
				track = params[:track]

				user = current_user
				user.follow(@task)
				TaskEngine.task3(@twitter_access_token, @twitter_secret, track, @task, user).deliver_now

				redirect_to root_path, notice: "Subscribed to task. #{email}"
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
					redirect_to root_path
				elsif twitter_status == "AUTHORISED"
					current_user.update_attribute(:twitter_status, "")

					redirect_to root_path
				elsif twitter_status == "NONE"
					@twitter_consumer_key = "8hEQiXtfU9vkGhNBylHICITLf"
					@twitter_consumer_secret = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"

					@twitter_callback_url = "http://metaaa.org/tasks/3"

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
				end	# Schedule Tweet
			end
		elsif id == "4"
			username = params[:username]
			password = params[:password]

			user = current_user
			user.follow(@task)
			TaskEngine.task4(username, password, @task, user).deliver_now

			redirect_to root_path, notice: "Subscribed to task. #{email}"
		elsif id == "5"
			if reset == "TRUE"
				current_user.update_attribute(:dropbox_status, "")
				current_user.update_attribute(:instagram_status, "")
				redirect_to root_path
			end
			if task_status == "AUTHORISED"
				@instagram_access_token = params[:instagram_key]
				@dropbox_access_token = params[:dropbox_key]
				@dropbox_secret = params[:dropbox_secret]
				
				user = current_user
				user.follow(@task)
				TaskEngine.task5(@instagram_access_token, @dropbox_access_token, @dropbox_secret, @task, user).deliver_now

				redirect_to root_path, notice: "Subscribed to task. #{email}"
			else
				if dropbox_status == "NONE"
					@dropbox_callback_url = "http://metaaa.org/tasks/5"

					consumer = Dropbox::API::OAuth.consumer(:authorize)
					request_token = consumer.get_request_token

					session[:token] = request_token.token
					session[:token_secret] = request_token.secret
					url = request_token.authorize_url(:oauth_callback => "#{@dropbox_callback_url}")

					current_user.update_attribute(:dropbox_status, "PENDING")
					session[:dropbox_consumer] = consumer
					session[:dropbox_callback] = @dropbox_callback_url
					redirect_to "#{url}"
				elsif dropbox_status == "PENDING"
					@dropbox_callback_url = session[:dropbox_callback]
					consumer = session[:dropbox_consumer]

					hash = {oauth_token: session[:token], oauth_token_secret: session[:token_secret]}
					request_token = OAuth::RequestToken.from_hash(consumer, hash)

					@dropbox_access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

					token = @dropbox_access_token.token
    				secret = @dropbox_access_token.secret

					current_user.update_attribute(:dropbox_key, token)
					current_user.update_attribute(:dropbox_secret, secret)
					current_user.update_attribute(:dropbox_status, "AUTHORISED")
					redirect_to "#{@dropbox_callback_url}"
				elsif dropbox_status == "AUTHORISED"
					current_user.update_attribute(:dropbox_status, "")

					redirect_to root_path
				end

				if instagram_status == "PENDING"
					@instagram_callback_url = session[:instagram_callback]
					url = @instagram_callback_url
					access = Instagram.get_access_token(params[:code], :redirect_uri => @instagram_callback_url)
					@instagram_access_token = access.access_token
					
					puts "Callback: #{@instagram_callback_url}"
					puts "Request Token: #{@instagram_request_token}"
					puts "Access Token: #{@instagram_access_token}"

					current_user.update_attribute(:instagram_key, @instagram_access_token)
					current_user.update_attribute(:instagram_status, "AUTHORISED")
					redirect_to "#{url}"
				elsif instagram_status == "AUTHORISED"
					current_user.update_attribute(:instagram_status, "")

					redirect_to root_path
				elsif instagram_status == "NONE"
					@instagram_consumer_key = "0474dcb817ed481d8f8e6104b7884004"
					@instagram_consumer_secret = "c9bf4b46b22f498999e0611f02eeaf4d"

					@instagram_callback_url = "http://metaaa.org/tasks/5"

					url =  Instagram.authorize_url(:redirect_uri => @instagram_callback_url)

					current_user.update_attribute(:instagram_status, "PENDING")
					session[:instagram_callback] = @instagram_callback_url
					redirect_to "#{url}"
				end
			end
		elsif id == "6"
			email = params[:email]

			user = current_user
			user.follow(@task)
			TaskEngine.task6(email, @task, user).deliver_now

			redirect_to root_path, notice: "Subscribed to task. #{email}"
		elsif id == "7"
			username = params[:username]
			password = params[:password]

			user = current_user
			user.follow(@task)
			TaskEngine.task7(username, password, @task, user).deliver_now

			redirect_to root_path, notice: "Subscribed to task. #{email}"
		elsif id == "8"
			if reset == "TRUE"
				current_user.update_attribute(:twitter_status, "")
				current_user.update_attribute(:instagram_status, "")
				redirect_to root_path
			end
			if task_status == "AUTHORISED"
				@instagram_access_token = params[:instagram_key]
				@twitter_access_token = params[:twitter_key]
				@twitter_secret = params[:twitter_secret]

				user = current_user
				user.follow(@task)

				TaskEngine.task8(@instagram_access_token, @twitter_access_token, @twitter_secret, @task, user).deliver_now
				redirect_to root_path
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
					redirect_to root_path
				elsif twitter_status == "AUTHORISED"
					current_user.update_attribute(:twitter_status, "")

					redirect_to root_path
				elsif twitter_status == "NONE"
					@twitter_consumer_key = "8hEQiXtfU9vkGhNBylHICITLf"
					@twitter_consumer_secret = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"

					@twitter_callback_url = "http://metaaa.org/tasks/8"

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

				if instagram_status == "PENDING"
					@instagram_callback_url = session[:instagram_callback]
					access = Instagram.get_access_token(params[:code], :redirect_uri => @instagram_callback_url)
					@instagram_access_token = access.access_token
					
					puts "Callback: #{@instagram_callback_url}"
					puts "Request Token: #{@instagram_request_token}"
					puts "Access Token: #{@instagram_access_token}"

					current_user.update_attribute(:instagram_key, @instagram_access_token)
					current_user.update_attribute(:instagram_status, "AUTHORISED")
					redirect_to root_path
				elsif instagram_status == "AUTHORISED"
					current_user.update_attribute(:instagram_status, "")

					redirect_to root_path
				elsif instagram_status == "NONE"
					@instagram_consumer_key = "0474dcb817ed481d8f8e6104b7884004"
					@instagram_consumer_secret = "c9bf4b46b22f498999e0611f02eeaf4d"

					@instagram_callback_url = "http://metaaa.org/tasks/8"

					url =  Instagram.authorize_url(:redirect_uri => @instagram_callback_url)

					current_user.update_attribute(:instagram_status, "PENDING")
					session[:instagram_callback] = @instagram_callback_url
					redirect_to "#{url}"
				end
			end
		end
	end

	def unfollow
		@task = Task.find(params[:id])
		current_user.stop_following(@task)
		flash[:notice] = "Unsubscribed from Task"
		redirect_to root_path, notice: "Unsubscribed to task."
	end

	def update
		if  @task.update(task_params)
			redirect_to @task, notice: "Task was successfully updated."
		else
			render 'edit'
		end
	end

	def destroy
		@task.destroy
		redirect_to root_path
	end

	private

	def task_params
		params.require(:task).permit(:title, :description)
	end

	def find_pin
		@task = Task.find(params[:id])
	end
end
