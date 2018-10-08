
# Lets you do:
# 	ssh_instance i-0123456789abcdefg
# 	ssh_instance user@i-0123456789abcdefg
# Remember to use the correct AWS profile for the instance you're trying to reach
ssh_instance() {
	if [[ $# -eq 0 ]] ; then
		echo 'Please provide an instance id.'
		return 1
	else
		# If the input has @ in it, split into a username, instanceid, otherwise assume it's just an instanceid and append current user
		read -r user instanceid <<<$([[ $1 == *"@"* ]] && echo ${1//@/ } || echo $(whoami) "$1")
		# Use the instance id to query for the first private ip of the first instance, send errors to the void
		ip=$(aws ec2 describe-instances --instance-id $instanceid --query "Reservations[0].Instances[0].PrivateIpAddress" --output text 2>/dev/null)
		# If we located an IP address, ssh with the calculated user, otherwise assume we haven't found an instancew
		[ ! -z "$ip" ] && ssh $user@$ip || echo "Instance not found. Wrong account maybe?"	
	fi
}
