{{flutter_js}}
{{flutter_build_config}}

const loadingElement = document.getElementById('loading');

window.addEventListener(
  'flutter-first-frame',
  () => {
    loadingElement?.remove();
  },
  { once: true },
);

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  config: {
    canvasKitBaseUrl: 'canvaskit/',
  },
});
