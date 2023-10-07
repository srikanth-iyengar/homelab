resource "helm_release" "litmus-chaos" {
    name = "litmus chart deployment"
    chart = "./charts/litmus"
}
