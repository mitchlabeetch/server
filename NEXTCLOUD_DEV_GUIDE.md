# Nextcloud Custom Development Guide

Welcome to your custom fork of Nextcloud! Because you are building and compiling directly on top of the `server` core (rather than using the standard Nextcloud "Apps" plugin ecosystem), there are several highly important rules and architectural workflows you must follow to prevent breaking your web interface, crashing your server, or losing data.

---

## 1. The Build Process (Node.js & Composer)
Nextcloud's UI heavily utilizes **Vue.js**, SCSS, and raw Javascript. The backend utilizes **PHP** and Composer packages.
* **If you edit Javascript, Vue, or SCSS files:** You **must** compile them for your changes to appear. 
* *Locally/Development:* You would normally run `npm ci && npm run build` inside the `server` repository. 
* *In Production/CI:* The `Dockerfile` provided for you handles this via a multi-stage Docker build. It will install all Node modules, run the JS build system, compile the Composer PHP dependencies, and bundle them seamlessly on top of `nextcloud:latest`. You do not need to manually commit `.js` dist files unless you want to, as the Action builds them.

---

## 2. Core Modifications vs. Custom Apps
When programming on top of Nextcloud, you have two overarching paths:
### A. Developing a Nextcloud App (Recommended)
Usually, modifications are best constructed as an *App* (in the `apps/` directory). 
If you build a feature inside an isolated app:
- State, tables, and logic are completely separated from the core.
- When Nextcloud releases a major version upgrade, your application won't break the whole core ecosystem, and migration is infinitely easier.
- You can read the Nextcloud Developer Manual (`nextcloud.com/developer`) to learn how to scaffold an app using `occ app:generate`.

### B. Modifying the Core Directly
If you choose to modify core functionalities directly (e.g. changing core `lib/` routines, altering core UI navigation):
- **Upgrades will be significantly harder.** If you ever attempt to merge upstream `nextcloud/server` updates into your fork in the future, you will encounter massive merge conflicts.
- **Cache Invalidations:** You must frequently clear your OPcache/Redis caches and maybe bump your `version.php` to force clients to redownload your modified CSS/JS.

---

## 3. The Database (Migrations and Upgrades)
If you add new tables or alter core columns:
- **Never alter the database manually.** Nextcloud uses Doctrine and an XML schema (`appinfo/database.xml` for legacy apps, or migration scripts in modern apps). 
- Modifying the core Nextcloud DB tables directly can cause `occ upgrade` to catastrophically fail during routine maintenance.

---

## 4. Helpful `occ` Commands for Devs
Nextcloud comes with `occ`, the CLI management tool. Under your current Docker VPS deployment, you can run them using:
`docker exec -it --user www-data <nextcloud_container_name> php occ <command>`
* `php occ maintenance:mode --on` : Enable maintenance mode when experimenting.
* `php occ upgrade` : Triggers database schema upgrades if you bump versions.
* `php occ app:enable <app_name>` : Enable your custom app if you go the App route.
* `php occ log:tail` : Watch the Nextcloud logs dynamically while debugging your features.

---

## 5. Security & Dependencies
* If you modify `.php` files, double-check your API implementations. Do not bypass the `OCP\AppFramework\Controller` which contains built-in CSRF and CORS protections!
* Never commit the `config/config.php` file containing passwords. Use the `.env` approach to inject database passwords and secrets into your Nextcloud via Docker environment variables.

Happy programming!
