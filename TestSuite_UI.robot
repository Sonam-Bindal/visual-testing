
*** Settings ***
Resource    util/CustomHtmlReportGenerator.robot
Resource    util/ImageManager.robot
Resource    util/BrowserManager.robot
Library     util/ExcelFileHandler.py
Library    util/pixelperfect/FigmaManager.py
Library     RequestsLibrary
Library    Image_HighlightDifference
Suite Teardown     Generate HTML Report
Test Teardown   End test

*** Test Cases ***
#Sample test to Compare 2 different images Delete
    #${img1}     Set Variable     ${FIGMA_DIR}/345_figma.png
    #${img2}     Set Variable     ${FIGMA_DIR}/345_figma_1.png
    #Report-Browser/Device     chrome
    #Compare 2 Images And Find Difference    ${img1}     ${img2}

#Sample test to Compare 2 different images
    #${img1}     Set Variable     ${FIGMA_DIR}/345_figma_1.png
    #${img2}     Set Variable     ${FIGMA_DIR}/345_figma_1.png
    ##${img2}     Set Variable     ${SCREENSHOTS_DIR}/Screenshot1733741490.29968.png
    #Report-Browser/Device     chrome
    #Compare 2 Images And Find Difference  ${img1}     ${img2}

#Sample test to Compare 2 similar images
    #${img1}     Set Variable     ${FIGMA_DIR}/345_figma.png
    #${img2}     Set Variable     ${FIGMA_DIR}/345_figma_1.png
    #${img2}     Set Variable     ${SCREENSHOTS_DIR}/headlesschrome_Mobile.png
    #Report-Browser/Device     chrome
    #Compare 2 Images And Find Difference  ${img1}     ${img2}

Data driven test to Compare figma images fetched from excel with live site in Cross-Browser setting
    [Template]    Responsive and Cross-Browser Testing Common Keyword
    chrome
    firefox
    edge

*** Keywords ***
Responsive and Cross-Browser Testing Common Keyword
    [Arguments]      ${browser}
    ${row_len}      Get Row Count    ${EXCEL_FILE}    ${SHEET_NAME}
    FOR    ${row}    IN RANGE    0    ${row_len}
        ${run}    Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     0

        ${run}  Convert To Lower Case    ${run}
        IF    "${run}" == "y"
            ${device}      Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     1
            ${figma_image_name}      Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     2
            ${url}      Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     3
            ${figma_access_token}      Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     4
            ${figma_file_id}      Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     5
            ${figma_node_id}      Get Cell Value    ${EXCEL_FILE}    ${SHEET_NAME}    ${row}     6
            Report-Browser/Device     ${browser}-${device}
            ${figma_image_path}     Set Variable    ${FIGMA_DIR}/${FIGMA_IMAGE_NAME}
            Report-Info     Figma Image path - ${figma_image_path}
            Report-Info     Page url - ${url}
            ${STOP_EXECUTION}       Launch Browser    ${url}    ${browser}    ${figma_image_path}
            IF    "${STOP_EXECUTION}"=="NO"
                ##########
                # In case you need to perform some action on the app such as login/navigation/expand/collapse
                # Please write the code just before capture screenshot
                ##########

                ${figma_text_nodes}   ${figma_text_list}    Get Figma JSON Data via API     ${figma_access_token}       ${figma_file_id}        ${figma_node_id}
                ${web_css_json}     Get Webapp JSON Data    ${figma_text_list}
                ${results}      Compare Figma With Web Json       ${figma_text_nodes}     ${web_css_json}
                ${pixel_perfect_report_path}   Generate HTML Report from JSON    ${results}
                #Code for PSCI project
                #Click Element    xpath=/html/body/div[2]/div[1]/div/div/div[2]/button[3]
                Capture Screenshot of live app and compare with passed image    ${figma_image_path}     ${pixel_perfect_report_path}

                Close All Browsers
            END
        END
    END

Get Figma JSON Data via API
    [Arguments]      ${figma_access_token}       ${figma_file_id}        ${figma_node_id}
    ${FIGMA_BASE_URL}   Set Variable        https://api.figma.com/v1/files/${figma_file_id}/nodes?ids=${figma_node_id}
    ${headers}      Create Dictionary       X-Figma-Token=${figma_access_token}
    ${response}     GET     ${FIGMA_BASE_URL}       headers=${headers}
    #Write content to json file      ${CURDIR}/figma_text_nodes_raw.json     ${response.json()}

    ${figma_text_nodes}   ${figma_text_list}   Get Text Elements From Raw Figma Data     ${response.json()}
    #Log    ${response.json()}
    #Write content to json file      ${CURDIR}/figma_text_nodes_transformed.json     ${figma_text_nodes}
    #Write content to json file      ${CURDIR}/figma_text_data.json     ${figma_text_data}
    RETURN      ${figma_text_nodes}   ${figma_text_list}

