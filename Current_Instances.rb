require 'rubygems'
require 'AWS'
require 'json/pure' 
require 'csv'
require 'mysql'
require 'time'
 

db = Mysql.new('localhost', 'scriptUser', 'pass', 'ec2_db')

#************************Get Customer Access Keys and assign to temp variable**************
ACCESS_KEY = db.query("select Access_Key from customerid")
ACCESS_KEY_ID_temp = ACCESS_KEY.fetch_row
#************************Get Customer Secret Key and assign to temp variable**************
SECRET_ACCESS = db.query("select Secret_Key from customerid")
SECRET_ACCESS_KEY_temp  = SECRET_ACCESS.fetch_row
#***********************Convert record set to string and then concatenate 
ACCESS_KEY_ID = ACCESS_KEY_ID_temp.to_s
ACCESS_KEY_ID = ACCESS_KEY_ID[2...22]
#***********************Convert record set to string and then concatenate 
SECRET_ACCESS_KEY = SECRET_ACCESS_KEY_temp.to_s
SECRET_ACCESS_KEY = SECRET_ACCESS_KEY[2...42]
#******Connect to EC2*******
  ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY_ID, :secret_access_key => SECRET_ACCESS_KEY)
  
#**************************Clear Existing Current Instances Table***************************************
db.query ('truncate table currentinstances')
    ec2.describe_instances.reservationSet.item.each do |reservationItem| 
	ownerId = reservationItem['ownerId'] 
	requesterId = reservationItem['requesterId']
		if (requesterId.nil?)
			requesterId = '0'
		end
			reservationItem.instancesSet.item.each do |instanceItem|
				instanceId = instanceItem['instanceId']
				launchTime = instanceItem['launchTime']
					launchTime = Time.parse(launchTime)
					launchTime = launchTime.to_s
				instanceState = instanceItem['instanceState']['name']
				reason = instanceItem['reason']
				if (reason.nil?)
					reason = 'none'
				end
				instanceType = instanceItem['instanceType']
				availabilityZone = instanceItem['placement']['availabilityZone']
				value = "none"
				if (!instanceItem.tagSet.nil?)
					instanceItem.tagSet.item.each do |tagItem|
					value = tagItem['value']
					end
				else
					value = "none"
				end

			db.query("INSERT INTO ec2_db.currentinstances (customerId, userId, instanceID, status, reason, instanceSize, launchDate, availabilityZone, metadata)
			VALUES ('"+ownerId+"','"+requesterId+"', '"+instanceId+"' , '"+instanceState+"' , '"+reason+"' , '"+instanceType+"' , '"+launchTime+"' , '"+availabilityZone+"' , '"+value+"' )")
			 
			 end
	end
	