#!/bin/bash
DATA_DIR="$HOME/.local/share/mcgen"
START_DIR="$PWD"

if [[ ! -t 0 ]]; then
    exit 1
fi

printError() {
    echo "Error: Please run the command properly:"
    echo "mcgen <DIRECTORY> --<PLATFORM> [--json <JSON_FILE_LOCATION>]"
    exit 1
}

if [[ "$1" == $null ]]; then
    printError
elif [[ "$2" == "--sponge" ]]; then
    OUTPUT_DIR=$(realpath -m "$1")
    echo "$OUTPUT_DIR" > "$DATA_DIR/output.tmp"

    if [[ "$3" != "--json" && "$3" == $null ]]; then
        cd "$DATA_DIR/scripts/genjson"

        echo "Please answer these questions for your Sponge Plugin to get set up!"

        sleep 0.5
        bash "./genjson-sponge.mcgen.sh"

        PROJECT_NAME=$(cat "$DATA_DIR/current.tmp" | tail -n1)

        cd "$DATA_DIR/scripts/mkfiles"

        echo "Creating $PROJECT_NAME in $OUTPUT_DIR.."
        bash "./mkfiles-sponge.mcgen.sh"

        echo "Done!"
        echo "Please go to $OUTPUT_DIR/$PROJECT_NAME to start working on your $PROJECT_NAME Sponge Plugin!"

        cd "$START_DIR"

    elif [[ "$3" == "--json" ]]; then
        JSON_FILE=$(realpath -m "$4")

        if [[ ! -f $JSON_FILE ]]; then
            printError
        fi

        echo "Reading your json \"$JSON_FILE\" file to ensure it is properly compatible.."

        PROJECT_NAME=$(jq -r '.PROJECT_NAME' "$JSON_FILE")
        GROUP=$(jq -r '.GROUP' "$JSON_FILE")
        PLUGIN_TYPE=$(jq -r '.PLUGIN_TYPE' "$JSON_FILE")
        JDK_VERSION=$(jq -r '.JDK_VERSION' "$JSON_FILE")
        SPONGEAPI_VERSION=$(jq -r '.SPONGEAPI_VERSION' "$JSON_FILE")
        GROUP_ID=$(jq -r '.GROUP_ID' "$JSON_FILE")
        PROJECT_NAME=$(jq -r '.PROJECT_NAME' "$JSON_FILE")
        PLUGIN_NAME=$(jq -r '.PLUGIN_NAME' "$JSON_FILE")
        PLUGIN_ID=$(jq -r '.PLUGIN_ID' "$JSON_FILE")
        ARTIFACT_ID=$(jq -r '.ARTIFACT_ID' "$JSON_FILE")
        MAIN_CLASS=$(jq -r '.MAIN_CLASS' "$JSON_FILE")
        FULL_MAIN_CLASS=$(jq -r '.FULL_MAIN_CLASS' "$JSON_FILE")
        BUILD_SYSTEM=$(jq -r '.BUILD_SYSTEM' "$JSON_FILE")
        LANGUAGE=$(jq -r '.LANGUAGE' "$JSON_FILE")
        KOTLIN_VERSION=$(jq -r '.KOTLIN_VERSION' "$JSON_FILE")
        DESCRIPTION=$(jq -r '.DESCRIPTION' "$JSON_FILE")
        WEBSITE=$(jq -r '.WEBSITE' "$JSON_FILE")
        VERSION=$(jq -r '.VERSION' "$JSON_FILE")
        LICENSE_ID=$(jq -r '.LICENSE_ID' "$JSON_FILE")
        USE_GIT=$(jq -r '.USE_GIT' "$JSON_FILE")
        mapfile -t AUTHORS < <(jq -r '.AUTHORS[]?' "$JSON_FILE")

        VARIABLES=(
            PROJECT_NAME
            GROUP
            PLUGIN_TYPE
            JDK_VERSION
            SPONGEAPI_VERSION
            GROUP_ID
            PROJECT_NAME
            PLUGIN_NAME
            PLUGIN_ID
            ARTIFACT_ID
            MAIN_CLASS
            FULL_MAIN_CLASS
            BUILD_SYSTEM
            LANGUAGE
            DESCRIPTION
            WEBSITE
            LICENSE_ID
            USE_GIT
            AUTHORS
        )

        for VARIABLE in "${VARIABLES[@]}"; do
            if [[ "${!VARIABLE}" == $null || "${!VARIABLE}" == "null" ]]; then
                echo "Error: Please make sure your json \"$JSON_FILE\" file is properly generated and formatted."
                exit 1
            fi
        done

        if [[ "$LANGUAGE" == "kotlin" && "$KOTLIN_VERSION" == $null || "$LANGUAGE" == "kotlin" && "$KOTLIN_VERSION" == "null" ]]; then
            echo "Error: Please make sure your json \"$JSON_FILE\" file is properly generated and formatted."
            exit 1
        fi

        echo "$PROJECT_NAME" > "$DATA_DIR/current.tmp"

        mkdir -p "$DATA_DIR/projects"

        echo "Copying your json \"$JSON_FILE\" file to $DATA_DIR/projects/$PROJECT_NAME.json.."

        cp "$JSON_FILE" "$DATA_DIR/projects/$PROJECT_NAME.json"

        cd "$DATA_DIR/scripts/mkfiles"

        echo "Creating $PROJECT_NAME in $OUTPUT_DIR.."
        bash "./mkfiles-sponge.mcgen.sh"

        echo "Done!"
        echo "Please go to $OUTPUT_DIR/$PROJECT_NAME to start working on your $PROJECT_NAME Sponge Plugin!"

        cd "$START_DIR"
    else
        printError
    fi
else
    printError
fi
