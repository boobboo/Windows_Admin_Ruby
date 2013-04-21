require 'rubygems'
require 'AWS'
require 'json/pure' 
require 'csv'
require 'mysql'
require 'time'
$volumeId
$size
$status
$createTime
$instanceId
$device
$attachTime


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
db.query ('truncate table currentvolumes')
     ec2.describe_volumes.volumeSet.item.each do |volumeItem|
	 	$instanceId = "No Instance"
		$device = "No Device"
		$attachTime = "00:00:00 31-12-9999"
		$volumeId = nil
		$size = nil
		$status = nil
		$createTime = nil
		$volumeId = volumeItem['volumeId']
		$size = volumeItem['size']
		$status = volumeItem['status']
		$createTime = volumeItem['createTime']
		$createTime = Time.parse($createTime)
			$createTime = $createTime.to_s
					volumeItem.attachmentSet.item.each do |attachmentItem|
						$instanceId = attachmentItem['instanceId']
						$device = attachmentItem['device']
						$attachTime = attachmentItem['attachTime']
						$attachTime = Time.parse($attachTime)
						$attachTime = $attachTime.to_s
					end
				

					if (!volumeItem.tagSet.nil?)
						volumeItem.tagSet.item.each do |tagItem|
							if tagItem['key'] = 'Name'
								$value = tagItem['value']
							else
								$value = "no name"
							end
						end
					else
					$value = "no tag"
puts $volumeId
puts $size
puts $status
puts $createTime
puts $instanceId
puts $device
puts $attachTime
puts "ends"
													
						db.query("INSERT INTO ec2_db.currentvolumes (customerId, volumeId, size, status, creationDate, instanceId, deviceId, attachDate, metadataName)
						VALUES ('720101133246','"+$volumeId+"','"+$size+"', '"+$status+"' , '"+$createTime+"' , '"+$instanceId+"' , '"+$device+"' , '"+$attachTime+"' , '"+$value+"')")
			 
					end
				end
		end

	