import groovy.yaml.YamlSlurper

def infraContent = new File("infra.yaml").text

def conf = new YamlSlurper().parseText(infraContent)

def getApiToken() {
    def proc = "./get-api-token.sh".execute()
    def token = new StringBuffer()
    proc.waitForProcessOutput(token, token)
    return token
}

conf.modules.each {
    def module = it.name
}
