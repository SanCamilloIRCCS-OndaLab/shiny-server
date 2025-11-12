# San Camillo Shiny Apps

This repository stores the server and the shiny apps developed at [IRCCS San Camillo Hospital](https://hsancamillo.it). 

The server is [ShinyProxy](https://www.shinyproxy.io/) which allows concurrent users to use the same app.

Moreover, ShinyProxy works with completely isolated docker containers, one for each app (indeed, one for each session...). Therefore, each app is independent and can use a different version of R and different packages.

## General structure of the repository

The server used is [ShinyProxy](https://www.shinyproxy.io/), which is deployed in its dockerized version (`docker-compose.yml`).

Current ShinyProxy version: `3.1.1`

All files used directly by ShinyProxy server (except for the docker compose starting file) are stored in the folder `shinyproxy`.

All the server's settings are defined in `application.yml`.

A full list of the available configurations is defined in the [ShinyProxy documentation](https://www.shinyproxy.io/documentation/configuration/).

Each app includes some attributes which define specific details of the app. The syntax of each app in the `application.yml` is the following:

```
id: [Short ID for the app. Must be unique among all the apps]
display-name: [English name of the app]
description: [English description of the app]
docker-cmd: ["R", "-e", "shiny::runApp('/root/idOfTheApp')"] (Change the id of the app)
container-image: [The name of the docker container of the app]
container-network: shinyproxy-nw (as defined in the docker-compose file)
logo-url: /assets/img/apps/AppLogo.png (A screenshot of the app)
template-group: [clinical or scientific]
template-properties:
    author: [Name of the autor] (optional)
    contact: [Email contact of the author] (optional)
    doi: [DOI of the article] (optional)
    display-name_it: [Italian title of the app] (optional)
    description_it: [Italian description of the app] (optional)
    keywords: [Keywords list separated by ;. Used for search purposes only.]
```

Folders `assets` and `templates` contains useful files for rendering the website.

All the applications are stored in the folder `apps`. Each application should be stored in a separate folder and is implemented in completely independent way. Each application must be dockerized.

## About ShinyProxy

ShinyProxy is a useful opensource tool to easily serve applications as shinyapps, jupyter notebooks and others.

The easiest way to deploy a new app with ShinyProxy is to create a docker image hosting the full and working app.

Each image is registered in the ShinyProxy configuration file (`application.yml`). Once someone open the app ShinyProxy will spawn a new docker instance of the app. In this way each user session is completely independent from the others and no interaction issues will arise.

The drawback of this logic is that if an app is not optimized and is resource demanding, if multiple users will access the app simultaneously, mutiple docker instances of the resource demanding app will be created, affecting the resources of the entire server.

## Deploying new apps

### How to contribute

The branch `main` of the repository is protected because it is synced with the website, which is automatically updated every time the branch main receive a new commit. (Currently the automation is not working.)

In order to contribute work on a separate branch, or preferably fork the repository, and send a pull request to merge the new app in `main`.

### Implementing a new app

As already mention each app is a standalone docker image.

New apps can be implemented using the already existing ones as template.

However, these are the steps required to implement a new app:
1. Create a folder inside `apps` with the name of the new app (e.g. `MyNewShinyApp`)
2. Inside the folder `apps/MyNewShinyApp` create a new folder with a short name of the app (e.g. `newapp`) where you can store all the developed code (for example `app.R`, `R_data`, `R_functions`, etc)
3. Inside the folder `apps/MyNewShinyApp` create a `Dockerfile` with the standalone working app (see below for a template)
4. Test the app locally (you need docker on your computer):
    1. `cd apps/MyNewShinyApp`
    2. `docker build -t shinyapp-newapp .`
    3. `docker run -it -p 3838:3838 shinyapp-newapp`
    4. Open a browser, go to [http://localhost:3838](http://localhost:3838) and you should see the app.
5. Add a screenshot (which will be the app logo) in `shinyproxy/templates/assets/img/apps` 
5. Add the app to the file `application.yml` at the end of the section `specs`:
    ``` 
    id: MyNewShinyApp
    display-name: New Shiny Application
    description: Here a beatiful description of the new shiny app
    container-cmd: ["R", "-e", "shiny::runApp('/root/mynewshinyapp')"]
    container-image: openanalytics/shinyproxy-newapp
    container-network: shinyproxy-nw
    logo-url: /assets/img/apps/name_of_the_screenshot.png
    template-group: [clinical or scientific]
    template-properties:
        author: Name of the author (optional)
        contact: author@email.com (optional)
        article: Title of the article of the app (optional)
        doi: 10.123/thedoiofthearticle (optional)
        display-name_it: Nuova applicazione Shiny (optional)
        description_it: Una bellissima descrizione anche in italiano (optional)
        keywords: keyword1; keyword2; keyword3
    ```

### Dockerfile

Each app must be dockerized. Therefore one Dockerfile must exist for each app.

For a new shiny app you can just modify the following template

```docker
FROM openanalytics/r-ver:4.3.3

RUN /rocker_scripts/setup_R.sh https://packagemanager.posit.co/cran/__linux__/jammy/latest
RUN echo "\noptions(shiny.port=3838, shiny.host='0.0.0.0')" >> /usr/local/lib/R/etc/Rprofile.site

# system libraries of general use
RUN apt-get update && apt-get install --no-install-recommends -y \
    pandoc \
    pandoc-citeproc \
    libcairo2-dev \
    libxt-dev \
    && rm -rf /var/lib/apt/lists/*

# system library dependency for the app
### For example:
### RUN apt-get update && apt-get install --no-install-recommends -y \
###    libmpfr-dev \
###    && rm -rf /var/lib/apt/lists/*

# basic shiny functionality
RUN R -q -e "options(warn=2); install.packages(c('shiny'))"

# install R packages of the app
### For example
### RUN R -q -e "options(warn=2); install.packages('png')"

# install R code
### CHANGE newapp WITH THE FOLDER WITH THE CODE
COPY newapp /app
WORKDIR /app

EXPOSE 3838

# create user
RUN groupadd -g 1000 shiny && useradd -c 'shiny' -u 1000 -g 1000 -m -d /home/shiny -s /sbin/nologin shiny
USER shiny

CMD ["R", "-q", "-e", "shiny::runApp('/app')"]
```

* Change the first line if you need a different R version
* Follow the comments if you need to install system libraries needed by the app
* Follow the comments if you need to install R packages needed by the app
* In the line starting with `COPY` change `newapp` with the name of the code folder (shortname of the app)


## How to run it locally

> [!WARNING]
>
> ShinyProxy relies on docker socket to run the single apps, therefore the shinyproxy website will work **ONLY on Linux** and it will NOT work on macOS or Windows (except if using WSL2). You can always run the single dockerized apps separately.

First you have to create a docker network

```bash
docker network create shinyproxy-nw
```

Then you need to create the images of all the apps and you need to change the Docker GUID in `.env`. To do so there is a script that does everything for you.

```bash
chmod +x first_run_setup.sh
./first_run_setup.sh
```

Then you can simply launch the docker compose file with:

```bash
# From the main folder of the project
docker compose up -d
```

From a browser, you will see the ShinyProxy server with all the apps at [http://localhost:8080](http://localhost:8080)

To stop the server

```bash
# From the main folder of the project
docker compose down -d
```