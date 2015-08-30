@dropbox_key = "xwls7wjf63szb91"
@dropbox_secret = "eibftqnakh7347h"
@dropbox_callback_url = "http://localhost:3000/tasks/5"

Dropbox::API::Config.app_key    = @dropbox_key
Dropbox::API::Config.app_secret = @dropbox_secret
Dropbox::API::Config.mode       = "sandbox"