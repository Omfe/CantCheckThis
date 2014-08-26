class UserMailer < ActionMailer::Base
  default from: "omfegumo6@gmail.com"
  
    def send_forgot_password_email(user, random_password)
      @user = user
      @random_password = random_password
      mail(:to => user.email, :subject => "Forgot Password")
    end
end
