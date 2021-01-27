#
# Generate a file of filtered messages base on the the "creativeNumber" attribute of the message and the array of IDs.
#

Clear

# Replace the file root (example file job.JSON.txt - "job" is the root)

$fileRoot = "job"

# Replace the array contents below with the missing job IDs to be extracted. (no commas needed)

$creativeIds = @(
392721
398744
415244
420452
411788
448396
457595
457596
473038
480620
491080
493630
491343
488550
502987
504776
504774
)

#========================= DO NOT EDIT BELOW THIS LINE ===========================================

$messageFile = ".\$fileRoot.JSON.txt"
$filteredMessageFile = ".\$fileRoot.filtered.JSONarray.txt"

Write-Output "Reading $messageFile ..."

# Each row is a valid JSON message (the entire file is NOT valid JSON)

$allMessages = Get-Content -Path $messageFile

Write-Output "Filtering messages ..."

Write-Output "[" > $filteredMessageFile

foreach ($message in $allMessages)
{
	# Convert each row into a valid JSON object so it can be tested against the filter IDs.

	$jsonMessage = $message | ConvertFrom-Json

	if ($jsonMessage.creativeNumber -in $creativeIds) {
		Write-Output $message

		# The last comma is invalid, but formatting it using Notepad++ will detect this error to remind you to delete it.

		Write-Output $message "," >> $filteredMessageFile
	}
}

Write-Output "]" >> $filteredMessageFile