resource "grafana_rule_group" "kube_state_metrics_errors" {
  count           = var.kube_state_metrics_errors_alerts_enabled ? 1 : 0
  name             = "kube_state_metrics_errors"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # Alert: KubeStateMetricsListErrors
  rule {
    name      = "KubeStateMetricsListErrors"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(sum(rate(kube_state_metrics_list_total{job="kube-state-metrics",result="error"}[5m])) by (cluster)
  /
sum(rate(kube_state_metrics_list_total{job="kube-state-metrics"}[5m])) by (cluster))
> 0.01
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "kube-state-metrics is experiencing errors at an elevated rate in list operations. This is likely causing it to not be able to expose metrics about Kubernetes objects correctly or at all."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricslisterrors"
      summary     = "kube-state-metrics is experiencing errors in list operations."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["cluster"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Alert: KubeStateMetricsWatchErrors
  rule {
    name      = "KubeStateMetricsWatchErrors"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics",result="error"}[5m])) by (cluster)
  /
sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics"}[5m])) by (cluster))
> 0.01
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "kube-state-metrics is experiencing errors at an elevated rate in watch operations. This is likely causing it to not be able to expose metrics about Kubernetes objects correctly or at all."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricswatcherrors"
      summary     = "kube-state-metrics is experiencing errors in watch operations."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["cluster"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    # Alert: KubeStateMetricsShardingMismatch
  rule {
    name      = "KubeStateMetricsShardingMismatch"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
stdvar (kube_state_metrics_total_shards{job="kube-state-metrics"}) by (cluster) != 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "kube-state-metrics pods are running with different --total-shards configuration, some Kubernetes objects may be exposed multiple times or not exposed at all."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricsshardingmismatch"
      summary     = "kube-state-metrics sharding is misconfigured."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["cluster"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Alert: KubeStateMetricsShardsMissing
  rule {
    name      = "KubeStateMetricsShardsMissing"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
2^max(kube_state_metrics_total_shards{job="kube-state-metrics"}) by (cluster) - 1
  -
sum( 2 ^ max by (cluster, shard_ordinal) (kube_state_metrics_shard_ordinal{job="kube-state-metrics"}) ) by (cluster)
!= 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "kube-state-metrics shards are missing, some Kubernetes objects are not being exposed."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricsshardsmissing"
      summary     = "kube-state-metrics shards are missing."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["cluster"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
