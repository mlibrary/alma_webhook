(import 'ksonnet-util/kausal.libsonnet') +
(import './config.libsonnet') +
(import './envVar.libsonnet') +
{
  local deploy = $.apps.v1.deployment,
  local container = $.core.v1.container,
  local port = $.core.v1.containerPort,
  local ingress = $.extensions.v1beta1.ingress,

  local config = $._config.alma_webhook,
  local images = $._images.alma_webhook,

  alma_webhook: {
    web: {
      deployment: deploy.new(
        name=config.web.name,
        replicas=1,
        containers=[
          container.new(config.web.name, images.web)
          + container.withPorts(
            [port.new('ui', config.web.port)]
          ) + container.withEnv( $._envVar,),
        ]
      ),

      service: $.util.serviceFor(self.deployment) + $.core.v1.service.mixin.spec.withPorts($.core.v1.service.mixin.spec.portsType.newNamed(
        name=config.web.name,
        port=80,
        targetPort=config.web.port,
      )),
    },
  },
}
