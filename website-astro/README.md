# Website Powered by Astro
Blog is powered on Astro and uses the [Blog Template](https://github.com/danielcgilibert/blog-template) by danielcgilibert.

## Temp notes
Below are some draft notes taken while I test drive.

Start Container
```
sudo service docker start

cd ~/code/git/lexd-solutions/website-astro
# docker run --rm -v $(pwd):/app -p 8080:8080 -it --user $(id -u):$(id -g) --entrypoint=bash node:22
docker run --rm -v $(pwd):/app -p 8080:4321 -it --entrypoint=bash node:22
```

Inside the container
```
cd /app

export PNPM_HOME="/pnpm"
export PATH="$PNPM_HOME:$PATH"
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

corepack enable
pnpm install

pnpm dev
```

Once its running, I can make changes and it will refresh the page automatically.

- Check WSL IP
    ```
    ip a | grep eth0: -A3 | grep inet
    inet 172.30.49.60/20 brd 172.30.63.255 scope global eth0
    ```

## Running live
Use the following to build prod image.
```
FROM node:20-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
EXPOSE 8000
CMD [ "pnpm", "start" ]
```