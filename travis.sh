#!/bin/sh

download_wbtmx() {
  cd ../..
  git clone https://github.com/wasabibit/WBTMXTool.git
  cd ${TRAVIS_REPO_SLUG}
}

run_wbtmx() {
  WBTMXTool=../../WBTMXTool/WBTMXTool

  if [ "${ACTION}" = "clean" ]
  then
  echo "cleaning..."
  else

  echo "*** Convert HDR TMX files to HD and SD..."

  for file in Resources/img/HDR/*.tmx
  do
        infile="$file"
        outfile=$(basename "$file" ".tmx")
        outfileHD="Resources/img/HD/$outfile.tmx"
        outfileSD="Resources/img/SD/$outfile.tmx"
        echo "Input HDR TMX File: $infile"
        echo "Output SD TMX File: $outfileSD"
        echo "Output HD TMX File: $outfileHD"
  ${WBTMXTool} -in $infile -out $outfileSD -scale 0.25
  ${WBTMXTool} -in $infile -out $outfileHD -scale 0.5
  done
  fi

}

download_spritesheetpacker() {
  cd ../..
  wget https://github.com/amakaseev/sprite-sheet-packer/releases/download/1.0.9/SpriteSheetPacker-Installer.dmg
  cd ${TRAVIS_REPO_SLUG}
}

setup_spritesheetpacker() {
  cd ../..
  sudo hdiutil attach SpriteSheetPacker-Installer.dmg
  sudo cp -R /Volumes/SpriteSheet\ Packer/SpriteSheetPacker.app /Applications
  cd ${TRAVIS_REPO_SLUG}
}

run_spritesheetpacker() {
  cd art
  /Applications/SpriteSheetPacker.app/Contents/MacOS/SpriteSheetPacker characters.ssp
  /Applications/SpriteSheetPacker.app/Contents/MacOS/SpriteSheetPacker menu.ssp
  cd ..
}

setup_git() {
  git config --global user.email "funkyzooink@gmail.com"
  git config --global user.name "Travis CI"
}

commit_files() {
  git checkout -b resources_update
  git add . 
  git commit -m "[skip ci] Travis tmx and spritesheet update: $TRAVIS_BUILD_NUMBER"
  git checkout master
  git merge --squash resources_update
  git merge resources_update
}

upload_files() {
  git remote add github https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git > /dev/null 2>&1
  git push --quiet --set-upstream github master
}


download_wbtmx
run_wbtmx
download_spritesheetpacker
setup_spritesheetpacker
run_spritesheetpacker
setup_git
commit_files
upload_files
