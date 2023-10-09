resource "time_static" "litmus_updated" {
}
resource "helm_release" "litmus-chaos" {
  name      = "litmuschart"
  chart     = "./charts/litmus"
  namespace = "observability-suite-srikanth-iyengar"
  values = [
    "lastUpdated: ${timestamp()}",
    "namespace:  observability-suite-srikanth-iyengar"
  ]
}
