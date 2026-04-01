# Simplified singe node k3s GZCTF deployment

- Auto k3s installation if k3s is not presented
- Traefik, kube-config, etc. managed by deployment script
- Postgres 18 alpine, no redis, local pv mounts
- Traefik configured to use Let's Encrypt certs and XFF
- All secrets and relevant configs in .env file (something like single source of truth)

That's just works

---

To deploy, create `.env` file in the same directory as `config/env/.env.example`. \
Fill out the `.env` file, then:
```
chmod +x ./deploy.sh && ./deploy.sh
```

---

If you need to purge all:
```
sudo kubectl delete -k .
sudo rm -rf /mnt/data/gzctf
```
You can then safely re-run `deploy.sh` script

---

If you accidentaly use `''` in `POSTGRES_PASSWORD` in `.env` (like `POSTGRES_PASSWORD='password'`) you can change it manually: 
```
sudo kubectl exec -it -n gzctf-server deployment/gzctf-db -- psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'password';"
```
It will delete `''` from the database password. \
Or you can just rm the mountpoint/pv's/pvc's. \
It will not work on `ADMIN_PASSWORD` variable. It is also gonna be stored in the database, so if you do this with the admin password - just change it via web service itself.

---

Host files changed:
```
/mnt/data/gzctf/files
/mnt/data/gzctf/db
/var/lib/rancher/k3s/server/manifests/traefik-config.yaml
/etc/rancher/k3s/config.yaml
/etc/rancher/k3s/registries.yaml
```

TODO:
- Tests
- Postgres mount point expansion
- Postgres image fixation on 18.3
- Version fixation (k3s, ps, traefik?...)

