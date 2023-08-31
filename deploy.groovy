import groovy.yaml.YamlSlurper

def infraContent = new File("infra.yaml").text

def conf = new YamlSlurper().parseText(infraContent)

conf.modules.each{
    def module = it.name
    def vercel_proxy = it.vercel_proxy
    def proc = "/bin/bash -c cd ${module} ; okteto deploy".execute()
    def processLog = new StringBuffer()
    println "[INFO] Deploying ${module}"
    proc.waitForProcessOutput(processLog, System.err)
    proc.waitFor()
    if (proc.exitValue() != 0) {
        println "[ERROR] Failed to deploy ${module}"
    }
    else {
        println "[INFO] Successfully deployed ${module}"
    }
}
