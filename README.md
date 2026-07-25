# experts-k8s-deploy

> ⚠️ **REPO NÀY PUBLIC — KHÔNG BAO GIỜ COMMIT SECRET VÀO ĐÂY.**
> Secret của cả dev lẫn prod được tạo trực tiếp trong cluster bằng
> `kubectl create secret --from-env-file`, không nằm trong git.

GitOps values + ArgoCD Application manifests cho **experts_marketplace** trên cụm FKE.
ArgoCD theo dõi nhánh `main`.

## Môi trường

| Env | Namespace | Nhánh trigger | Tag |
|---|---|---|---|
| dev | `experts-dev` | push `dev` | `dev-<run>-<sha>` |
| prod | `experts-prod` | push `main` | `prod-<run>-<sha>` |

## Layout
- `be-api/{dev,prod}/values.yaml`    — BE HTTP API (Helm chart `lemon`)
- `be-worker/{dev,prod}/values.yaml` — BE BullMQ worker
- `cms/{dev,prod}/values.yaml`       — CMS (Vite + nginx)
- `fe/{dev,prod}/values.yaml`        — FE (Next.js)
- `argocd/*.yaml`                    — 8 ArgoCD Application (4 dev + 4 prod)
- `edit.sh`                          — bump tag, dùng bởi CI

## Hosts

| | dev | prod |
|---|---|---|
| FE | experts-dev.onair.today | experts.onair.today |
| API | api.experts-dev.onair.today | api.experts.onair.today |
| CMS | cms.experts-dev.onair.today | cms.experts.onair.today |

## Sửa secret prod

Secret KHÔNG nằm trong repo này. Sửa trực tiếp trong cluster:

```bash
export KUBECONFIG=~/.kube/onair-dev-fke.yaml
kubectl -n experts-prod delete secret experts-be-env
kubectl -n experts-prod create secret generic experts-be-env --from-env-file=<file.env>
kubectl -n experts-prod rollout restart deploy/experts-be-api deploy/experts-be-worker
```

Pod không tự đọc lại secret khi secret đổi — luôn cần `rollout restart` sau khi tạo lại secret.

File env nguồn nằm ngoài git, chỉ trên máy vận hành, không có bản backup nào khác.
Cần đưa vào password manager sớm — đây là bản duy nhất.

## Rollback

```bash
git revert --no-edit <bump-sha> && git push origin main   # ArgoCD tự sync về tag cũ
```
