#!/bin/sh
# Credit: https://gist.github.com/willprice/e07efd73fb7f13f917ea

#看云版本库地址:
KY_REPO=https://git.kancloud.cn/evcard_cd/zhidu_evcard_cd.git
#github仓库地址：
GH_REPO=https://github.com/ERIC-HR/kanyun.git

KY_REPO_URL=https://${KANCLOUD_USER}:${KANCLOUD_PASS}@$(echo $KY_REPO | awk -F'//' '{print $2}')
GH_REPO_URL=https://${GITHUB_TOKEN}@$(echo $GH_REPO | awk -F'//' '{print $2}')

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  rm -rf *
  git clone $KY_REPO_URL
  repo_dir=$(ls) && cp -rf $repo_dir/* ./ &&  rm -rf $repo_dir
}

commit_country_json_files() {
  git checkout master
  # Current month and year, e.g: Apr 2018
  dateAndMonth=`date "+%b %Y"`
  # Stage the modified files in dist/output
  git add -A
  # Create a new commit with a custom build message
  # with "[skip ci]" to avoid a build loop
  # and Travis build number for reference
  git commit -m "Travis update: $dateAndMonth (Build $TRAVIS_BUILD_NUMBER)" -m "[skip ci]"
}

upload_files() {
  # Remove existing "origin"
  git remote rm origin
  # Add new "origin" with access token in the git URL for authentication
  git remote add origin $GH_REPO_URL > /dev/null 2>&1
  git push origin master --quiet
}

setup_git

commit_country_json_files

# Attempt to commit to git only if "git commit" succeeded
if [ $? -eq 0 ]; then
  echo "A new commit with changed country JSON files exists. Uploading to GitHub"
  upload_files
else
  echo "No changes in country JSON files. Nothing to do"
fi
