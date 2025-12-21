#! /bin/bash
set -euo pipefail

# ------------------------------------------------------------------------
# Signs and bundles the JAR files for a package deployment to the Central
# Repository.
# 
# (C) 2023-2025 Sylvain Hallé
# Laboratoire d'informatique formelle, Université du Québec à Chicoutimi
# 
# Usage: ./sign-and-bundle.sh <passphrase>
# where <passphrase> is the passphrase required to access the GPG key
# ------------------------------------------------------------------------

# The name of the artifact to produce
GROUP_ID="io.github.liflab"
ARTIFACT_ID="beepbeep-palettes"
VERSION="3.13"
BASE="${ARTIFACT_ID}-${VERSION}"

# Sign each file; exit the script as soon as the operation fails for one
# of them
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $BASE.pom
if [ $? -ne 0 ]; then
	exit $?
fi
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $BASE.jar
if [ $? -ne 0 ]; then
	exit $?
fi
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $BASE-sources.jar
if [ $? -ne 0 ]; then
	exit $?
fi
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $BASE-javadoc.jar
if [ $? -ne 0 ]; then
	exit $?
fi

# Bundle into a zip. If we get here, all 4 files were successfully signed.

FILES=(
  "${BASE}.pom"
  "${BASE}.pom.asc"
  "${BASE}.jar"
  "${BASE}.jar.asc"
  "${BASE}-sources.jar"
  "${BASE}-sources.jar.asc"
  "${BASE}-javadoc.jar"
  "${BASE}-javadoc.jar.asc"
)

# 1) Stage Maven-repository layout
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

REPO_PATH="${STAGE}/$(echo "$GROUP_ID" | tr . /)/${ARTIFACT_ID}/${VERSION}"
mkdir -p "$REPO_PATH"

# Copy files
for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || { echo "Missing file: $f" >&2; exit 2; }
  cp "$f" "$REPO_PATH/"
done

# 2) Generate required checksums for every file in the repo path
(
  cd "$REPO_PATH"
  for f in *; do
    # md5
    md5sum "$f" | awk '{print $1}' > "${f}.md5"
    # sha1
    sha1sum "$f" | awk '{print $1}' > "${f}.sha1"
  done
)

# 3) Create the upload archive (paths relative to repo root, no ./)
OUT="${ARTIFACT_ID}-${VERSION}-central-bundle.zip"
(
  cd "$STAGE"
  zip -X -r "$OUT" .
)
mv $STAGE/$OUT .
echo "OK: created $OUT"
echo "Upload this ZIP to the Central Portal."
