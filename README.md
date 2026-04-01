# Singe instance GZCTF deployment

- Auto k3s installation if k3s is not presented
- Traefik, kube-config, etc managed by script
- No redis, psql, gzctf-server
- Traefik configured to use Let's Encrypt and XFF
- All secrets and relevant configs in .env file

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
You can then safely rerun `./deploy.sh`

---

If you accidentaly use `''` in POSTGRES_PASSWORD in `.env` (like `POSTGRES_PASSWORD='password'`): 
```
sudo kubectl exec -it -n gzctf-server deployment/gzctf-db -- psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'password';"
```
That will delete `''` from database password. \
Or you can just rm the mountpoint/pv's/pvc's. \
That will (potentialy) not work with `ADMIN_PASSWORD` variable. It is also gonna be stored in the database, so if you do this with admin password - just change it via web service itself.

---

Host files changed:
```
/mnt/data/gzctf/files
/mnt/data/gzctf/db
/var/lib/rancher/k3s/server/manifests/traefik-config.yaml
/etc/rancher/k3s/config.yaml
/etc/rancher/k3s/registries.yaml
```
