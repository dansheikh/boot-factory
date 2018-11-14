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
    ext.wsdlMap = ['ordering': 'https://xat-www.netxservice.inautix.com/soap/orderprocessing/1/wsdl/orderprocessing_12.wsdl']

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

EOF
}

function templates::build_tasks {
  templates::config_tasks
  templates::javadoc_task
  templates::soap_import_task
}
