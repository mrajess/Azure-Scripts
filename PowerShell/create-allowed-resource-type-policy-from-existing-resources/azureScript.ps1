$results = get-azpolicystate -Apply "groupby((ResourceType), aggregate(`$count as NumTypes))" -Filter "PolicyAssignmentName eq '13677ffdf17a431082350da9'"
$policy = Get-AzPolicyDefinition -Name "a08ec900-254a-4555-9bf5-e42af04b5c5c"
$scope = Get-AzManagementGroup -GroupName "mrajess"

$allowedResources = $results.ResourceType | ForEach-Object { $_.Remove(0,1) }

New-AzPolicyAssignment -Name "Allowed Resources" -Scope $scope.Id -PolicyDefinition $policy -listOfResourceTypesAllowed $allowedResources