function Test-CloudFlare {
    <#
    .SYNOPSIS
    Tests a connection to CloudFlare DNS.
    .DESCRIPTION
    This function will test a single computer's or multiple computer's Internet Connection to CloudFlare's one.one.one.one DNS Server.
    .PARAMETER ComputerName
    A string that specifies which computer(s) will be connected to in a remote session.
    .EXAMPLE
    Test-CloudFlare -ComputerName 192.168.1.70
    Executing this command will test a computer's connection to CloudFlare's one.one.one.one DNS server.
    Since the ComputerName parameter accepts multiple values, you can alternatively test multiple computers at once.
    .NOTES
    Author: Derek Kirk
    Last Modified: 12-09-2021
    Version 2.0 - Modified Release of Test-CloudFlare.
        -Added a Try/Catch construct to the ForEach construct for error handling.
        -Modified the OBJ variable to use the [PSCustomObject] accelerator.
        -Moved the associated output commands to the new function Get-PipeResults.
        -Modified comment based help.
    #>
    
    [CmdletBinding()]
    # This enables cmdlet binding.
    
    Param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [Alias('CN','Name')][string[]]$ComputerName
    ) #Param
    #This sets the ComputerName parameter to true, accepts input ByValue from the pipeline.
    Begin {}
    Process {
    ForEach ($EachValue in $ComputerName) {
        Try {
            $Params = @{
              'ComputerName' = $EachValue
              'ErrorAction' = 'Stop'
            } #Try Params
        #Creates a new parameter named Params that includes the objects ComputerName and ErrorAction.
        $RemoteSession = New-PSSession @Params
        #Variable which specifies a new remote session to the computer name provided in input.
        Enter-PSSession $RemoteSession
        #Enters the remote session.
        $TestCF = Test-NetConnection -ComputerName 'one.one.one.one' -InformationLevel Detailed
        #Variable that contains the command to run a detailed ping test to 1.1.1.1.
        Write-Verbose "Running a ping test from the remote computer to 1.1.1.1."
        Start-Sleep -Seconds 2
        $OBJ = [PSCustomObject]@{
            'ComputerName' = $EachValue
            'PingSuccess' = $TestCF.PingSucceeded
            'NameResolve' = $TestCF.NameResolutionSucceeded
            'ResolvedAddresses' = $TestCF.ResolvedAddresses
            } #OBJ Custom Props
        #Creates a variable that contains the ComputerName and the results of the ping, name resolve and the resolved address.
        $OBJ
        Exit-PSSession
        Remove-PSSession $RemoteSession
        #Exits the PS session and then removes the PS session.
        } #Try
        Catch {
            Write-Host "Remote Connection to $EachValue failed" -ForeGroundColor Red
            } #Catch
        } #ForEach
    } #Process
    End {}
} #Function
    
function Get-PipeResults {
    <#
    .SYNOPSIS
    This function will retrieve the results of the output from Get-PipeResults.
    .DESCRIPTION
    Retrieves and saves/displays the result of a command based on which output was chosen by the user.
    .PARAMETER Output
    A string that specifies which output will be produced depending on input.
        Host will display the the output to the screen.
        Text will save the output to a text file named PipeResults.txt.
        CSV will save the output to a CSV file named PipeResults.csv.
    .PARAMETER PathVariable
    A string that specifies a path to the user's home directory.
    .PARAMETER FileName
    This string contains the name of the file in which your output will be saved as. The default name of the file saved is "PipeResults".
    .PARAMETER Object
    Accepts multiple objects from the pipeline.
    .EXAMPLE
    Get-PipeResults -ComputerName 192.168.1.70 -Output 'Host'.
    Executing this command will run the Get-PipeResults script and display the results of the script on the screen.
    .EXAMPLE
    Get-PipeResults -ComputerName 192.168.1.70 -Output 'Text'
    Executing this command will run the Get-PipeResults script and output the results of the scripts in text file.
    .EXAMPLE
    Get-PipeResults -ComputerName 192.168.1.70 -Output 'CSV'.
    Executing this command will run the Get-PipeResults script and output the results of the script in a CSV file.
    .NOTES
    Author: Derek Kirk
    Last Modified: 12-09-2021
    Version 2.0 - Initial Release of Get-PipeResults.
        -Moved associated output options from Test-CloudFlare.
        -Modified comment based help.
    #>

    [CmdletBinding()]
    #This enables cmdlet binding.

    param (
        [Parameter(ValueFromPipeLine=$True, ValueFromPipelineByPropertyName=$True)]
        [object[]]$Object,
        [Parameter(Mandatory=$False)][string]$PathVariable = $env:userprofile,
        [ValidateSet('Host','Text','CSV')][string]$Output = "Host",
        [Parameter(Mandatory=$False)][string]$FileName = "PipeResults"
    ) #Param
    #Accepts byValue and byPropertyName pipeline input. Sets valid options for the output parameter and defaults output to host.
    Begin {}
    Process {
        Switch ($Output) {
            "Text" {
                $Object | Out-File $PathVariable\$FileName.txt
                #Adds content to the PipeResults text file including the contents of TestResults.txt.
                Write-Verbose "Generating results file"
                Start-Sleep -Seconds 1
                Write-Verbose "Opening results"
                Start-Sleep -Seconds 2
                Notepad.exe $PathVariable\$FileName.txt
                Start-Sleep -Seconds 2
                Remove-Item $PathVariable\$FileName.txt
                #Opens the PipeResults text file and removes the TestResults text file.
                } #Text
            "CSV" {
                Write-Verbose "Generating results file as CSV"
                Start-Sleep -Seconds 1
                $Object | Export-CSV -Path $PathVariable\$FileName.csv
                #Retrieves the output results and exports the contents to a CSV file.
                } #CSV
            "Host" {
                Write-Verbose "Generating results file and displaying it to the screen"
                Start-Sleep -Seconds 1
                $Object
                #Retrieves the output results and displays the contents to the screen.
                } #Host
            } #Switch
    } #Process
    End {}
} #Function