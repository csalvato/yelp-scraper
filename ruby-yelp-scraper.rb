require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'rails'
require 'watir-webdriver'
require 'csv'
require 'whois'

def fetch_links_in_json output_file_name
	browser = Watir::Browser.new :firefox

	# Overwrite old file and put headers
	CSV.open("#{output_file_name}.csv","wb") do |csv|
	 	csv << ["Ad?",
	 					"Company Name",
	 					"Stars",
	 					"Phone Number",
	 					"Yelp URL",
	 					"Company URL",
	 					"Email",
	 					"Street Address",
	 					"City",
	 					"State",
	 					"ZIP",
	 					"Exception"]
	end

	search_string = "cpa"
	json_base_urls = [
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=10001&&start=0&l=g%3A-73.1651253333618%2C41.369168092075675%2C-74.8130745521118%2C40.12070578072507&parent_request_id=9e5607db6dd417ba&request_origin=hash&bookmark=true", #NY
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=10001&start=0&l=g%3A-74.1648811927368%2C41.007837130369374%2C-75.8128304114868%2C39.752552985178525&parent_request_id=0d596be3a55733f6&request_origin=hash&bookmark=true", #N NJ
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=10001&start=0&l=g%3A-72.2203011146118%2C41.91297915869615%2C-73.8682503333618%2C40.67488005044548&parent_request_id=332b1b9edb9290b6&request_origin=hash&bookmark=true", # LI & SW CT	
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=10001&start=0&l=g%3A-71.7149300208618%2C42.376686603463696%2C-73.3628792396118%2C41.14751488141275&parent_request_id=7abc788466b632c1&request_origin=hash&bookmark=true", # More CT	
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=10001&start=0&l=g%3A-70.8689827552368%2C42.373771406077765%2C-72.5169319739868%2C41.14454330063166&parent_request_id=1b8fe7d2aa044f42&request_origin=hash&bookmark=true", # CT & RI
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=10001&start=0&l=g%3A-70.6767220130493%2C42.988711209247896%2C-72.3246712317993%2C41.77144906864006&parent_request_id=1bb2ea658704e698&request_origin=hash&bookmark=true", # E MA (Boston Area)
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=houston&start=0&l=g%3A-94.54497427519533%2C30.30278765572468%2C-96.19292349394533%2C28.869770713450315&parent_request_id=26268748371665f1&request_origin=hash&bookmark=true", # Houston
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Dallas%2C%20TX&start=0&l=g%3A-96.18804931640625%2C33.33983296254634%2C-97.83599853515625%2C31.952290165944365&parent_request_id=2da493bfd895dd69&request_origin=hash&bookmark=true", # Dallas
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Austin%2C%20TX&start=0&l=g%3A-97.30178833007812%2C30.75401452292025%2C-98.12576293945312%2C30.043323164551083&parent_request_id=ec8dc85cbbb6dffe&request_origin=hash&bookmark=true", # Austin
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Los%20Angeles%2C%20CA&start=0&l=g%3A-117.79129028320312%2C34.32828767066809%2C-118.61526489257812%2C33.6450824301223&parent_request_id=e627ed227bfa5755&request_origin=hash&bookmark=true", # Los Angeles #1
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Los%20Angeles%2C%20CA&start=0&l=g%3A-117.06619262695312%2C34.08000617423546%2C-117.89016723632812%2C33.394803435916714&parent_request_id=f0ecdf93e6f969c2&request_origin=hash&bookmark=true", # Los Angeles #2
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Los%20Angeles%2C%20CA&start=0&l=g%3A-118.17306518554688%2C34.6303146544345%2C-118.99703979492188%2C33.949556811755286&parent_request_id=831e04c91745980d&request_origin=hash&bookmark=true", # Los Angeles #3
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Los%20Angeles%2C%20CA&start=0&l=g%3A-118.53286743164062%2C34.6755020600347%2C-119.35684204101562%2C33.995112030212425&parent_request_id=611b993494887fbf&request_origin=hash&bookmark=true", # Los Angeles #4
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Phoenix%2C%20AZ&start=0&l=g%3A-111.25030517578125%2C34.131592483797554%2C-112.89825439453125%2C32.75656570288531&parent_request_id=86114f8558ed547d&request_origin=hash&bookmark=true", # Phoenix
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Chicago%2CIL&start=0&l=g%3A-86.85379028320312%2C42.515456217789726%2C-88.50173950195312%2C41.28897225155621&parent_request_id=4e7af9a3875a8d1b&request_origin=hash&bookmark=true", # Chicago
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=Seattle%2CWA&start=0&l=g%3A-121.51153564453125%2C48.22180942369693%2C-123.15948486328125%2C47.11207506763631&parent_request_id=4e7af9a3875a8d1b&request_origin=hash&bookmark=true", # Seattle
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=denver%2C+co&start=0&l=g%3A-104.16824340820312%2C40.70309215567731%2C-105.81619262695312%2C39.442094406171&parent_request_id=4e7af9a3875a8d1b&request_origin=hash&bookmark=true", # Denver & Fort Collins
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=miami%2C+fl&start=0&l=g%3A-80.02166748046875%2C26.331658185377567%2C-80.84564208984375%2C25.590838187841516&parent_request_id=4e7af9a3875a8d1b&request_origin=hash&bookmark=true", # Miami & Fort Lauderdale
										"http://www.yelp.com/search/snippet?find_desc=#{search_string}&find_loc=tampa%2C+fl&start=0&l=g%3A-81.21231079101562,28.25507027782465%2C-82.86026000976562%2C26.79370662978729&parent_request_id=4e7af9a3875a8d1b&request_origin=hash&bookmark=true", # Tampa & Sarasota FL
									 ]

	json_base_urls.each do |json_base_url|
		puts "Fetching #{json_base_url}"
		current_page = 1
		current_index = (current_page * 10) - 10
		json_url = json_base_url.gsub("&start=0", "&start=#{current_index}")
		begin
			browser.goto json_url
			page = Nokogiri::HTML(browser.html)
			json = JSON.parse(page.search('pre').text)
		rescue Exception => msg
			puts "Retrying: #{json_url}"
			retry
		end
		num_pages = Nokogiri::HTML(json["search_results"]).search('.page-of-pages').text[/(\d+) of (\d+)/,2].to_i

		(current_page .. num_pages).each do
			puts "Page #{current_page} of #{num_pages}"
			json_url = json_base_url.gsub("&start=0", "&start=#{current_index}")
			begin
			browser.goto json_url
			page = Nokogiri::HTML(browser.html)
			json = JSON.parse(page.search('pre').text)
			rescue Exception => msg
				puts "Retrying: #{json_url}"
				retry
			end
			results = Nokogiri::HTML(json["search_results"]).search('.search-result')
			results.each do |result|
				business_name = result.search('.biz-name').text
				star_rating = result.search('i.star-img')
				phone = result.search('.biz-phone').text[/\(\d\d\d\) \d\d\d-\d\d\d\d/]
				if star_rating.empty? 
					star_rating = "N/A"
				else
					star_rating = result.search('i.star-img').first['title'][/(\d.\d)/]
				end

				if ad?(result['class'])
					yelp_url = URI.decode(result.search('.biz-name').first['href'][/redirect_url=([^&]+)/,1])
				else 
					yelp_url = "http://yelp.com" + result.search('.biz-name').first['href']
				end

				CSV.open("#{output_file_name}.csv","a") do |csv|
					csv << [ad?(result['class']) ? "Ad" : "Natural",
									business_name,
									star_rating,
									phone,
									yelp_url,
									nil,
									nil]
				end
			end
			current_page += 1
			current_index = (current_page * 10) - 10
			delay_secs = 5 + rand(3)
	  	puts "Waiting #{delay_secs} seconds before getting next page.."
	  	sleep(delay_secs)
		end
	end
	browser.close
end

def ad? (class_name)
	#is an ad if the class name of the search result does nit contain "natural-search-result"
	return_val = false
	return_val = true if class_name[/natural-search-result/].nil?
	return return_val
end

def remove_duplicates(file_name)
	# Load table with headers to get the dupe row index
	table = CSV.read("#{file_name}.csv", :headers => true)
	duplicate_header_row = 'Company Name'
	duplicate_header_row_index = table.headers.find_index("Company Name")
	# Reload the table without headers to access it more easily to remove dupes
	table = CSV.read("#{file_name}.csv")

	CSV.open("#{file_name}.csv", 'wb') do |csv|
		table.uniq { |row| row[duplicate_header_row_index] }.each do |row|
			csv << row
		end
	end
end

def merge_csv( file_name_1, file_name_2 )
	first_data = []
	second_data = []
	first_data = CSV.read("#{file_name_1}.csv") if File.exist?("#{file_name_1}.csv")
	second_data = CSV.read("#{file_name_2}.csv") if File.exist?("#{file_name_2}.csv")
	
	output_data = first_data.concat(second_data)

	CSV.open("#{file_name_1}.csv", 'wb') do |csv|
		output_data.each do |row|
			csv << row
		end
	end
end

def extract_business_info (page, master_list_name, existing_data )
	row = existing_data
	business_website = URI.decode(page.search(".biz-website a").first['href'])
	business_website = business_website[/url=([^&]+)/,1] if !business_website.nil?
	street_address = ""
	address_city = ""
	address_state = ""
	address_ZIP = ""
	page.search(".address span").each do |address_node|
		case address_node['itemprop']
		when 'streetAddress'
			address_node.children.each do |line|
				street_address += line.to_s if line.to_s != "<br>"
			end
		when 'addressLocality'
			address_city = address_node.text
		when 'addressRegion'
			address_state = address_node.text
		when 'postalCode'
			address_ZIP = address_node.text
		else
			puts address_node['itemprop'].inspect
		end
	end
	CSV.open("#{master_list_name}.csv", 'a', :headers => true) do |csv|
		csv << [ row["Ad?"],
						 row["Company Name"],
						 row["Stars"],
						 row["Phone Number"],
						 row["Yelp URL"],
						 business_website,
						 row["Email"],
						 street_address,
						 address_city,
						 address_state,
						 address_ZIP
						]
	end
end

def fetch_business_listing_links(master_list_name)
	if File.exist?("#{master_list_name}.csv")
		browser = Watir::Browser.new :firefox
		master_data = CSV.read("#{master_list_name}.csv", :headers => true) #:encoding => 'windows-1251:utf-8')
		CSV.open("#{master_list_name}.csv", 'wb', :headers => true) do |csv|
			# csv << master_data.headers #Commented out because of bad yelp_data file.  For new runs, can delete this.
			csv << ["Ad?",
	 					"Company Name",
	 					"Stars",
	 					"Phone Number",
	 					"Yelp URL",
	 					"Company URL",
	 					"Email",
	 					"Street Address",
	 					"City",
	 					"State",
	 					"ZIP",
	 					"Exception"]
		end

		master_data.each do |row|
			puts "URL: #{row['Yelp URL']}"
			puts row['Yelp URL']
			if row['Exception'] == "Net::ReadTimeout"
				puts "Trying again because of ReadTimeout exception"
			end
			if row['Company URL'] == nil && (row['Exception'] != "undefined method `[]' for nil:NilClass") #row 11 is exception
				begin
				  Timeout::timeout(2) do
				    # perform actions that may hang here
				    browser.goto row['Yelp URL']
						page = Nokogiri::HTML(browser.html)
						extract_business_info(page, master_list_name, row)
				  end
				rescue Timeout::Error => msg
				  puts "Recovered from Timeout"
				  begin
				  	sleep(0.5)
				  	puts "Escape"
				  	browser.send_keys :escape
				  	sleep(0.1)
				  	puts "Escape"
				  	browser.send_keys :escape
				  	sleep(0.1)
				  	puts "Escape"
				  	browser.send_keys :escape
				  	page = Nokogiri::HTML(browser.html)
						extract_business_info(page, master_list_name, row)
					rescue Exception => msg
						puts msg
						puts "Moving on and leaving this row as is"
						CSV.open("#{master_list_name}.csv", 'a', :headers => true) do |csv|
							csv << [ row["Ad?"],
											 row["Company Name"],
											 row["Stars"],
											 row["Phone Number"],
											 row["Yelp URL"],
											 row["Company URL"],
											 row["Email"],
											 row["Street Address"],
											 row["City"],
											 row["State"],
											 row["ZIP"],
											 msg
											]
						end
					end	
				rescue Exception => msg
					puts msg
					puts "Moving on and leaving this row as is"
					CSV.open("#{master_list_name}.csv", 'a', :headers => true) do |csv|
						csv << [ row["Ad?"],
										 row["Company Name"],
										 row["Stars"],
										 row["Phone Number"],
										 row["Yelp URL"],
										 row["Company URL"],
										 row["Email"],
										 row["Street Address"],
										 row["City"],
										 row["State"],
										 row["ZIP"],
										 msg
										]
					end		
				end
			else
				if row['Company URL'] != nil
					puts "Skipping because URL Exists: #{row['Company URL']}"
				else
					puts "Skipping because of #{row['Exception']}"
				end
				CSV.open("#{master_list_name}.csv", 'a', :headers => true) do |csv|
						csv << [ row["Ad?"],
										 row["Company Name"],
										 row["Stars"],
										 row["Phone Number"],
										 row["Yelp URL"],
										 row["Company URL"],
										 row["Email"],
										 row["Street Address"],
										 row["City"],
										 row["State"],
										 row["ZIP"],
										 row["Exception"]
										]
					end		
			end
		end
		browser.close
	end
end

def get_emails_from_whois(master_list_name)
	if File.exist?("#{master_list_name}.csv")
		whois = Whois::Client.new
		master_data = CSV.read("#{master_list_name}.csv", :headers => true, :encoding => 'windows-1251:utf-8')
		CSV.open("#{master_list_name}.csv", 'wb', :headers => true) do |csv|
			csv << master_data.headers
		end

		master_data.each do |row|
			puts "Getting Data for #{row['Company URL']}"
			if !row['Company URL'].nil? && !row['Company URL'].empty?
				begin
					domain_name = row['Company URL'][/http:\/\/([^\/]+)/,1].gsub("www.", "")
					whois_record = whois.lookup(domain_name)
					
					if !whois_record.admin_contact.nil?
						email = whois_record.admin_contact.email
					elsif !whois_record.to_s[/Admin Email: ([^\\\n]+)/,1].nil?
						email = whois_record.to_s[/Admin Email: ([^\\\n]+)/,1]
					else 
						email = ""
					end

					if email[/(.+)@(.+)/,1].downcase == "whois"
						email = ""
					end

					email.strip!
					
					CSV.open("#{master_list_name}.csv", 'a', :headers => true) do |csv|
						csv << [ row["Ad?"],
										 row["Company Name"],
										 row["Stars"],
										 row["Phone Number"],
										 row["Yelp URL"],
										 row["Company URL"],
										 email,
										 row["Street Address"],
										 row["City"],
										 row["State"],
										 row["ZIP"]
										]
					end
				rescue Exception => msg 
					puts msg  
					puts "Moving on and leaving this row as is"
					CSV.open("#{master_list_name}.csv", 'a', :headers => true) do |csv|
						csv << [ row["Ad?"],
										 row["Company Name"],
										 row["Stars"],
										 row["Phone Number"],
										 row["Yelp URL"],
										 row["Company URL"],
										 row["Email"],
										 row["Street Address"],
										 row["City"],
										 row["State"],
										 row["ZIP"]
										]
					end
				end
			end
		end
	end
end


start_time = Time.now
puts "Starting Script..."
scrape_data_file_name = "yelp_data"
master_list_file_name = "accountants-nationwide"

fetch_links_in_json (scrape_data_file_name)
merge_csv(master_list_file_name, scrape_data_file_name )
remove_duplicates(master_list_file_name)
fetch_business_listing_links(master_list_file_name)
#get_emails_from_whois("master_list copy")


say_string = "All Done!"
`say "#{say_string}"`
puts "Script Complete!"
puts "Time elapsed: #{Time.now - start_time} seconds"