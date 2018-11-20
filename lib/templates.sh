function templates::log4j2_yaml {
  cat <<-'EOF' > "${1}/${2}"
Configuration:
  Appenders:
    Console:
      PatternLayout:
        Pattern: '%d{yyyy-MMM-dd HH:mm:ss a} - %msg%n'
      name: STDOUT
      target: SYSTEM_OUT
  Loggers:
    Root:
      AppenderRef:
        - ref: STDOUT
      level: warn
    Logger:
      - name: com.springframework.beans
        level: error
        additivity: false
        AppenderRef:
          - ref: STDOUT
      - name: com.springframework.boot
        level: error
        additivity: false
        AppenderRef:
          - ref: STDOUT
      - name: com.springframework.core
        level: error
        additivity: false
        AppenderRef:
          - ref: STDOUT
EOF
}

function templates::app_yaml {
  cat <<-'EOF' > "${1}/${2}"
spring:
  flyway:
    enabled: true
    baseline-version: 0
    sql-migration-prefix: v
    baselineOnMigrate: true
  jpa:
    show-sql: true
    generate-ddl: false

---

spring:
  profiles: dev

---

spring:
  profiles: test
EOF
}

function templates::config_tasks {
  cat <<-'EOF'
tasks.withType(JavaExec) {
    systemProperties System.properties
}

EOF
}

function templates::javadoc_task {
  cat <<-'EOF'
javadoc {
    source sourceSets.main.allJava

    title = 'Service Template Documentation'
    options.linkSource = true
    options.links = ['https://docs.oracle.com/javase/8/docs/api/', 'https://docs.spring.io/spring-boot/docs/current/api/']
    options.footer = "Generated on ${new Date().format('dd MMM yyyy')}"
    options.header = "Documentation for version ${project.version}"

    failOnError false
}

EOF
}

function templates::soap_import_task {
  cat <<-'EOF'
task wsimport {
    group 'Build'
    description 'Makes SOAP classes.'

    ext.groupName = 'com.capgroup.esi.finance'
    ext.artifactName = 'pershing.soap.entities'
    ext.sourcesDir = file("${sourceSets.main.java.srcDirs[0]}")
    // TODO: Add SOAP 'key-value' pair, where 'key' is package name and 'value' is WSDL URL.
    ext.wsdlMap = ['': '']

    outputs.dir sourceSets.main.output.classesDir

    doLast {
        // Make class output directories.
        sourceSets.main.output.classesDir.mkdirs()

        ant {
            taskdef(name: 'wsimport', classname: 'com.sun.tools.ws.ant.WsImport', classpath: configurations.jaxws.asPath)
            wsdlMap.each {
                packageName, schema ->
                    wsimport(keep: true, encoding: "UTF-8", destdir: sourceSets.main.output.classesDir, sourcedestdir: sourcesDir, package: "${groupName}.${artifactName}.${packageName}", wsdl: schema)
            }
        }
    }
}

wsimport.onlyIf {
    // TODO: Provide full path to entities generated from WSDL
    String path = "${groupName}/${artifactName}".replaceAll("\\.", "/")
    File entities = file("${sourceSets.main.java.srcDirs[0]}/${path}")
    return (entities.exists() && entities.list().length > 0)
}

compileJava {
    dependsOn wsimport
}

EOF
}

function templates::build_tasks {
  templates::config_tasks
  templates::javadoc_task

  if [[ $xml == 0 ]]; then
    templates::soap_import_task
  fi
}

function templates::build_dependencies {
  templates::runtime_deps
  templates::compile_deps
  templates::test_compile_deps

  if [[ $xml == 0 ]]; then
    templates::jaxws_deps
  fi
}
