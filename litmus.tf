resource "helm_release" "litmus-chaos" {
    name = "litmuschart"
    chart = "./charts/litmus"
}
