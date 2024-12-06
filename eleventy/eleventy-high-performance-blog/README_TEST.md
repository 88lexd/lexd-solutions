# Instructions to test on WSLv2

Start Container
```
cd ~/code/git/lexd-solutions/eleventy
docker run --rm -v $(pwd):/app -p 8080:8080 -it --user $(id -u):$(id -g) --entrypoint=bash node:22
```

Inside the container. This will constantly watch and serve website.. not sure if I need this when running live..
There is another option to run `npm run build`... but lets check another time..
```
cd /app/eleventy-high-performance-blog
npm run watch
```

Once its running, I can make changes and it will refresh the page automatically.
 - Check WSL IP
    ```
    ip a | grep eth0: -A3 | grep inet
    inet 172.30.49.60/20 brd 172.30.63.255 scope global eth0
    ```
 - Open browser and use http://172.30.49.60:8080


## Notes
- Google Analytics - See: /home/alex/code/git/lexd-solutions/eleventy/eleventy-high-performance-blog/_data/metadata.json

- Wordpress posts have been converted to Markdown and is saved onto OneDrive (Personal Docs/temp/wordpress-markdowns-backup)