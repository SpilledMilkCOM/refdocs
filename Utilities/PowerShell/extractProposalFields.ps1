#
# Generate CSV data based on a JSON file and field names (turned into column names)
#

Clear

# Replace the file root (example file job.JSON.txt - "job" is the root)

$fileName = "proposals.JSON.txt"
$fieldNames = "opportunityId,proposalId,externalOpportunityId,name"
$fieldArray = $fieldNames.Split(",")

#========================= DO NOT EDIT BELOW THIS LINE ===========================================

Write-Output $fieldNames

# Each row is a valid JSON message (the entire file is NOT valid JSON)

$allMessages = Get-Content -Path $fileName

foreach ($message in $allMessages)
{
	# Convert each row into a valid JSON object so it can be tested against the filter IDs.

	$jsonMessage = $message | ConvertFrom-Json

	$output = ""

	foreach ($fieldName in $fieldArray)
	{
		if ($output.Length -gt 0)
		{
			$output += ","
		}

		# If there are double quotes in the data, then maybe swap it out
		# Kind of like "reflection" on a property

		$output += "`"" + ($jsonMessage | Select -ExpandProperty $fieldName) + "`""
	}

	# $output = $jsonMessage.opportunityId + "," + $jsonMessage.externalOpportunityId

	Write-Output $output
}
