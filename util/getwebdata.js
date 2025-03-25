const target_tags = ["p", "h1", "h2", "h3", "h4", "h5", "h6", "span", "a", "li", "ul", "ol", "strong", "em", "blockquote", "label", "b", "i", "small"];

function getElementsPropertiesByTextContents(textContents) {
    const allElements = document.querySelectorAll('*');
    const allProperties = [];
    //return Array.isArray(textContents);
    //return typeof textContents;

    //textContents = JSON.stringify(textContents);
    //const list = textContents.split(", ").map(item => item.trim().replace(/^'|'$/g, ''));
    textContents.forEach(textContent => {
        allElements.forEach(element => {
            if (target_tags.includes(element.tagName.toLowerCase()) && element.textContent.toLowerCase().trim() === textContent.toLowerCase().trim()) {
                const computedStyles = window.getComputedStyle(element);



                const elementProperties = {
                /*
                for (let property of computedStyles) {
                    elementProperties[property] = computedStyles.getPropertyValue(property);
                }
                */
                text: textContent,
                fontFamily: computedStyles.fontFamily,
                fontWeight: isNaN(parseInt(computedStyles.fontWeight)) ? computedStyles.fontWeight : parseInt(computedStyles.fontWeight),
                fontSize: parseFloat(computedStyles.fontSize),
                color: computedStyles.color,
                textCase: element.style.textTransform || computedStyles.textTransform,
                letterSpacing: parseFloat(computedStyles.letterSpacing),
                lineHeightPx:  parseFloat(computedStyles.lineHeight),
                // Add the tag name of the element
                tagName: element.tagName
                };

                //allProperties[textContent] = elementProperties;
                allProperties.push(elementProperties);
            }
        });
    });

    return allProperties;
}

// Example usage:
//const textContents = ["Will it work for me?", "See Why Theradome Leads the way"];
const properties = getElementsPropertiesByTextContents(arguments[0]);
//console.log(properties);
return properties;