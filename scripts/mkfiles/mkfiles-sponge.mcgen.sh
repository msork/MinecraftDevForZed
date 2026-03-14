#!/bin/bash
DATA_DIR="$HOME/.local/share/mcgen"
ROOT_TEMPLATE_DIR="$DATA_DIR/templates/sponge"
ROOT_OUT_DIR=$(cat $DATA_DIR/output.tmp | tail -n1)

# If script is not ran in terminal, exit
if [[ ! -t 0 ]]; then
    exit 1
fi

if [[ ! -f $DATA_DIR/current.tmp ]]; then
    echo "Error: File not found for configuration. Please rerun mcgen --sponge again."
    exit 1
fi

PROJECT_NAME=$(cat $DATA_DIR/current.tmp | tail -n1)
JSON_FILE="$DATA_DIR/projects/$PROJECT_NAME.json"

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

TEMPLATE_DIR="$ROOT_TEMPLATE_DIR/$LANGUAGE/$BUILD_SYSTEM"
PACKAGE_PATH="${GROUP_ID//./\/}/$PLUGIN_ID"
OUT_DIR="$ROOT_OUT_DIR/$PROJECT_NAME"
TEMP_OUT_DIR="$OUT_DIR/template"

mkdir -p $ROOT_OUT_DIR

makeGradleAuthorsBlock() {
    GRADLE_AUTHORS_BLOCK=""
    for AUTHOR in "${AUTHORS[@]}"; do
        if [[ -n "$AUTHOR" && "$AUTHOR" != "${AUTHORS[0]}" ]]; then
            GRADLE_AUTHORS_BLOCK+=",
            "
        fi
        GRADLE_AUTHORS_BLOCK+="contributor(\"$AUTHOR\") {
        "
        GRADLE_AUTHORS_BLOCK+="    description(\"Author\")
        "
        GRADLE_AUTHORS_BLOCK+="}"
    done
}

makeMavenAuthorsBlock() {
    MAVEN_AUTHORS_BLOCK=""
    for AUTHOR in "${AUTHORS[@]}"; do
        if [[ -n "$AUTHOR" && "$AUTHOR" != "${AUTHORS[0]}" ]]; then
            MAVEN_AUTHORS_BLOCK+=",
            "
        fi
        MAVEN_AUTHORS_BLOCK+="{
        "
        MAVEN_AUTHORS_BLOCK+="  \"name\": \"$AUTHOR\",
        "
        MAVEN_AUTHORS_BLOCK+="  \"description\": \"Author\"
        "
        MAVEN_AUTHORS_BLOCK+="}"
    done
}

convertFile() {
    export GROUP PLUGIN_TYPE JDK_VERSION SPONGEAPI_VERSION GROUP_ID
    export PROJECT_NAME PLUGIN_NAME PLUGIN_ID ARTIFACT_ID MAIN_CLASS FULL_MAIN_CLASS
    export BUILD_SYSTEM LANGUAGE KOTLIN_VERSION DESCRIPTION WEBSITE VERSION LICENSE_ID
    export GRADLE_AUTHORS_BLOCK MAVEN_AUTHORS_BLOCK

    perl -0pe '
        s/\$\{GROUP\}/$ENV{GROUP} \/\/ ""/ge;
        s/\$\{PLUGIN_TYPE\}/$ENV{PLUGIN_TYPE} \/\/ ""/ge;
        s/\$\{JDK_VERSION\}/$ENV{JDK_VERSION} \/\/ ""/ge;
        s/\$\{SPONGEAPI_VERSION\}/$ENV{SPONGEAPI_VERSION} \/\/ ""/ge;
        s/\$\{GROUP_ID\}/$ENV{GROUP_ID} \/\/ ""/ge;
        s/\$\{PROJECT_NAME\}/$ENV{PROJECT_NAME} \/\/ ""/ge;
        s/\$\{PLUGIN_NAME\}/$ENV{PLUGIN_NAME} \/\/ ""/ge;
        s/\$\{PLUGIN_ID\}/$ENV{PLUGIN_ID} \/\/ ""/ge;
        s/\$\{ARTIFACT_ID\}/$ENV{ARTIFACT_ID} \/\/ ""/ge;
        s/\$\{MAIN_CLASS\}/$ENV{MAIN_CLASS} \/\/ ""/ge;
        s/\$\{FULL_MAIN_CLASS\}/$ENV{FULL_MAIN_CLASS} \/\/ ""/ge;
        s/\$\{BUILD_SYSTEM\}/$ENV{BUILD_SYSTEM} \/\/ ""/ge;
        s/\$\{LANGUAGE\}/$ENV{LANGUAGE} \/\/ ""/ge;
        s/\$\{KOTLIN_VERSION\}/$ENV{KOTLIN_VERSION} \/\/ ""/ge;
        s/\$\{DESCRIPTION\}/$ENV{DESCRIPTION} \/\/ ""/ge;
        s/\$\{WEBSITE\}/$ENV{WEBSITE} \/\/ ""/ge;
        s/\$\{VERSION\}/$ENV{VERSION} \/\/ ""/ge;
        s/\$\{LICENSE_ID\}/$ENV{LICENSE_ID} \/\/ ""/ge;
        s/\$\{GRADLE_AUTHORS_BLOCK\}/$ENV{GRADLE_AUTHORS_BLOCK} \/\/ ""/ge;
        s/\$\{MAVEN_AUTHORS_BLOCK\}/$ENV{MAVEN_AUTHORS_BLOCK} \/\/ ""/ge;
    ' "$1" > "$2"
}

convertTemplate() {
    mkdir -p "$OUT_DIR"
    cp -r "$TEMPLATE_DIR" "$TEMP_OUT_DIR"

    if [[ $USE_GIT == "false" ]]; then
        rm "$TEMP_OUT_DIR/.gitignore.mcgen"
    else
        convertFile "$TEMP_OUT_DIR/.gitignore.mcgen" "$OUT_DIR/.gitignore"
    fi

    if [[ $BUILD_SYSTEM == "gradle" ]]; then
        convertFile "$TEMP_OUT_DIR/build.gradle.kts.mcgen" "$OUT_DIR/build.gradle.kts"
        convertFile "$TEMP_OUT_DIR/gradle.properties.mcgen" "$OUT_DIR/gradle.properties"
        convertFile "$TEMP_OUT_DIR/settings.gradle.kts.mcgen" "$OUT_DIR/settings.gradle.kts"

        mkdir -p "$OUT_DIR/gradle/wrapper"
        convertFile "$TEMP_OUT_DIR/gradle-wrapper.properties.mcgen" "$OUT_DIR/gradle/wrapper/gradle-wrapper.properties"
    else
        convertFile "$TEMP_OUT_DIR/pom.xml.mcgen" "$OUT_DIR/pom.xml"

        mkdir -p "$OUT_DIR/src/main/resources/META-INF"
        convertFile "$TEMP_OUT_DIR/sponge_plugins.json.mcgen" "$OUT_DIR/src/main/resources/META-INF/sponge_plugins.json"
    fi


    if [[ $LANGUAGE == "java" ]]; then
        mkdir -p "$OUT_DIR/src/main/java/$PACKAGE_PATH"
        convertFile "$TEMP_OUT_DIR/MainClass.java.mcgen" "$OUT_DIR/src/main/java/$PACKAGE_PATH/$MAIN_CLASS.java"
    else
        mkdir -p "$OUT_DIR/src/main/kotlin/$PACKAGE_PATH"
        convertFile "$TEMP_OUT_DIR/MainClass.kt.mcgen" "$OUT_DIR/src/main/kotlin/$PACKAGE_PATH/$MAIN_CLASS.kt"
    fi

    rm -r "$TEMP_OUT_DIR"
}

makeGradleAuthorsBlock

makeMavenAuthorsBlock

convertTemplate

rm "$DATA_DIR/current.tmp"
rm "$DATA_DIR/output.tmp"
