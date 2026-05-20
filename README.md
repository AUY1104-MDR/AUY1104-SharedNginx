# AUY1104-SharedNginx

Repositorio dedicado al **servicio nginx** desplegado en k3s para la Evaluación Sumativa 2 (AUY1104 — Ciclo de Vida del Software II).

Cubre el requisito de la sección 5 de la pauta: servicio nginx expuesto vía NodePort en el puerto **30080**.

## Contenido del repositorio

| Ruta | Propósito |
|---|---|
| `Dockerfile` | Imagen basada en `nginx:1.27-alpine`. nginx escucha internamente en `30080`. |
| `index.html` | Página estática personalizada que sirve el contenedor. |
| `k8s/deployment.yml` | `Deployment` con estrategia `RollingUpdate`, `livenessProbe` y `readinessProbe`. La imagen se inyecta vía `IMAGE_PLACEHOLDER`. |
| `k8s/service.yml` | `Service` tipo `NodePort` en el puerto `30080`. |
| `.github/workflows/deploy.yml` | Pipeline CI/CD: build de la imagen, push a Docker Hub y despliegue por SSH al nodo k3s. |

## Flujo CI/CD

```
push tag v*
   ↓
Build Docker (nginx-custom:<tag> + :latest)
   ↓
Push a Docker Hub
   ↓
SCP de manifiestos al servidor k3s
   ↓
sed → kubectl apply → rollout status → curl :30080
```

Disparador único: `push` de un tag `v*` (ej. `v0.0.1`). El versionamiento es obligatorio y no se permite ejecución manual.

Secrets/Variables necesarios:
- `secrets.DOCKER_USERNAME` / `secrets.DOCKER_PASSWORD` (organización)
- `secrets.EA2_SSH_PRIVATE_KEY` (organización)
- `vars.K3S_SERVER_PUBLIC_IP` (variable de repo)

## URL esperada

```
http://<IP_PUBLICA_SERVIDOR>:30080
```

## Imagen publicada

- Docker Hub: `marcdelrio/nginx-custom`
- Tags: el del push (`v0.0.x`) y `latest`.

## Rollback

```bash
# 1. Volver a la revisión anterior del Deployment
kubectl rollout undo deployment/nginx-30080
kubectl rollout history deployment/nginx-30080

# 2. Re-aplicar un tag previo desde Docker Hub
kubectl set image deployment/nginx-30080 \
    nginx=marcdelrio/nginx-custom:v0.0.1
kubectl rollout status deployment/nginx-30080
```

## Verificación manual

```bash
kubectl get pods -l app=nginx-30080 -o wide
kubectl get svc nginx-svc-30080
curl http://<IP_PUBLICA>:30080
```
