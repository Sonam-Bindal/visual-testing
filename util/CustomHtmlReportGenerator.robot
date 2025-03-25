*** Settings ***
Library    Collections
Library    OperatingSystem
Library    String
Resource    ../config.robot
Library     Utilities.py

*** Variables ***
&{TEST_RESULT}
@{ROWS}

*** Keywords ***
Private_Get From Test Dict
    TRY
        ${existing_items}     Get From Dictionary    ${TEST_RESULT}   ${TEST_NAME}
    EXCEPT
        Set To Dictionary       ${TEST_RESULT}      ${TEST_NAME}=@{ROWS}
        ${existing_items}     Get From Dictionary    ${TEST_RESULT}   ${TEST_NAME}
    END
    Log    ${TEST_RESULT}
    RETURN      ${existing_items}


Report-Browser/Device
    [Arguments]     ${BrowserDevice}=${EMPTY}
    ${BrowserDevice}    Convert To Upper Case    ${BrowserDevice}
    ${temp_list2}     Create List     ${EMPTY}       ${EMPTY}      ${EMPTY}     ${EMPTY}    ${EMPTY}    ${EMPTY}    ${BrowserDevice}
    ${existing_items}     Private_Get From Test Dict
    Append To List     ${existing_items}   ${temp_list2}
    Set To Dictionary       ${TEST_RESULT}      ${TEST_NAME}=${existing_items}
    Log    ${TEST_RESULT}


Report-Pass
    [Arguments]     ${Description}=${EMPTY}      ${Matching_Percent}=${EMPTY}     ${Image_Path1}=${EMPTY}     ${Image_Path2}=${EMPTY}    ${pixel_perfect_report_path}=${EMPTY}        ${BrowserDevice}=${EMPTY}
    ${temp_list}     Create List     PASS       ${Description}      ${Matching_Percent}     ${Image_Path1}     ${Image_Path2}    ${pixel_perfect_report_path}   ${BrowserDevice}
    ${existing_items}     Private_Get From Test Dict
    Append To List     ${existing_items}   ${temp_list}
    Set To Dictionary       ${TEST_RESULT}      ${TEST_NAME}=${existing_items}
    Log    ${TEST_RESULT}

Report-Info
    [Arguments]     ${Description}=${EMPTY}      ${Matching_Percent}=${EMPTY}     ${Image_Path1}=${EMPTY}     ${Image_Path2}=${EMPTY}    ${pixel_perfect_report_path}=${EMPTY}        ${BrowserDevice}=${EMPTY}
    ${temp_list}     Create List     INFO       ${Description}      ${Matching_Percent}     ${Image_Path1}     ${Image_Path2}    ${pixel_perfect_report_path}   ${BrowserDevice}
    ${existing_items}     Private_Get From Test Dict
    Append To List     ${existing_items}   ${temp_list}
    Set To Dictionary       ${TEST_RESULT}      ${TEST_NAME}=${existing_items}
    Log    ${TEST_RESULT}

Report-Fail
    [Arguments]     ${Description}=${EMPTY}      ${Matching_Percent}=${EMPTY}     ${Image_Path1}=${EMPTY}     ${Image_Path2}=${EMPTY}    ${pixel_perfect_report_path}=${EMPTY}        ${BrowserDevice}=${EMPTY}
    ${temp_list}     Create List     FAIL       ${Description}      ${Matching_Percent}     ${Image_Path1}     ${Image_Path2}    ${pixel_perfect_report_path}   ${BrowserDevice}
    ${existing_items}     Private_Get From Test Dict
    Append To List     ${existing_items}   ${temp_list}
    Set To Dictionary       ${TEST_RESULT}      ${TEST_NAME}=${existing_items}
    Log    ${TEST_RESULT}

Generate HTML Report
    ${all_results}      Private_Read all jsons and merge the content
    ${html_content}    Private_Get HTML Template    ${all_results}
    Create File    ${HTML_REPORT_FILE_PATH}    ${html_content}

End test
    ${json_data}    Evaluate    json.dumps('''${TEST_RESULT}''')   json
    Create File    ${CUSTOM_REPORT_OUTPUT_DIR}/${TEST_NAME}.json    ${json_data}

Private_Read all jsons and merge the content
    # Read the individual tests json and combine them to create final report, it is needed for PABOT
    ${all_results}    Create Dictionary
    ${files}    List Files In Directory    ${CUSTOM_REPORT_OUTPUT_DIR}
    FOR    ${file}    IN    @{files}
        ${test_results}    Get File    ${CUSTOM_REPORT_OUTPUT_DIR}/${file}
        ${test_results}=    Replace String    ${test_results}    "    ${EMPTY}
        ${test_results}=    Replace String    ${test_results}    \\    \\\\
        ${test_results}=    Replace String    ${test_results}    '    "
        ${test_results}    Evaluate    json.loads('''${test_results}''')    json
        #Log    ${TEST_RESULTS}

        ${keys}     Get Dictionary Keys    ${TEST_RESULTS}
        FOR    ${key}    IN    @{keys}
            @{value}    Get From Dictionary    ${test_results}    ${key}
            Set To Dictionary    ${all_results}    ${key}=${value}
        END
        #Log    ${all_results}
    END
    RETURN  ${all_results}

Private_Get HTML Template
    [Arguments]     ${all_results}
    ${html}=    Set Variable    <html><head><title>Responsive Testing Report</title><style>table, th, td {border: 2px solid grey;border-collapse: collapse;font-family: calibri;padding: 5px;} .desc{max-width: 700px;word-wrap: break-word;}</style></head><body><h1>Test Report</h1><table style="width:100%"><tr><th>Test Case/Browser/Device</th><th>Status</th><th class='desc'>Description</th><th>Matching %</th><th>Overlay Image</th><th>Highlight Diff Image</th><th>Pixel Perfect Report</th></tr>
    ${keylist}      Get Dictionary Keys    ${all_results}
    FOR    ${key}    IN    @{keylist}
        ${html}=    Set Variable    ${html}<tr><td>${key}</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
        ${list}     Get From Dictionary    ${all_results}    ${key}
        FOR    ${row}    IN    @{list}
            ${matching_percent}     Set Variable    ${row[2]}
            IF     "${matching_percent}" != "${EMPTY}"
                 ${matching_percent}     Convert To Integer    ${matching_percent}
            END

            ${image1}     Set Variable    ${row[3]}
            ${flag}     Evaluate    r"${image1}" != "${EMPTY}"
            IF     ${flag}
                 ${image1}     Set Variable      <a href="${image1}" target="_blank">Overlayed Img</a>
            END

            ${image2}     Set Variable    ${row[4]}
            ${flag}     Evaluate    r"${image2}" != "${EMPTY}"
            IF     ${flag}
                 ${image2}     Set Variable      <a href="${image2}" target="_blank">Highlighted Img</a>
            END

            ${pixel_perfect_report}     Set Variable    ${row[5]}
            ${flag}     Evaluate    r"${pixel_perfect_report}" != "${EMPTY}"
            IF     ${flag}
                 ${pixel_perfect_report}     Set Variable      <a href="${pixel_perfect_report}" target="_blank">Pixel Perfect Report</a>
            END

            ${html}=    Set Variable    ${html}<tr><td>${row[6]}</td><td>${row[0]}</td><td class='desc'>${row[1]}</td><td>${matching_percent}</td><td>${image1}</td><td>${image2}</td><td>${pixel_perfect_report}</td></tr>
        END
    END
    ${html}=    Set Variable    ${html}</table></body></html>
    RETURN   ${html}


Generate HTML Report from JSON
    [Arguments]     ${json_data}
    ${time}     Utilities.Get Timestamp
    ${report_name}  Set Variable    PixelPerfect${time}.html
    ${report_path}  Set Variable    ${OUTPUT_DIR}/${report_name}
    ${html_content}     Private_Get HTML Template for JSON    ${json_data}
    Create File        ${report_path}   ${html_content}
    RETURN  ${report_name}


Private_Get HTML Template for JSON
    [Arguments]     ${json_data}
    ${html}=    Set Variable    <html><head><title>Pixel Perfect Testing Report</title><style>table, th, td {border: 2px solid grey;border-collapse: collapse;font-family: calibri;padding: 5px;} .desc{max-width: 700px;word-wrap: break-word;}</style></head><body><h1>Test Report</h1><table style="width:100%"><tr><th>Sr. No.</th><th class='desc'>Searched Text</th><th>Css Property</th><th>Expected Value(figma)</th><th>Actual Value(web)</th><th>Matching?</th></tr>
    ${last_title}       Set Variable        ${EMPTY}
    ${sr_no}       Set Variable        0

    FOR    ${row}    IN    @{json_data}
        ${current_title}       Set Variable        ${row['title']}
        IF    "${current_title}" != "${last_title}"
             ${last_title}      Set Variable    ${current_title}
             ${sr_no}   Evaluate    ${sr_no}+1
             ${current_sr_no}   Set Variable    ${sr_no}
        ELSE
             ${current_title}   Set Variable    ${EMPTY}
             ${current_sr_no}   Set Variable    ${EMPTY}
        END
        ${html}=    Set Variable    ${html}<tr><td>${current_sr_no}</td><td class='desc'>${current_title}</td><td>${row['key']}</td><td>${row['figma_value']}</td><td>${row['web_value']}</td><td>${row['match']}</td></tr>
    END
    ${html}=    Set Variable    ${html}</table></body></html>
    RETURN   ${html}