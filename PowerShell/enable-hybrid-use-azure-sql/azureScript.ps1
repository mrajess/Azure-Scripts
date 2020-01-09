Install-Module Az.ResourceGraph
Import-Module Az.ResourceGraph

$subscriptions = Search-AzGraph -Query "where type == ""microsoft.sql/servers/databases"" and properties.currentSku.tier in (""GeneralPurpose"", ""Hyperscale"", ""BusinessCritical"") and properties.currentSku.name !contains ""GP_S"" and properties.licenseType != ""BasePrice"" | summarize resourceCount=count() by subscriptionId | project subscriptionId"

foreach ($sub in $subscriptions) {
    $subId = $sub.subscriptionId
    Set-AzContext -Subscription $subId
    $graphQuery = "where type == ""microsoft.sql/servers/databases"" and properties.currentSku.tier in (""GeneralPurpose"", ""Hyperscale"", ""BusinessCritical"") and properties.currentSku.name !contains ""GP_S"" and properties.licenseType != ""BasePrice"" and properties.currentSku.name != ""ElasticPool"" and subscriptionId == ""$subId"""
    $graphResult = Search-AzGraph -Query $graphQuery
    foreach ($result in $graphResult) {
        $serverName = ($result.ResourceId).split('/')[8]
        Set-AzSqlDatabase -ResourceGroupName $result.resourceGroup -DatabaseName $result.name -ServerName $serverName -LicenseType "BasePrice"
    }
    $graphQuery = "where type == ""microsoft.sql/servers/elasticpools"" and properties.licenseType == ""LicenseIncluded"" and subscriptionId == ""$subId"""
    $graphResult = Search-AzGraph -Query $graphQuery
    foreach ($result in $graphResult) {
        $serverName = ($result.ResourceId).split('/')[8]
        Set-AzSqlElasticPool -ResourceGroupName $result.resourceGroup -ElasticPoolName $result.name -ServerName $serverName -LicenseType "BasePrice"
    }
}