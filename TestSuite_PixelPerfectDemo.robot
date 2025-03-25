
*** Settings ***
Resource    util/CustomHtmlReportGenerator.robot
Resource    util/ImageManager.robot
Resource    util/BrowserManager.robot
Library     util/ExcelFileHandler.py
Library     RequestsLibrary
Library     util/pixelperfect/FigmaManager.py


*** Keywords ***

Get Figma JSON Data via API
    ${file_id}      Set Variable        hritOi8jFNn2Zvf6ilrZwB
    ${node_id}      Set Variable        1202-3193
    ${FIGMA_BASE_URL}   Set Variable        https://api.figma.com/v1/files/${file_id}/nodes?ids=${node_id}
    ${headers}      Create Dictionary       X-Figma-Token=FIGMA_ACCESS_TOKEN
    ${response}     GET     ${FIGMA_BASE_URL}       headers=${headers}
    #Write content to json file      ${CURDIR}/figma_text_nodes_raw.json     ${response.json()}

    ${figma_text_nodes}   ${figma_text_data}   Get Text Elements From Raw Figma Data     ${response.json()}
    #Log    ${response.json()}
    #Write content to json file      ${CURDIR}/figma_text_nodes_transformed.json     ${figma_text_nodes}
    #Write content to json file      ${CURDIR}/figma_text_data.json     ${figma_text_data}
    RETURN      ${figma_text_nodes}   ${figma_text_data}

Get Webapp JSON Data via browser
    [Arguments]     ${figma_text_data}
    Open Browser        https://theradome.com/    headlesschrome
    Sleep    2s
    ${jscontent}     Get File    getwebdata.js
    ${val}      Execute Javascript      ARGUMENTS       ${figma_text_data}      JAVASCRIPT      ${jscontent}
    Close All Browsers
    #Log    ${val}
    #Write content to json file      ${CURDIR}/web.json     ${val}
    RETURN      ${val}


#*** Test Cases ***
Test Case Perform Pixel Perfect Testing
    ${figma_text_nodes}   ${figma_text_data}    Get Figma Json Data via API
    ${web_css_json}     Get Webapp JSON Data via browser   ${figma_text_data}
    ${results}  Compare Figma With Web Json       ${figma_text_nodes}     ${web_css_json}
    Generate HTML Report from JSON    ${results}

