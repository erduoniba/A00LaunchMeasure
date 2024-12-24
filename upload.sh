#!/bin/bash

git stash
git pull origin master --tags
git stash pop

VersionString=`grep -E 's.version.*=' CTMediator.podspec`
echo "VersionString: ${VersionString}"
VersionNumber=`tr -cd 0-9 <<<"$VersionString"`
NewVersionNumber=$(($VersionNumber + 1))
echo "NewVersionNumber: ${NewVersionNumber}"

LineNumber=`grep -nE 's.version.*=' CTMediator.podspec | cut -d : -f1`

git add .
git commit -am modification
git pull origin master --tags

sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" A00LaunchMeasure.podspec

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"

git commit -am ${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin master --tags
pod trunk push ./A00LaunchMeasure.podspec --verbose --use-libraries --allow-warnings