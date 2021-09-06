Import-Module OktaAPI

#In my PowerShell folder, I have a file OktaAPISettings.ps1 with 1 line of code:
#Connect-Okta $apiToken "https://the-sopranos.okta.com"
.\OktaAPISettings.ps1

#Show information about the current user.
Get-OktaUser "me"

#Add user to a group.
$user = Get-OktaUser "00uojcckkuFU9jzRs3l6" #literal in parentheses can be User ID or "me" for quick testing.
$groupR = Get-OktaGroups "Marketing" 'type eq "OKTA_GROUP"' #use name for simplicity, need to specify if group is Okta-mastered.
Add-OktaGroupMember $groupR.id $user.id

Create a user.
$userprofile = @{login = "green@color.com"; email = "green@color.com"; firstName = "Green"; lastName = "Guy"}
$user = New-OktaUser @{profile = $userprofile}
Write-Host "User Creation attempted. Admin needs to confirm."

#Create a group.
$groupprofile = @{name = "PowerShell"; description = "Created programmatically in PowerShell"}
$groupC = New-OktaGroup @{profile = $groupprofile}
Write-Host "Group Creation attempted. Admin needs to confirm.

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
<# $pagesearched = Get-OktaUsers -search 'profile.department eq "Marketing"'
$userssearched = $pagesearched.objects # see pagination above.
Write-Host $pagesearched
Write-Host $userssearched #>

#Adding users to Okta org with a for loop
for ($i=0; $i -lt 5; $i++)
{
    $date = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
    $userprofile = @{login = "$date@getcolor.com"; email = "$date@getcolor.com"; firstName = "Green"; lastName = "Guy"}
    $user = New-OktaUser @{profile = $userprofile}
    Write-Host addedTBD
}

#Get-OktaUsers(<#$q, $filter, $limit = 200, $url = "/api/v1/users?q=$q&filter=$filter&limit=$limit&search=$search", $search#>)
#Lists users from a certain username
$usersListed = Get-OktaUsers ($q = "cm@the-sopranos.com")
$usersListed.response.Content

function Get-MfaUsers() {
    $totalUsers = 0
    $mfaUsers = @()
    # for more filters, see https://developer.okta.com/docs/api/resources/users#list-users-with-a-filter
    $params = @{filter = 'status eq "ACTIVE"'}
    do {
        $page = Get-OktaUsers @params
        $users = $page.objects
        foreach ($user in $users) {
            $factors = Get-OktaFactors $user.id

            $sms = $factors.where({$_.factorType -eq "sms"})
            $call = $factors.where({$_.factorType -eq "call"})
            $push = $factors.where({$_.factorType -eq "push"})

            $mfaUsers += [PSCustomObject]@{
                id = $user.id
                name = $user.profile.login
                sms = $sms.factorType
                sms_enrolled = $sms.created
                sms_status = $sms.status
                call = $call.factorType
                call_enrolled = $call.created
                call_status = $call.status
                push_status = $push.status
            }
        }
        $totalUsers += $users.count
        $params = @{url = $page.nextUrl}
    } while ($page.nextUrl)
    Write-Host($push8)
    
    "$totalUsers users found."
    $mfaUsers
}

#Get the users who have push enabled as an active MFA factor.
Get-MfaUsers | Where-Object {$_.push_status -eq "ACTIVE"}

#Create dummy users for your org. Just input the # of users you'd like to create.
function New-Users($numUsers) {
    $now = Get-Date -Format "yyyyMMddHHmmss"
    for ($i = 1; $i -le $numUsers; $i++) {
        $profile = @{login="a$now$i@okta.com"; email="testuser$i@okta.com"; firstName="test"; lastName="ZExp$i"}
        try {
            $user = New-OktaUser @{profile = $profile; credentials = @{password = @{value = "Password123"}}} $false
            Write-Host $i
        } catch {
            Get-Error $_
        }
    }
}

#Measure the time it takes to create 1000 users. For me, it took 24 minutes, 59.433 seconds.
Measure-Command {New-Users 1000}
