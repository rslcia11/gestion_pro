# Migración fidelity-app: Supabase Cloud → AWS EC2 (self-hosted)

**Estado: ✅ Migración funcional completa.** Falta configuración de push y apuntar la app.
**Fecha:** 2026-07-22 · **Última verificación:** todos los datos restaurados y validados.

---

## 1. Resumen ejecutivo

Se migró el proyecto Supabase `fidelity-app` a un **Supabase self-hosted corriendo en
una sola EC2**, encendible/apagable on-demand.

**Decisión de arquitectura:** se eligió *self-hosted en EC2* sobre *migración a AWS
nativo* (RDS + Cognito + Lambda) porque el requisito era **funcionar ya, con mínimo
riesgo**, y una sola VM permite el encendido/apagado on-demand. La app no requiere
cambios de código: solo cambiar la URL y la `ANON_KEY`.

> ⚠️ **El proyecto Supabase original NUNCA se modificó.** Toda la extracción fue en
> modo lectura (`pg_dump`, descargas HTTP GET). No se borró ni alteró nada en origen.

---

## 2. Origen (proyecto Supabase Cloud)

| Dato | Valor |
|---|---|
| Proyecto | `fidelity-app` |
| Ref | `wdxqttifkznlswgyhywb` |
| Organización | `mateocp10's Org` (`jxshhrrnonglhhhoacfw`) |
| Región | West US (Oregon) |
| Postgres | 17.6 |
| Tamaño DB | 14 MB |

---

## 3. Infraestructura creada en AWS

| Recurso | ID / Valor |
|---|---|
| Cuenta | `354918380322` |
| Región | `us-east-1` |
| Instancia | `i-0e206237bcda8a7d4` — **t3.medium** (2 vCPU / 4 GB) |
| AMI | `ami-052355af2a014bd2c` (Ubuntu 24.04 LTS) |
| Disco | 30 GB gp3 |
| IP pública | `54.224.142.204` ⚠️ *dinámica — cambia al apagar/encender* |
| VPC | `vpc-03e19e56c950ec4f6` |
| Subnet / AZ | `subnet-0da04489cdc2bf676` / `us-east-1c` |
| Security Group | `sg-083b3f9371b376c78` |
| Llave SSH | `~/.ssh/fidelity-supabase-key.pem` |
| Stack | `/opt/supabase` (11 contenedores) |

**Security Group:** puertos `22`, `8000`, `3000` abiertos **solo** a `157.100.198.11/32`
y `181.199.46.129/32` (las dos IPs de salida del usuario).

> 📌 La región `us-east-1` **estaba completamente vacía** (sin VPCs). Se recreó la VPC
> por defecto con `aws ec2 create-default-vpc` (sin costo).

---

## 4. Qué se migró — verificación

| Componente | Origen | Restaurado | Estado |
|---|---|---|---|
| Tablas en `public` | 11 | 11 | ✅ |
| `scans` | 131 | 131 | ✅ |
| `subscription_plans` | 78 | 78 | ✅ |
| `profiles` | 73 | 73 | ✅ |
| `businesses` | 36 | 36 | ✅ |
| `qr_codes` | 36 | 36 | ✅ |
| `loyalty_cards` | 34 | 34 | ✅ |
| `rewards` | 24 | 24 | ✅ |
| `business_categories` | 20 | 20 | ✅ |
| `reward_transfer_history` | 11 | 11 | ✅ |
| `scan_attempts` | 2 | 2 | ✅ |
| `support_tickets` | 0 | 0 | ✅ |
| **`auth.users`** | 78 | 78 | ✅ |
| **`auth.identities`** | 78 | 78 | ✅ |
| Policies RLS | 52 | 52 | ✅ |
| Funciones | 13 | 13 | ✅ |
| Triggers | 12 | 12 | ✅ |
| Buckets de Storage | 2 | 2 | ✅ |
| Archivos de Storage | 30 | 30 | ✅ |
| Edge functions | 3 | 3 | ✅ |

### Pruebas funcionales ya ejecutadas

- ✅ **Login completo**: creación de usuario → autenticación → JWT emitido.
- ✅ **Hashes de contraseña**: 78/78 en bcrypt (`$2a$`), 78/78 con email confirmado.
- ✅ **Resolución de rol en PostgREST**: `anon` → `{"rol":"anon","uid":null}`;
  `authenticated` → `{"rol":"authenticated","uid":"..."}` con `auth.uid()` funcionando.
- ✅ **Storage público**: archivo servido con HTTP 200 desde fuera de la EC2.
- ✅ **Edge function**: `validate-scan` responde con su propia lógica de validación.
- ✅ **Kong**: `service_role` → 200, sin key → 401 (comportamiento correcto).

---

## 5. Acceso

| Qué | Dónde |
|---|---|
| API / Kong | `http://54.224.142.204:8000` |
| Studio (dashboard) | `http://54.224.142.204:8000` (usuario `supabase`) |
| Credenciales completas | `migracion_aws/CREDENCIALES.txt` (permisos 600) |
| SSH | `./supabase-ec2.sh ssh` |

> ⚠️ La `ANON_KEY` **cambió** respecto al proyecto original (se generó un `JWT_SECRET`
> nuevo). La key vieja no sirve.

---

## 6. Operación: encender / apagar

```bash
cd migracion_aws
./supabase-ec2.sh start    # enciende, reajusta URLs a la IP nueva, levanta el stack
./supabase-ec2.sh stop     # apaga (deja de cobrar cómputo)
./supabase-ec2.sh status   # estado + IP + contenedores
./supabase-ec2.sh ssh      # entra por SSH
./supabase-ec2.sh logs     # logs del stack
```

**Costos:** ~$0.042/h encendida · **~$2.40/mes apagada** (solo disco).
Los 11 contenedores tienen `restart: unless-stopped` y Docker está habilitado al boot,
así que **el stack rearranca solo** al encender la instancia.

---

## 7. Decisiones técnicas y hallazgos

1. **Triggers de push apuntan a la red interna.** Los 5 triggers `push_notify_*` se
   reapuntaron de `https://wdxqttifkznlswgyhywb.supabase.co` a **`http://kong:8000`**
   (red interna de Docker) con el `SERVICE_ROLE_KEY` nuevo. Ventaja: **sobreviven a
   los cambios de IP pública**.
2. **Carga de datos con triggers desactivados.** Se usó `SET session_replication_role
   = replica` para que los triggers de push no dispararan llamadas HTTP durante el
   import.
3. **Storage se subió por la API**, no copiando archivos al volumen: garantiza que
   metadata y backend queden consistentes.
4. **`business_categories` y `support_tickets` tienen RLS activo pero CERO policies.**
   Esto **ya venía así del origen** (verificado contra el dump: solo `ENABLE ROW LEVEL
   SECURITY`, sin `CREATE POLICY`). Efecto: `anon` y `authenticated` reciben `[]`; solo
   `service_role` ve datos. **No es un defecto de la migración** — es condición
   preexistente del proyecto original.

### Gotchas encontrados (para no repetirlos)

- **La IP que reporta `checkip.amazonaws.com` no era la real.** El ISP usa egress
  distinto según destino: reportaba `157.100.198.11` pero AWS veía `181.199.46.129`.
  Se descubre leyendo `$SSH_CLIENT` dentro de la sesión SSH.
- **`pg_restore` restaura en orden alfabético**: `auth.identities` falla por FK porque
  va antes que `auth.users`. Hay que restaurar `users` primero y `identities` aparte.
- **Studio no se expone en el 3000**; se accede por Kong en el 8000.
- **El puerto 5432 lo ocupa Supavisor** (pide tenant id). Para SQL directo:
  `docker exec supabase-db psql -U postgres`.
- **`/rest/v1/` raíz es admin-only por diseño** en Supabase reciente. Un 403 con `anon`
  ahí es correcto, no un bug.
- Un trigger del origen se llamaba **` push_notify_reward_transfers` con espacio
  inicial**, por eso `LIKE 'push_notify%'` no lo capturaba.

---

## 8. ⏳ Lo que FALTA por hacer

### Prioridad alta

1. **Probar login con una cuenta real.** Es la validación definitiva de que los hashes
   migrados funcionan con contraseñas reales:
   ```bash
   curl -X POST "http://54.224.142.204:8000/auth/v1/token?grant_type=password" \
     -H "apikey: <ANON_KEY>" -H "Content-Type: application/json" \
     -d '{"email":"TU_EMAIL","password":"TU_PASSWORD"}'
   ```
   Si devuelve `access_token`, la migración queda validada de punta a punta.

2. **Apuntar la app al nuevo backend**: URL `http://54.224.142.204:8000` + la
   `ANON_KEY` nueva. Luego ejercitar los flujos reales (escanear QR, sumar puntos,
   transferir premio).

3. **Cargar los secretos de push.** Los push **no funcionarán** hasta configurar:
   - `FIREBASE_SERVICE_ACCOUNT` → JSON del service account (consola de Firebase →
     Project Settings → Service accounts → Generate key).
   - `WEBHOOK_SECRET` → valor custom, pedirlo al dueño del proyecto.

   Son los únicos secretos que no se pudieron copiar (Supabase los guarda *write-only*).
   Los `SUPABASE_*` ya los regeneró el stack self-hosted.

### Prioridad media

4. **HTTPS + dominio.** Hoy todo va por **HTTP plano**. Para producción: dominio,
   certificado TLS (Caddy/nginx + Let's Encrypt delante de Kong).
5. **IP estática (Elastic IP, ~$3.60/mes).** Descartada por ahora a pedido del usuario.
   Mientras tanto, la IP cambia en cada arranque y `supabase-ec2.sh start` reajusta las
   URLs del `.env` automáticamente — pero **la app hay que reapuntarla a mano**.
6. **Decidir sobre `business_categories`.** Si la app necesita que usuarios autenticados
   listen las categorías, hay que **crear una policy** (hoy no existe, heredado del
   origen).

### Prioridad baja

7. **Backups del nuevo Supabase.** No hay backups automáticos configurados. Opciones:
   snapshot EBS programado, o `pg_dump` a S3 vía cron.
8. **Usuario IAM en vez de root.** El `aws-cli` está usando **credenciales de root**
   (`arn:aws:iam::354918380322:root`). Conviene un usuario IAM con permisos acotados.
9. **Rotar credenciales expuestas.** Durante la sesión, la contraseña de Studio y la de
   Postgres quedaron visibles en el chat. Si preocupa, rotarlas.

---

## 9. Archivos de este directorio

```
ESTADO_MIGRACION.md   Este documento.
README.md             Inventario de la copia y guía de restauración.
CREDENCIALES.txt      Credenciales del Supabase nuevo (chmod 600).
supabase-ec2.sh       Control de la EC2: start|stop|status|ssh|logs.
setup-supabase.sh     Script que generó los secretos y configuró el .env.
user-data.sh          Bootstrap de la EC2 (Docker + stack de Supabase).
aws_ids.env           IDs de los recursos AWS creados.
dumps/                Los 5 dumps de la base de origen.
storage_files/        Los 30 archivos de Storage descargados.
supabase/functions/   Las 3 edge functions.
```

> La carpeta hermana `backup_supabase/` contiene trabajo manual previo
> (`adapar_a_postgre.md`, `schema_listo_postgre.sql`) que **no es reproducible** con una
> descarga. No borrarla.
