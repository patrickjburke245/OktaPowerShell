Import-Module OktaAPI

#In my PowerShell folder, I have a file OktaAPISettings.ps1 with 1 line of code:
#Connect-Okta $apitoken "https://the-sopranos.okta.com"
.\OktaAPISettings.ps1

#Show information about the current user.
Get-OktaUser "me"

#Add user to a group.
$user = Get-OktaUser "00uojcckkuFU9jzRs3l6" #literal in parentheses can be User ID or "me" for quick testing.
$groupR = Get-OktaGroups "Marketing" 'type eq "OKTA_GROUP"' #use name for simplicity, need to specify if group is Okta-mastered.
Add-OktaGroupMember $groupR.id $user.id

# Create a user.
$userprofile = @{login = "green@color.com"; email = "green@color.com"; firstName = "Green"; lastName = "Guy"}
$user = New-OktaUser @{profile = $userprofile}
Write-Host "User Creation attempted. Admin needs to confirm."

# Create a group.
$groupprofile = @{name = "PowerShell"; description = "Created programmatically in PowerShell"}
$groupC = New-OktaGroup @{profile = $groupprofile}
Write-Host "Group Creation attempted. Admin needs to confirm."

# Get all users. If you have more than 200 users, you have to use pagination.
# See this page for more info:
# https://developer.okta.com/docs/reference/api-overview/#pagination
$params = @{filter = 'status eq "ACTIVE"'}
do {
    $page = Get-OktaUsers @params
    $users = $page.objects
    foreach ($user in $users) {
        # Add more properties here:
        Write-Host $user.profile.login $user.profile.email
    }
    $params = @{url = $page.nextUrl}
} while ($page.nextUrl)

# Query up to 200 users by first name, last name or email.
$pagequeried = Get-OktaUsers -q "Patrick"
$usersqueried = $pagequeried.objects
Write-Host $pagequeried
Write-Host $usersqueried

# Filter lists all users; filter by status, last updated, id, login, email, first name or last name.
$pagefiltered = Get-OktaUsers -filter 'profile.firstName eq "Patrick"'
$usersfiltered = $pagefiltered.objects # see pagination above.
Write-Host $pagefiltered
Write-Host $usersfiltered

#Quick note: More optionality (attributes to be filtered for) with -filter vs. -q
#More details: https://developer.okta.com/docs/reference/api/users/#request-parameters-3

# Search lists all users; search by any user profile property, including custom-defined
# properties, and id, status, created, activated, status changed and last updated.
$pagesearched = Get-OktaUsers -search 'profile.department eq "Marketing"'
$userssearched = $pagesearched.objects # see pagination above.
Write-Host $pagesearched
Write-Host $userssearched

#Dummycomment