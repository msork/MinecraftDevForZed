#!/bin/bash

# DO NOT CHANGE!!
GROUP="plugin"
PLUGIN_TYPE="sponge"
JDK_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)
CONFIG_FILE="$HOME/.config/mcgen/defaults.json"
PROJECTS_DIR="$HOME/.local/share/mcgen/projects"
DESCRIPTION="My plugin description"
SEMVER_REGEX='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

if [[ ! -t 0 ]]; then
    exit 1
fi

getDefaults() {
    if [ -f $CONFIG_FILE ]; then
        GROUP_ID=$(jq -r '.GROUP_ID' "$CONFIG_FILE")
        WEBSITE=$(jq -r '.WEBSITE' "$CONFIG_FILE")
        LICENSE_ID=$(jq -r '.LICENSE_ID' "$CONFIG_FILE")
        mapfile -t AUTHORS < <(jq -r '.AUTHORS[]' "$CONFIG_FILE")
    else
        echo "Error: You have not run mcinit.sh properly from where you installed the MinecraftDevForZed repo. Please follow the guide here to reinstall mcgen:"
        echo "https://github.com/msork/MinecraftDevForZed?tab=readme-ov-file#initial-setup-for-unix-platforms-linux--mac--freebsd"
        exit 1
    fi
}

getSpongeVersions() {
    mapfile -t SPONGEAPI_VERSIONS < <(
      curl -s https://jd.spongepowered.org/ \
        | awk '/SpongeAPI/{flag=1} /modlauncher-injector-junit/{flag=0} flag' \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-SNAPSHOT)?' \
        | grep -v '^8\.2\.0-SNAPSHOT$' \
        | sort -Vu \
        | awk '$0 == "8.2.0" {start=1} start'
    )
}

chooseSpongeVersion() {
    read -r -p "Which Sponge API Version would you like to use? " SPONGEAPI_VERSION
    shopt -s nocasematch

    for TEMP_VERSION in "${SPONGEAPI_VERSIONS[@]}"; do
        if [[ $SPONGEAPI_VERSION == "$TEMP_VERSION" ]]; then
            SPONGEAPI_VERSION="$TEMP_VERSION"
            return
        fi
    done

    echo "Version \"$SPONGEAPI_VERSION\" not valid. Please use one of the following versions:"
    printf '%s\n' "${SPONGEAPI_VERSIONS[@]}"
}

checkJavaVersion() {
    SPONGEAPI_MAJOR=$(echo $SPONGEAPI_VERSION 2>&1 | cut -d. -f1)
    if (( SPONGEAPI_MAJOR >= 11 )); then
        JAVA_VERSION=21
    elif (( SPONGEAPI_MAJOR >= 9 )); then
        JAVA_VERSION=17
    elif (( SPONGEAPI_MAJOR >= 8 )); then
        JAVA_VERSION=16
    else
        JAVA_VERSION=8
    fi

    if (( JDK_VERSION != JAVA_VERSION )); then
        echo "Error: Please adjust your installed Java Version to be OpenJDK Version $JAVA_VERSION for proper Sponge API Version $SPONGEAPI_VERSION support." >&2
        exit 1
    fi
}

chooseGroupID() {
    while :; do
        read -r -p "What would you like to be the Group ID for your project and future projects? " GROUP_ID
        if [[ $GROUP_ID =~ ^[A-Za-z_] ]]; then
            jq --arg v "$GROUP_ID" '.GROUP_ID = $v' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            return
        else
            echo "Group ID must start with a letter (A-Z, a-z) or underscore (_)."
        fi
    done
}

chooseBuildProperties() {
    while :; do
        if [[ $GROUP_ID == "com.example" ]]; then
            read -r -p "Currently the Group ID for all projects is \"$GROUP_ID\". Keep it? [y/N] " choice

            shopt -s nocasematch
            case $choice in
                n | $null)
                    chooseGroupID
                    break
                    ;;
                y)
                    break
                    ;;
                *)
                    echo "Invalid choice. Please choose 'y' or 'n'."
                    ;;
            esac
            shopt -u nocasematch
        else
            read -r -p "Currently the Group ID for all projects is \"$GROUP_ID\". Keep it? [Y/n] " choice

            shopt -s nocasematch
            case $choice in
                n)
                    chooseGroupID
                    break
                    ;;
                y | $null)
                    break
                    ;;
                *)
                    echo "Invalid choice. Please choose 'y' or 'n'."
                    ;;
            esac
            shopt -u nocasematch
        fi
    done

    echo "Okay. Applying \"$GROUP_ID\" as your Group ID."

    read -r -p "What would you like to call your project? " PROJECT_NAME
    echo "Okay. Applying \"$PROJECT_NAME\" to your Project Name, Plugin Name, Plugin ID, Artifact ID, and Main Class Name."

    PLUGIN_NAME="$PROJECT_NAME"
    PLUGIN_ID=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')
    ARTIFACT_ID=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
    MAIN_CLASS=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/.*/\u&/' | sed 's/ /_/g')

    while :; do
        read -r -p "Currently the Plugin Name is \"$PLUGIN_NAME\" Keep it? [Y/n] " choice

        shopt -s nocasematch
        case $choice in
            n)
                read -r -p "What would you like to have as your Plugin Name? " PLUGIN_NAME
                echo "Okay. Applying \"$PLUGIN_NAME\" as your Plugin Name."
                break
                ;;
            y | $null)
                break
                ;;
            *)
                echo "Invalid choice. Please choose 'y' or 'n'."
                ;;
        esac
        shopt -u nocasematch
    done

    while :; do
        read -r -p "Currently the Plugin ID is \"$PLUGIN_ID\" Keep it? [Y/n] " choice

        shopt -s nocasematch
        case $choice in
            n)
                read -r -p "What would you like to have as your Plugin ID? " PLUGIN_ID
                PLUGIN_ID=$(printf '%s' "$PLUGIN_ID" \
                  | tr '[:upper:]' '[:lower:]' \
                  | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g')
                echo "Okay. Applying \"$PLUGIN_ID\" as your Plugin ID."
                break
                ;;
            y | $null)
                break
                ;;
            *)
                echo "Invalid choice. Please choose 'y' or 'n'."
                ;;
        esac
        shopt -u nocasematch
    done

    while :; do
        read -r -p "Currently the Artifact ID is \"$ARTIFACT_ID\" Keep it? [Y/n] " choice

        shopt -s nocasematch
        case $choice in
            n)
                read -r -p "What would you like to have as your Artifact ID? " ARTIFACT_ID
                ARTIFACT_ID=$(printf '%s' "$ARTIFACT_ID" \
                  | tr '[:upper:]' '[:lower:]' \
                  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
                echo "Okay. Applying \"$ARTIFACT_ID\" as your Artifact ID."
                break
                ;;
            y | $null)
                break
                ;;
            *)
                echo "Invalid choice. Please choose 'y' or 'n'."
                ;;
        esac
        shopt -u nocasematch
    done


    while :; do
        read -r -p "Currently the Main Class Name is \"$MAIN_CLASS\" in \"$GROUP_ID.$PLUGIN_ID\". Keep it? [Y/n] " choice

        shopt -s nocasematch
        case $choice in
            n)
                read -r -p "What would you like to have as your Main Class Name? " MAIN_CLASS
                MAIN_CLASS=$(printf '%s' "$MAIN_CLASS" \
                  | tr '[:upper:]' '[:lower:]' \
                  | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g' \
                  | sed 's/^./\u&/')
                echo "Okay. Applying \"$GROUP_ID.$PLUGIN_ID.$MAIN_CLASS\" as your Main Class."
                break
                ;;
            y | $null)
                break
                ;;
            *)
                echo "Invalid choice. Please choose 'y' or 'n'."
                ;;
        esac
        shopt -u nocasematch
    done

    FULL_MAIN_CLASS="$GROUP_ID.$PLUGIN_ID.$MAIN_CLASS"
}

chooseBuildSystem() {
    if [[ $BUILD_SYSTEM != $null ]]; then
        echo "Please try again. Type either \"gradle\" or \"maven\"."
    fi
    read -r -p "Would you like to use Gradle or Maven? " BUILD_SYSTEM
    shopt -s nocasematch
    case $BUILD_SYSTEM in
        Gradle)
            BUILD_SYSTEM="gradle"
            ;;
        Maven)
            BUILD_SYSTEM="maven"
            ;;
    esac
    shopt -u nocasematch
}

chooseLanguage() {
    if [[ $LANGUAGE != $null ]]; then
        echo "Please try again. Type either \"java\" or \"kotlin\"."
    fi
    read -r -p "Would you like to use Java or Kotlin? " LANGUAGE
    shopt -s nocasematch
    case $LANGUAGE in
        Java)
            LANGUAGE="java"
            ;;
        Kotlin)
            LANGUAGE="kotlin"
            ;;
    esac
    shopt -u nocasematch
}

getKotlinVersions() {
    mapfile -t KOTLIN_VERSIONS < <(
      curl -s https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-jdk8/maven-metadata.xml \
          | grep -oP '(?<=<version>)[^<]+' \
          | sort -Vu \
          | awk '$0 ~ /^2\.0\.21(-RC)?$/ {start=1} start'
    )

    KOTLIN_VERSION=$(
      curl -s https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-jdk8/maven-metadata.xml \
      | grep -oP '(?<=<latest>)[^<]+'
    )
}

chooseKotlinVersion() {
    read -r -p "Which Kotlin Version would you like to use? " KOTLIN_VERSION
    shopt -s nocasematch

    for TEMP_VERSION in "${KOTLIN_VERSIONS[@]}"; do
        if [[ $KOTLIN_VERSION == "$TEMP_VERSION" ]]; then
            KOTLIN_VERSION="$TEMP_VERSION"
            return
        fi
    done

    echo "Version \"$KOTLIN_VERSION\" not valid. Please use one of the following versions:"
    printf '%s\n' "${KOTLIN_VERSIONS[@]}"
}

addAuthors() {
    if [[ -n "${AUTHORS[0]}" ]]; then
        while :; do
            echo "Currently you have $(jq '.AUTHORS | length' "$HOME/.config/mcgen/defaults.json") author(s):"
            printf '%s\n' "${AUTHORS[@]}"
            read -r -p "Would you like to edit the authors for this and future projects? [y/N] " choice
            case $choice in
                y)
                    break
                    ;;
                n | $null)
                    return
                    ;;
                *)
                    echo "Invalid choice. Please choose 'y' or 'n'."
                    ;;
            esac
        done
    fi

    num=1

    while :; do
        read -r -p "What is Author #$num's name? " AUTHOR
        if [[ $num == 1 ]]; then
            AUTHORS=("$AUTHOR")
            jq --arg v "$AUTHOR" '.AUTHORS = [$v]' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        else
            AUTHORS+=("$AUTHOR")
            jq --arg v "$AUTHOR" '.AUTHORS += [$v]' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        fi
        while :; do
            read -r -p "Add another author? [y/N] " choice

            case $choice in
                y)
                    ((num++))
                    break
                    ;;
                n | $null)
                    return
                    ;;
                *)
                    echo "Invalid choice. Please choose 'y' or 'n'."
                    ;;
            esac
        done
    done
}

chooseLicense() {
     LICENSE_IDS=(
        "AGPL-3.0"
        "All-Rights-Reserved"
        "Apache-2.0"
        "BSD-2-Clause-FreeBSD"
        "BSD-3-Clause"
        "GPL-3.0"
        "ISC"
        "LGPL-3.0"
        "MIT"
        "MPL-2.0"
        "Unlicense"
    )

    echo "Choose a license out of these following licenses for this and all future projects: "

    for i in "${!LICENSE_IDS[@]}"; do
        printf "%2d) %s\n" "$((i+1))" "${LICENSE_IDS[i]}"
    done

    while :; do
        read -r -p "Enter number: " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#LICENSE_IDS[@]} )); then
            LICENSE_ID="${LICENSE_IDS[choice-1]}"
            jq --arg v "$LICENSE_ID" '.LICENSE_ID = $v' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            break
        else
            echo "Invalid selection."
        fi
    done
}

getDefaults

getSpongeVersions

shopt -s nocasematch
while [[ ! " ${SPONGEAPI_VERSIONS[*]} " =~ " ${SPONGEAPI_VERSION} " ]]; do
    chooseSpongeVersion
done
echo "Chosen to use $SPONGEAPI_VERSION as the Sponge API Version for this project."

checkJavaVersion

shopt -s nocasematch

while [[ $PROJECT_NAME == $null || $PLUGIN_NAME == $null || $PLUGIN_ID == $null || $ARTIFACT_ID == $null || $MAIN_CLASS == $null ]]; do
    chooseBuildProperties
    if [[ $PROJECT_NAME != $null && $PLUGIN_NAME != $null && $PLUGIN_ID != $null && $ARTIFACT_ID != $null && $MAIN_CLASS != $null ]]; then
        break
    else
        echo "Invalid Build Properties. Please recreate it."
    fi
done

while [[ $BUILD_SYSTEM != "gradle" && $BUILD_SYSTEM != "maven" ]]; do
    chooseBuildSystem
done
echo "Chosen to use $BUILD_SYSTEM as the Build System for this project."

while [[ $LANGUAGE != "java" && $LANGUAGE != "kotlin" ]]; do
    chooseLanguage
done
echo "Chosen to use $LANGUAGE as the Language for this project."

shopt -u nocasematch

if [[ $LANGUAGE == "kotlin" ]]; then
    getKotlinVersions

    shopt -s nocasematch

    while :; do
        read -r -p "Chosen to use $KOTLIN_VERSION as the Kotlin Version for this project. Keep it? [Y/n] " choice

        case $choice in
            n)
                while [[ ! " ${KOTLIN_VERSIONS[*]} " =~ " ${KOTLIN_VERSION} " ]]; do
                    chooseKotlinVersion
                done
                echo "Chosen to use $KOTLIN_VERSION as the Kotlin Version for this project."
                break
                ;;
            y | $null)
                break
                ;;
            *)
                echo "Invalid choice. Please choose 'y' or 'n'."
                ;;
        esac
    done

    shopt -u nocasematch
fi

while :; do
    read -r -p "Would you like to add a Description? [y/N] " choice

    shopt -s nocasematch

    case $choice in
        y)
            read -r -p "What would you like the Description to be? " DESCRIPTION
            break
            ;;
        n | $null)
            break
            ;;
        *)
            echo "Invalid choice. Please choose 'y' or 'n'."
            ;;
    esac

    shopt -u nocasematch
done

while :; do
    read -r -p "Would you like to add a Version Number? [y/N] " choice

    shopt -s nocasematch

    case $choice in
        y)
            while :; do
                read -r -p "What would you like the Version to be? " VERSION

                if [[ $VERSION =~ $SEMVER_REGEX ]]; then
                    break
                else
                    echo "Invalid version. Use semantic versioning (example: 1.0.0)"
                fi
            done
            break
            ;;
        n | $null)
            break
            ;;
        *)
            echo "Invalid choice. Please choose 'y' or 'n'."
            ;;
    esac

    shopt -u nocasematch
done

while :; do
    read -r -p "Would you like to add any Authors for this and future projects? [y/N] " choice

    shopt -s nocasematch

    case $choice in
        y)
            addAuthors
            break
            ;;
        n | $null)
            break
            ;;
        *)
            echo "Invalid choice. Please choose 'y' or 'n'."
            ;;
    esac

    shopt -u nocasematch
done

while :; do
    if [[ $WEBSITE != "" ]]; then
        echo "Currently your Website is saved as: \"$WEBSITE\""
        read -r -p "Would you like to change or remove your Website for this and future projects? [y/N] " choice
    else
        read -r -p "Would you like to add a Website for this and future projects? [y/N] " choice
    fi

    shopt -s nocasematch

    case $choice in
        y)
            read -r -p "What would you like the Website to be? (Press Enter for no website) " WEBSITE
            jq --arg v "$WEBSITE" '.WEBSITE = $v' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            break
            ;;
        n | $null)
            break
            ;;
        *)
            echo "Invalid choice. Please choose 'y' or 'n'."
            ;;
    esac

    shopt -u nocasematch
done

while :; do
    read -r -p "Chosen to use $LICENSE_ID as the License ID for this and all future projects. Keep it? [Y/n] " choice

    case $choice in
        n)
            chooseLicense
            echo "Chosen to use $LICENSE_ID as the License ID for this and all future projects."
            break
            ;;
        y | $null)
            break
            ;;
        *)
            echo "Invalid choice. Please choose 'y' or 'n'."
            ;;
    esac
done

while :; do
    read -r -p "Use Git? [y/N] " choice
    case $choice in
        y)
            USE_GIT=true
            break
            ;;
        n | $null)
            USE_GIT=false
            break
            ;;
        *)
            echo "Invalid choice. Please choose 'y' or 'n'."
            ;;
    esac
done


shopt -u nocasematch

DATA_FILE="$PROJECTS_DIR/$PROJECT_NAME.json"

mkdir -p "$PROJECTS_DIR"

AUTHORS_JSON=$(printf '%s\n' "${AUTHORS[@]}" | jq -R . | jq -s .)

jq -n \
  --arg GROUP "$GROUP" \
  --arg PLUGIN_TYPE "$PLUGIN_TYPE" \
  --arg JDK_VERSION "$JDK_VERSION" \
  --arg SPONGEAPI_VERSION "$SPONGEAPI_VERSION" \
  --arg GROUP_ID "$GROUP_ID" \
  --arg PROJECT_NAME "$PROJECT_NAME" \
  --arg PLUGIN_NAME "$PLUGIN_NAME" \
  --arg PLUGIN_ID "$PLUGIN_ID" \
  --arg ARTIFACT_ID "$ARTIFACT_ID" \
  --arg MAIN_CLASS "$MAIN_CLASS" \
  --arg FULL_MAIN_CLASS "$FULL_MAIN_CLASS" \
  --arg BUILD_SYSTEM "$BUILD_SYSTEM" \
  --arg LANGUAGE "$LANGUAGE" \
  --arg KOTLIN_VERSION "$KOTLIN_VERSION" \
  --arg DESCRIPTION "$DESCRIPTION" \
  --arg WEBSITE "$WEBSITE" \
  --arg VERSION "$VERSION" \
  --arg LICENSE_ID "$LICENSE_ID" \
  --arg USE_GIT "$USE_GIT" \
  --argjson AUTHORS "$AUTHORS_JSON" \
  '$ARGS.named + {AUTHORS: $AUTHORS}' \
  > "$DATA_FILE"

echo "Saved configuration to $DATA_FILE."

echo "$PROJECT_NAME" > "$PROJECTS_DIR/../current.tmp"
