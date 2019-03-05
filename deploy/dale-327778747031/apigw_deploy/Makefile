deploy :
	terragrunt apply --terragrunt-non-interactive -no-color -auto-approve
	terragrunt output -no-color
	terragrunt output -no-color -json > /tmp/output.json
