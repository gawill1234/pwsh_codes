This directory contains examples of tests that push api/route data 
directly at ASB.  This is a direct web request.  So it does not 
use swagger or selenium to perform the action.  Though they may 
use the swagger user/pw to accomplish the task.

The "run_" part is not necessary.  A holdover from an experimental phase.

## runitall.ps1
Run the list of tests in test.lst in powershell.
Options:  -which: <target>  (one of alpha, beta, charlie)
          -isEntra:  yes|no

## runitall.sh
Run the list of tests in test.lst in bash.
Options:  -W: <target>  (one of alpha, beta, charlie)
          -E: yes|no

## run_ADUser.ps1
Test the ActiveDirectoryUser route

## run_FORCEACOId.ps1
Test the /Force/ActiveContractingOfficeID route

## run_FORCEFMErr.ps1
Test the /Force/FormModel route
This test is a negative test.  It expects an error and passes if 
it gets the error.

## run_OASEcorIdx.ps1
Test the /OAS/ECOR/Indices route

## run_OASUser.ps1
Test the /OAS/Users route

## run_test.ps1
Test the /Vendors/VendorInfo route.  First one written.  More
of a example test.  Same as run_VendorInfo.ps1.

## showloc.ps1
Runs the /Requirements route.  But, no comments.  Intended to
show the actual code size of a test.

## run_VendorInfo.ps1
Test the /Vendors/VendorInfo route

## VendorInfo_dne.ps1
Test the /Vendors/VendorInfo route where the queried company does not exist

## Requirements1.ps1
Test the /Requirements route
This logs to FORCE.log, Application.log and stdout.xxxxxxxxx.log

## AwardType1.ps1
Test the /List/AwardType route

## AwardType2.ps1
Test the /List/AwardType route, specific item

## ACoordByOrg1.ps1
Test the /List/AssignmentCoordinatorsByOrg route

## ConOffUsersByOrg1.ps1
Test the /List/ContractingOfficeUsersByOrg route

## fpds1.ps1
Test the /Lists/FpdsContractingOfficeCode route, get everything 

## fpds2.ps1
Test the /Lists/FpdsContractingOfficeCode route, get a specific item

## fpds3.ps1
Test the /Lists/FpdsExtentCompeted route, get everything 

## fpds4.ps1
Test the /Lists/FpdsExtentCompeted route, get a specific item

## fpds5.ps1
Test the /Lists/FpdsIdcType route, get everything 

## fpds6.ps1
Test the /Lists/FpdsIdcType route, get a specific item

## fpds7.ps1
Test the /Lists/FpdsIdvType route, get everything 

## fpds8.ps1
Test the /Lists/FpdsIdvType route, get a specific item

## fpds9.ps1
Test the /Lists/FpdsReasonForModification route, get everything 

## fpds10.ps1
Test the /Lists/FpdsReasonForModification route, get a specific item

# Run the stuff in here, if you are bored.

git clone https://devops.ec.va.gov/SharedServices/eCMS/_git/-Scripts
cd -- -Scripts (where ever you put scripts)
git checkout cr/Oct7.07a-326115-GW
cd Deploy/tests
(powershell script)
./runitall.ps1 -which beta -isEntra yes

It only does GETS so it won't impact ongoing work.
