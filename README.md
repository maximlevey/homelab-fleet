<h1>FleetDM Docker</h1>

Update configurations in `.env`

```
cd fleetdm-docker
```

```
make setup
```

If using cloudflared tunnel, confirm `secrets/cloudfared.yml` configuration

```
make start
```

Access UI at `https://localhost:8080`
