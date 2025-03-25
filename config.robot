*** Variables ***
${WAIT_TIME_IN_SECONDS}    60
${OUTPUT_DIR}     ${CURDIR}/output
${CUSTOM_REPORT_OUTPUT_DIR}     ${CURDIR}/output/report

${testdata}     testdata
${FIGMA_DIR}     ${CURDIR}/${testdata}/figma
${EXCEL_FILE}     ${CURDIR}/${testdata}/Resolutions.xlsx

${SCREENSHOTS_DIR}     ${OUTPUT_DIR}/screenshots
${OUT_IMG_FOLDER_NAME}      comparison_output
${COMPARISON_OUTPUT_DIR}     ${OUTPUT_DIR}/${OUT_IMG_FOLDER_NAME}

${SHEET_NAME}     Sheet1
${HTML_REPORT_FILE_PATH}     ${OUTPUT_DIR}/Custom_Report.html