#!/bin/bash

git stash
git pull origin master --tags
git stash pop

VersionString=`grep -E 's.version.*=' A00LaunchMeasure.podspec`

# 获取版本信息，譬如：'0.1.3'
VersionNumber=`echo $VersionString | awk -F"'" '{print $2}'`

# 使用 IFS 将版本号分割成数组
# major:0 minor:1 patch:3
IFS='.' read -r major minor patch <<< "$VersionNumber"
# 将补丁版本加 1
patch=$((patch + 1))

# 重新组合版本号
NewVersionNumber="$major.$minor.$patch"
echo "NewVersionNumber: ${NewVersionNumber}"

LineNumber=`grep -nE 's.version.*=' A00LaunchMeasure.podspec | cut -d : -f1`

git add .
git commit -m $1
git pull origin master --tags

sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" A00LaunchMeasure.podspec

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"

git commit -am ${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin master --tags
pod trunk push ./A00LaunchMeasure.podspec --verbose --use-libraries --allow-warnings