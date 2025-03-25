
*** Settings ***
Library    OperatingSystem
Library    WatchUI
Resource    ../config.robot
Resource    CustomHtmlReportGenerator.robot
Library     Image_HighlightDifference.py
Library    SeleniumLibrary


*** Keywords ***
Capture Screenshot of live app and compare with passed image
    [Arguments]     ${img1}     ${pixel_perfect_report_path}=${EMPTY}
    ${timestamp}    Utilities.Get Timestamp
    ${img2}     Set Variable    ${SCREENSHOTS_DIR}/Screenshot${timestamp}.png
    Capture Page Screenshot    ${img2}
    Report-Info    Screenshot saved at: ${img2}
    Compare 2 Images And Find Difference     ${img1}     ${img2}    ${pixel_perfect_report_path}

Compare 2 Images And Find Difference
    [Arguments]     ${img1}     ${img2}     ${pixel_perfect_report_path}=${EMPTY}
    Run Keyword And Ignore Error   Compare Images      ${img1}     ${img2}      save_folder=${COMPARISON_OUTPUT_DIR}     #tolerance=0.1       image_format=png
    Sleep    1s
    ${diffImg}     Private_Get Last Updated File Path        ${COMPARISON_OUTPUT_DIR}
    Log    ${diffImg}
    ${matching%}       ${overlayImg}     Find Diff    ${img1}     ${img2}     ${COMPARISON_OUTPUT_DIR}
    Report-Info     Comparison Result     ${matching%}      ${OUT_IMG_FOLDER_NAME}/${overlayImg}    ${OUT_IMG_FOLDER_NAME}/${diffImg}     ${pixel_perfect_report_path}
    RETURN      ${matching%}       ${overlayImg}    ${diffImg}

Private_Get Last Updated File Path
    [Arguments]     ${folder}
    @{files}=    List Files In Directory    ${folder}
    ${latest_file}=    Set Variable    None
    ${latest_time}=    Convert To Integer    0
    FOR    ${file}    IN    @{files}
        ${modified_time}=    Get Modified Time     ${folder}/${file}    epoch
        ${flag}     Evaluate    int(${modified_time}) > int(${latest_time})
        IF   ${flag}
            ${latest_time}      Set Variable    ${modified_time}
            ${latest_file}      Set Variable    ${file}
        END
        Log    ${latest_time}
        Log    ${latest_file}
    END
    Log    ${folder}/${latest_file}
    RETURN  ${latest_file}