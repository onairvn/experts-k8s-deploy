# experts-k8s-deploy

GitOps values + ArgoCD Application manifests for **experts_marketplace** on the FKE dev cluster (`experts-dev` namespace). ArgoCD tracks `main`.

## Layout
- `be-api/dev/values.yaml`      — BE HTTP API (Helm chart `lemon`)
- `be-worker/dev/values.yaml`   — BE BullMQ worker
- `cms/dev/values.yaml`         — CMS (Vite + nginx)
- `fe/dev/values.yaml`          — FE (Next.js)
- `argocd/*.yaml`               — 4 ArgoCD Applications (multi-source: lemon chart + these values)
- `edit.sh`                     — tag bumper used by CI (`./edit.sh <svc>/dev/values.yaml <container> <tag>`)

## Flow
App repo push to `dev` → GitHub Actions build+push image to FKE Harbor → CI bumps `tag:` here (`main`) → ArgoCD syncs `experts-dev`.

Images: `registry-hn02.fke.fptcloud.com/344af395-857e-4e68-83ea-3972784eb4cb/experts-{be,cms,fe}`.
