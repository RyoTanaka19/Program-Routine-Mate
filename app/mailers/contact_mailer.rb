class ContactMailer < ApplicationMailer
  def contact_mail(contact)
     @contact = contact
     mail to: ENV["TOMAIL"], subject: "お問い合せ内容" +@contact.subject
  end
end
