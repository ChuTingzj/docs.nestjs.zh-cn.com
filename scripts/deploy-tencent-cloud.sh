#!/usr/bin/env sh

uri='git@gitee.com:ChuTingzj/docs.nestjs.zh-cn.com.git'

rm -rf dist
npm run build:prod
cd dist || exit
git init
git remote add origin $uri
git add .
git commit -m "push"
git push origin master --force
