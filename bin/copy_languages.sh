#!/bin/sh
# mv ./src/lang/es/paths_es.json ./src/lang/es-ES/paths_es.json &&
# mv ./src/lang/pt/paths_pt.json ./src/lang/pt-PT/paths_pt.json &&
# mv ./src/lang/zh/paths_zh.json ./src/lang/zh-CN/paths_zh.json &&
rm -r ./src/lang/es &&
rm -r ./src/lang/pt &&
rm -r ./src/lang/zh &&
mv ./src/lang/es-ES ./src/lang/es &&
mv ./src/lang/pt-PT ./src/lang/pt &&
mv ./src/lang/zh-CN ./src/lang/zh
