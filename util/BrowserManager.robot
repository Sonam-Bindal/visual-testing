
*** Settings ***
Resource    CustomHtmlReportGenerator.robot
Library     SeleniumLibrary
Library     Image_HighlightDifference.py

*** Keywords ***
Launch Browser
    [Arguments]      ${URL}    ${BROWSER}   ${FIGMA_IMAGE_PATH}
    ${BROWSER}      Convert to Lower Case    ${BROWSER}
    ${figma_width}    ${figma_height}   Get Image Dimensions    ${figma_image_path}
    Report-Info    Figma Image Size=${figma_width}x${figma_height}

    ${STOP_EXECUTION}    Set Variable    NO
    ${WIDTH}    Convert To Integer    ${figma_width}
    ${HEIGHT}   Convert To Integer    ${figma_height}

    IF    "${BROWSER}" in "headlessedge"
        ${options}    Evaluate    sys.modules['selenium.webdriver'].EdgeOptions()    sys, selenium.webdriver
        Call Method    ${options}    add_argument    --headless
    END

    IF    "${BROWSER}" in "headlesschrome"
        ${options}    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
        Call Method    ${options}    add_argument    --headless
    END

    IF    ${WIDTH} <= 500
        IF    "${BROWSER}" in "headlessfirefox"
            Report-Info     FIREFOX NOT SUPPORTED FOR RESOLUTIONS LESS THAN 500 px
            ${STOP_EXECUTION}    Set Variable    YES
        ELSE
            ${deviceMetrics}    Create Dictionary    width=${WIDTH}    height=${HEIGHT}
            ${mobile_emulation}     Create Dictionary       deviceMetrics=${deviceMetrics}
            Call Method    ${options}    add_experimental_option    mobileEmulation    ${mobile_emulation}
            IF    "${BROWSER}" in "headlessedge"
               Open Browser    ${URL}    edge    options=${options}
            ELSE
               Open Browser    ${URL}    ${BROWSER}    options=${options}
            END
            ${new_width}    ${new_height}    Get Window Size    ${True}
            Report-INFO    Browser window size: ${new_width}x${new_height}
        END
    ELSE
        IF    "${BROWSER}" in "headlessedge"
            Open Browser    ${URL}    edge    options=${options}
        END

        IF    "${BROWSER}" in "headlessfirefox"
             Open Browser    ${URL}     headlessfirefox
        END

        IF    "${BROWSER}" in "headlesschrome"
             Open Browser    ${URL}     headlesschrome      options=${options}
        END

        Set Window Size    ${WIDTH}   ${HEIGHT}
        ${new_width}    ${new_height}    Get Window Size    ${True}
        ${new_width}    Evaluate    ${WIDTH}+(${WIDTH}-${new_width})
        ${new_height}   Evaluate    ${HEIGHT}+(${HEIGHT}-${new_height})
        Set Window Size    ${new_width}    ${new_height}
        ${new_width}    ${new_height}    Get Window Size    ${True}
        Report-INFO    Browser window size: ${new_width}x${new_height}
    END
    Sleep    ${WAIT_TIME_IN_SECONDS}s
    RETURN  ${STOP_EXECUTION}



Get Webapp JSON Data
    [Arguments]     ${figma_text_list}
    ${jscontent}     Get File    ${CURDIR}/getwebdata.js
    ${val}      Execute Javascript      ARGUMENTS       ${figma_text_list}      JAVASCRIPT      ${jscontent}
    #Log    ${val}
    #Write content to json file      ${CURDIR}/web.json     ${val}
    RETURN      ${val}

