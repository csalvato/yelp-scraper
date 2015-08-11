require 'mail'
require 'csv'
require 'erb'

def create_copy
  num_variants = 3

  #businesses = CSV.read("emails-test.csv", :headers => true, :encoding => 'windows-1251:utf-8') # For Debugging
  businesses = CSV.read("master_list_LA_Lasik_4+.csv", :headers => true, :encoding => 'windows-1251:utf-8') 

  businesses.each_with_index do |row, index|
    company_name = row['Company Name']
  	puts "Creating copy for: #{company_name}"
    output_filename = "./output/#{company_name.gsub(/[^A-Za-z0-9 ]/, '-')}.txt"

    variant = (index % num_variants) + 1
    
    subject_string   = File.open("templates/subject-template-#{variant}.txt"){ |f| f.read }
    text_body_string = File.open("templates/text-template-#{variant}.txt"){ |f| f.read }
    html_body_string = File.open("templates/html-template-#{variant}.txt"){ |f| f.read }

    recipient = row['Email']
    sender = 'Chris Salvato <csalvato@gmail.com>'
    # Insert variables using ERB and create string
    subject = ERB.new(subject_string).result(binding)
    text_body = ERB.new(text_body_string).result(binding)
    html_body = ERB.new(html_body_string).result(binding)

    File.write(output_filename, text_body)

    if index > 0 && index % 100 == 0
      delay_secs = 250 + rand(50)
      puts "Long delay before next 100 sends..."
    else
      delay_secs = 5 + rand(3)
    end

    #send_mail(recipient, sender, subject, text_body, html_body, delay_secs)
  end
end

def send_mail(recipient, sender, subject, text_body, html_body, delay_between_sends)
  options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'gmail.com',
            :user_name            => 'csalvato@gmail.com',
            :password             => 'piKablu64@0',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }
            
  Mail.defaults do
    delivery_method :smtp, options
  end

  mail = Mail.deliver do
    to      recipient.strip # Make sure the email address is stripped
    from    sender
    subject subject

    text_part do
      body text_body
    end

    html_part do
      content_type 'text/html; charset=UTF-8'
      body html_body
    end
  end

  puts "Waiting #{delay_between_sends} seconds before sending next one.."
  sleep(delay_secs)
end

puts "Starting Script..."

start_time = Time.now

create_copy

say_string = "All Done!"
`say "#{say_string}"`
puts "Script Complete!"
puts "Time elapsed: #{Time.now - start_time} seconds"