#!/bin/sh
rm -rf ./tmp
mkdir tmp
cp -r src pom.xml tmp
pushd tmp

# delete database info if JPA or Mybatis2 is not used
grep "<artifactId>" pom.xml | head -1 | grep -E "jpa|mybatis2" >/dev/null
if [ $? -ne 0 ]; then
  sed -i -e '/Begin Database/,/End Database/d' pom.xml
  sed -i -e '/postgresql.version/d' pom.xml
  sed -i -e '/ojdbc.version/d' pom.xml
fi

# rename "projectName" in filename to replace by ${artifactId}
mv src/main/resources/META-INF/spring/projectName-domain.xml src/main/resources/META-INF/spring/__artifactId__-domain.xml
mv src/main/resources/META-INF/spring/projectName-infra.xml src/main/resources/META-INF/spring/__artifactId__-infra.xml
mv src/main/resources/META-INF/spring/projectName-codelist.xml src/main/resources/META-INF/spring/__artifactId__-codelist.xml

# if JPA or Mybatis2 is used
if [ -e src/main/resources/META-INF/spring/projectName-env.xml ];then
  mv src/main/resources/META-INF/spring/projectName-env.xml src/main/resources/META-INF/spring/__artifactId__-env.xml
fi
if [ -e src/main/resources/META-INF/spring/projectName-infra.properties ];then
  mv src/main/resources/META-INF/spring/projectName-infra.properties src/main/resources/META-INF/spring/__artifactId__-infra.properties
fi


sed -i -e "s/org\.terasoluna\.gfw\.blank/xxxxxx.yyyyyy.zzzzzz/g" pom.xml
sed -i -e "s/terasoluna-gfw-web-blank/projectName/g" pom.xml

rm -rf `find . -name '.svn' -type d`
mvn archetype:create-from-project

pushd target/generated-sources/archetype

sed -i -e "s/xxxxxx\.yyyyyy\.zzzzzz/org.terasoluna.gfw.blank/g" pom.xml
sed -i -e "s/projectName/terasoluna-gfw-web-blank/g" pom.xml
if [ "$1" = "deploy" ]; then
  mvn deploy
else
  mvn install
fi
