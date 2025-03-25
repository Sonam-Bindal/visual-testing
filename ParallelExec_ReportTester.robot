
*** Settings ***
Resource        util/CustomHtmlReportGenerator.robot
Suite Teardown     Generate HTML Report
Test Teardown   End test



*** Test Cases ***
Tc1
    Log    tc1
    Report-Browser/Device     chrome
    Report-Info     Page url 1

Tc2
    Log    tc2
    Report-Browser/Device     firefox
    Report-Info     Page url 2
