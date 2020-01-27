# The name of the role you're wanting to query on. Format follows "Owner".
$queriedRole = 

# Name of the file and path for which you want said file exported to. Format follows "C:\exampleDirectory\exampleFile.csv".

$exportPath = 

Connect-AzAccount

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    $subId = $sub.subscriptionId
    Set-AzContext -Subscription $subId
    $graphQuery = "where type == ""microsoft.network/virtualnetworks"" and subscriptionId == ""$subId"""
    $graphResult = Search-AzGraph -Query $graphQuery

    foreach ($result in $graphResult.Properties.subnets) {
        $rolenames = @()
        $roles = Get-AzRoleAssignment -RoleDefinitionName $queriedRole -Scope $result.id
        foreach ($role in $roles) {
            $rolenames += $role.DisplayName
        }
        $subnet = Get-AzVirtualNetworkSubnetConfig -ResourceId $result.id
        [pscustomobject]@{
            SubnetId      = $result.id
            SubnetName    = $result.name
            SubnetAddress = $subnet.AddressPrefix | Out-string
            AssignedRoles = (@($rolenames) | Out-String).Trim()
        } | Export-Csv -notype -Path $exportPath -Append
    }
}