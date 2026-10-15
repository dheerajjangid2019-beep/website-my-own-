# Hosting Bhawani Interior on Render

This guide deploys the current Node.js website and API as one Render web service. It uses the existing SQLite database on a Render persistent disk. This is a reasonable first production setup for a small site with one running server instance. If traffic grows or multiple app instances are needed, migrate the database to managed PostgreSQL.

## The complete client-project process

### 1. Agree on what the client is buying

Before making changes, write down the agreed pages and features, delivery date, number of review rounds, who supplies the text/photos/logo, who pays hosting/domain fees, and what support is included after launch. Confirm whether the AI Designer and consultation form email alerts are included. Get the client to approve the final text, contact details, prices, portfolio, testimonials, and claims before launch.

The domain, GitHub repository, and hosting account should belong to the client or the client's business. Ask to be invited as a collaborator; do not make the client dependent on your personal accounts. Agree in writing who handles updates, backups, and future hosting bills.

### 2. Know what each part of this website does

- `frontend/index.html` contains the pages, text, forms, and page structure (HTML).
- `frontend/styles.css` contains the site's custom appearance (CSS). The page also loads Tailwind, fonts, and icons from external CDNs.
- `frontend/app.js` handles browser interactions such as the menu, estimate calculator, consultation form, admin panel, and AI chat (JavaScript).
- `backend/server.js` serves the pages and provides the API. The API validates and saves consultation requests, checks admin sign-in, lists/deletes leads, and can proxy chat requests to Gemini.
- `backend/data/website.sqlite` is the local SQLite database. On Render, the app writes the database under the persistent disk path selected by `DATA_DIR`.
- `.env` contains local private settings. It must stay out of GitHub. Production secrets are entered in Render's Environment settings instead.

When building or revising the site, first get the client's approved content and assets; then edit HTML for structure, CSS for appearance, and browser JavaScript for page behavior. Use backend routes for anything that must be validated, protected, or stored. Do not put passwords, database credentials, or API keys into HTML or frontend JavaScript.

### 3. Review locally and get client approval

On Windows, double-click `Start Website.bat` and leave its console window open. Open the local URL printed in that window. Review the site on a phone-sized screen and desktop. Check all navigation links, portfolio filters, calculator, consultation form, admin login, search/delete actions, and AI chat if configured.

For form testing, use clearly fake test details. Confirm that a test lead appears in the existing admin panel, then delete only that fake lead. The current form saves leads but does not email them; either add an email alert or make sure the client agrees to check the admin panel regularly. Have the client review a preview and approve the text, photos, contact details, and layout in writing before public launch.

### 4. Save the approved source code safely

Use a private GitHub repository owned by the client. The `.gitignore` already excludes `.env`, `backend/data/`, and `node_modules/`. Check before every first push that `.env` and the SQLite database do not appear in Git status. Do not upload real client leads or share passwords in GitHub.

Keep a clean source backup and a short record of the production service, domain, configuration names, and support arrangement. The private repository is the versioned source of truth; Render deploys the selected branch.

### 5. Deploy and verify before launch

Follow the Render steps below to create the Node.js web service, persistent disk, and private environment variables. Deploy first to the Render-provided test URL. Confirm the homepage and `/api/health`, then test one fake consultation request and the admin panel. Only continue to the custom domain after these checks pass.

### 6. Hand over the project

After the client approves the live site:

1. Confirm the client can sign in to the Render and domain-provider accounts they own. Invite their staff to the admin panel only if needed.
2. Give them the live website URL, admin URL/entry point, and instructions for checking and following up on leads. Send the admin password through a password manager or another private channel, not a public document or source file.
3. Explain the recurring costs and who pays them. Render's paid server and disk charges are separate; the domain is usually billed by its registrar.
4. Explain what the site stores, who can access it, how to export/back up leads, and how long you will provide support.
5. Deliver the approved project files/source repository and a short list of future-maintenance tasks. Do not leave the client with an account or domain that only you control.

Keep a written handover record: date, live URL, repository, service owner, domain owner, admin access delivered, recurring services/costs, backup plan, and support end date.

## Before you start

- Use GitHub, Render, and the domain account owned by the client. The client can invite you to help.
- Render needs a paid web service to attach a persistent disk. Disks currently cost $0.25 per GB per month, in addition to server compute. Confirm current prices before deploying: <https://render.com/pricing>.
- A free Render web service has an ephemeral filesystem and cannot use a persistent disk. Do not use it for the live consultation database: <https://render.com/docs/free>.
- The website stores consultation requests in the database and shows them in the existing admin panel. It does not send email notifications. Decide who will check the admin panel, or add an email notification provider before launch.
- AI Designer replies require a Gemini API key. Without it, the rest of the website can work, but chat will show a configuration message.
- Confirm all business claims, contact details, portfolio images, testimonials, and awards on the site are approved and accurate before publishing for a client.

## 1. Push the project to a private GitHub repository

Create a new **private** repository for the client. Leave the README, `.gitignore`, and license options unchecked because those files already exist locally. GitHub's instructions for importing local code are at <https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github>.

Open PowerShell and run:

```powershell
cd "C:\Users\DheerajKumar\OneDrive\Desktop\website"
git init
git add .
git status --short
```

Before continuing, check that `.env` and `backend/data/` are **not** listed. The repository's `.gitignore` excludes them; they contain private settings and local database data. If either appears, stop and ask for help before pushing.

Then commit the project and connect it to the empty GitHub repository. Replace `YOUR-GITHUB-NAME` with the account or organization that owns the private repository:

```powershell
git commit -m "Prepare Bhawani Interior website for deployment"
git branch -M main
git remote add origin https://github.com/YOUR-GITHUB-NAME/bhawani-interior-website.git
git push -u origin main
```

Git may open a browser window to sign in. If it reports that the folder is already a Git repository or that `origin` already exists, stop and ask for help instead of repeating `git init` or `git remote add`.

## 2. Create the Render web service

1. Sign in to Render using the client's account.
2. Choose **New → Web Service** and connect the private GitHub repository.
3. Select the `main` branch.
4. Use the repository root as the Root Directory (leave it blank if Render asks).
5. Choose the Node runtime. The project declares Node.js 24 in `package.json`.
6. Set **Build Command** to `npm install` and **Start Command** to `npm start`.
7. Choose a paid instance plan suitable for the client's expected traffic. A disk-backed SQLite setup is for one running instance; do not turn on multiple instances with this database.
8. In Advanced settings, add a persistent disk. Set its mount path to `/var/data` and choose the smallest disk size that Render offers for this service. If you attach the disk after creating the service, use its Disks settings and wait for the resulting deploy to finish.

Render requires public web services to listen on `0.0.0.0` and use its `PORT` environment variable. The backend now does this automatically in production. Render documents the port requirement at <https://render.com/docs/web-services>.

## 3. Add production environment variables

In the Render service's **Environment** settings, add:

| Key | Value |
|---|---|
| `NODE_ENV` | `production` |
| `DATA_DIR` | `/var/data` |
| `ADMIN_PASSWORD` | A new, unique, strong password. Do not reuse the local password or a password shown in chat. |
| `GEMINI_API_KEY` | Optional. Add a private Gemini API key only if the client wants the AI Designer enabled. |
| `GEMINI_MODEL` | Optional. Use the model selected for the Gemini key, or keep the default in the app. |

Do **not** set `PORT` or `HOST` manually on Render. Render supplies `PORT`; the app selects the correct production host. Never upload `.env` or paste API keys into GitHub, chat, or website JavaScript. Save the Environment settings and let Render deploy again.

Set the service health-check path to `/api/health` if the health-check setting is available. The endpoint should return `{"status":"ok"}` when the service is running.

## 4. Verify the test URL before connecting the client's domain

Render gives the service an `https://...onrender.com` URL. Check these in order:

1. Open the site URL and confirm the homepage, images, navigation, and mobile layout load.
2. Open `https://YOUR-SERVICE.onrender.com/api/health`; confirm it returns `{"status":"ok"}`.
3. Submit a fake test consultation request using your own test details, not a real customer's personal details.
4. Open the existing admin panel, sign in with the production `ADMIN_PASSWORD`, and confirm the test request appears.
5. Delete only the fake test request after confirming the form and dashboard work.
6. If AI Designer is enabled, send it a test message. If not enabled, decide whether to configure the key or remove/disable that UI before launch.

The server currently stores leads but does not email anyone. Ensure the client knows to check the admin panel regularly, or arrange email notifications before relying on the form for new business.

## 5. Connect the client's domain

Do this only after the `onrender.com` URL passes the checks above and the client has authorized changes to the domain:

1. In the Render service, open **Settings → Custom Domains** and add the client's domain (for example, `example.com` or `www.example.com`).
2. Render will show the DNS records to add at the domain registrar. Copy those exact records; do not guess.
3. Preserve mail-related DNS records such as MX records. If unsure which records are for email, ask the domain/email administrator before changing DNS.
4. Return to Render and verify the domain. Render provisions and renews HTTPS certificates and redirects HTTP traffic to HTTPS: <https://render.com/docs/custom-domains>.
5. Test the root domain and `www` address, then submit one more fake consultation request through the final domain.

## 6. After launch

- Keep `.env` and `backend/data/` out of GitHub. Do not commit customer lead data.
- Confirm the client can access the Render dashboard, GitHub repository, domain registrar, and production admin panel.
- Make a database backup/export schedule. Render disk snapshots help with recovery, but they are not a substitute for a deliberate business-data backup process.
- Monitor Render deploy logs and the health-check endpoint after changes.
- If the client needs email alerts, multiple server instances, or higher write volume, move leads to managed PostgreSQL and add a notification provider before scaling.
