Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikUserRole' -Tag 'Public', 'Get-RubrikUserRole' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }
    #endregion

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'hasmore'   = 'false'
                'total'     = '1'
                'data'      =
                @{
                    'readOnlyAdmin'     = '@{basic=}'
                    'admin'             = '@{fullAdmin=}'
                    'principal'         = 'User:111-222-333'
                    'endUser'           = '@{restore="VirtualMachine:111}'           
                }
            }
        }
        It -Name 'Returns correct principal' -Test {
            ( Get-RubrikUserRole -id 'User:111-222-333' ).principal |
                Should -BeExactly 'User:111-222-333'
        } 
   
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikUserRole -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String[]' and try again."
        }       
    }
}