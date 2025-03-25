import json

def write_content_to_json_file(filepath, filecontent):
    with open(filepath, 'w') as json_file:
        json.dump(filecontent, json_file, indent=4)


def get_text_elements_from_raw_figma_data(figma_json_data):
    """
    Extract all text elements from a Figma JSON file.

    Args:
        file_path (str): Path to the JSON file containing Figma data.

    Returns:
        tuple: Two lists:
            - text_nodes: A list of dictionaries containing text node details (e.g., id, name, style, fills).
            - text_data: A list of text node names.
        If the file cannot be loaded or processed, returns an empty list.

    Raises:
        ValueError: If the Figma data is malformed or the required keys are missing.
    """
    #figma_data = _load_json_data(file_path)
    if figma_json_data:
        top_node_id = list(figma_json_data["nodes"].keys())[0]
        top_node = figma_json_data["nodes"][top_node_id]["document"]
        text_nodes, text_data = _extract_text_nodes(top_node)  # Tuple unpacking (This "extract_text_nodes" returns 2 different lists of data hence we assigned two variables)
        return text_nodes, text_data
    return []

def _load_json_data(file_path):
    """
    Load Figma JSON data from a file.

    Args:
        file_path (str): Path to the JSON file containing Figma data.

    Returns:
        dict or None: The loaded Figma JSON data as a dictionary if successful, or None if an error occurs.

    Raises:
        Exception: If there is an error opening or parsing the JSON file.
    """
    try:
        with open(file_path, "r") as json_file:
            data = json.load(json_file)
            print(f"Successfully loaded data from {file_path}")
            return data
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        return None

def _extract_text_nodes(node, path=[]):
    """
    Recursively extract text nodes and their associated data from a Figma node tree.

    Args:
        node (dict): A Figma node as a dictionary.
        path (list): A list representing the path of parent nodes leading to the current node.

    Returns:
        tuple: Two lists:
            - extracted_text_nodes: A list of dictionaries containing text node details (e.g., id, name, style, fills).
            - text_data: A list of text node names.

    Raises:
        ValueError: If the input node is not a dictionary or is malformed.
    """
    if not node or not isinstance(node, dict):
        return [], []

    extracted_text_nodes = []
    text_data = []

    if node.get("type") == "TEXT":
        text_data.append(node.get("name", "N/A"))
        try:
            text_node_data = {
                #"id": node.get("id", "N/A"),
                "text": node.get("name", "N/A"),
                "textCase": "uppercase" if node.get("style", {}).get("textCase", "N/A") == "UPPER" else "none",
                "color": _rgba_to_figma_format(node.get("fills", [{}])[0].get("color", {})),
                "opacity": node.get("fills", [{}])[0].get("opacity", 1.0),
                "fontFamily": node.get("style", {}).get("fontFamily", "NA"),
                "fontSize": node.get("style", {}).get("fontSize", "NA"),
                "fontWeight": node.get("style", {}).get("fontWeight", "NA"),
                "letterSpacing": node.get("style", {}).get("letterSpacing", "NA"),
                "lineHeightPx": node.get("style", {}).get("lineHeightPx", "NA"),
                #"style": node.get("style", {}),  # Style information
            }
            extracted_text_nodes.append(text_node_data)
        except (KeyError, IndexError, ValueError):
            pass

    if "children" in node and isinstance(node["children"], list):
        for child in node["children"]:
            child_nodes, child_names = _extract_text_nodes(child, path + [node.get("name", "")])
            extracted_text_nodes.extend(child_nodes)
            text_data.extend(child_names)

    return extracted_text_nodes, text_data


def _rgba_to_figma_format(rgba):
    """
    Convert RGBA values (with r, g, b in [0, 1]) to Figma's RGBA format with r, g, b as integers in [0, 255]
    and alpha unchanged as a float in [0, 1].

    Args:
        rgba (dict): A dictionary with keys 'r', 'g', 'b', and 'a', where 'r', 'g', 'b' are in the range [0, 1]
                     and 'a' is a float in the range [0, 1].

    Returns:
        dict: A dictionary with keys 'r', 'g', 'b' as integers in the range [0, 255] and 'a' as a float.

    Raises:
        ValueError: If the input dictionary is missing required keys or is not in the correct format.
    """
    try:
        r = int(rgba["r"] * 255)
        g = int(rgba["g"] * 255)
        b = int(rgba["b"] * 255)
        # a = round(rgba["a"], 2)  # Alpha remains unchanged and is rounded to 2 decimals
        #return {"r": r, "g": g, "b": b}
        return f"rgb({r}, {g}, {b})"
    except KeyError as e:
        raise ValueError(f"Missing key in RGBA dictionary: {e}")
    except TypeError:
        raise ValueError("Input must be a dictionary with keys 'r', 'g', 'b'.")

def compare_figma_with_web_json(figma_json, web_json):
    # Initialize a list to store the results
    results = []
    best_tag = None

    # Iterate through each reference item and compare with data list
    for ref_styles in figma_json:

        # Initialize variables to track the best match for each reference item
        best_match = None
        max_score = 0

        # Iterate through each item in the data list and compare
        for item in web_json:
            # Check if the text component matches
            if ref_styles.get('text','figma').lower() != item.get('text','web').lower():
                continue

            item_styles = item
            score = 0

            # Calculate the match score for the current item
            for key in ref_styles:
                ref_value = ref_styles.get(key, "N/A")
                item_value = item_styles.get(key, "N/A")
                if ref_value == item_value:
                    score += 1

            # Update best match if the current score is higher
            if score > max_score:
                max_score = score
                best_match = item
                best_tag = item.get('tagName', "N/A")

        # Store the result for the current reference item
        if best_match:
            best_item = best_match
            title = f"{best_tag}-{best_item['text']}"

            # Add the result to the Excel sheet for the best matching tag
            for key in ref_styles:
                ref_value = ref_styles.get(key, "N/A")
                item_value = best_item.get(key, "N/A")
                match = "Yes" if ref_value == item_value else "No"
                row = {
                    "title":title,
                    "key":key,
                    "figma_value":ref_value,
                    "web_value":item_value,
                    "match":match
                }
                results.append(row)
                # Add the data to the Excel sheet
                #print([title, key, ref_value, item_value, match])

            # Print best match details to the console
            #print(f"[bold yellow]Best matching element for '{best_item['text']}':[/bold yellow]")
            #print(f"[bold yellow]Match score:[/bold yellow] {max_score}")
            #print(f"\n")

    return results