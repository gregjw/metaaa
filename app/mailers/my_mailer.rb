class MyMailer < Devise::Mailer
 
  def confirmation_instructions(record, token, opts={})
    # code to be added here later
  end
  
  def reset_password_instructions(record, token, opts={})
    options = {
      :subject => "Password Reset",
      :template => "forgot-password",
      :email => record.email,
      :global_merge_vars => [
        {name: "password_reset_link", content: "http://localhost:3000/users/password/edit?reset_password_token=#{token}"}
      ]
    }
    mandrill_send options  
  end
  
  def unlock_instructions(record, token, opts={})
    # code to be added here later
  end
  
  def mandrill_send(opts={})
    message = { 
      :subject=> "#{opts[:subject]}", 
      :from_name=> "Meta",
      :from_email=>"greg@metaaa.org",
      :to=>
            [{"name"=>"Some User",
                "email"=>"#{opts[:email]}",
                "type"=>"to"}],
      :global_merge_vars => opts[:global_merge_vars]
      }
    sending = MANDRILL.messages.send_template opts[:template], [], message
    rescue Mandrill::Error => e
      Rails.logger.debug("#{e.class}: #{e.message}")
      raise
  end
  
end