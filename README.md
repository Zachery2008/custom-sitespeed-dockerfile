# Custom Sitespeed Docker Image Build 

### Why we need to customize the docker image?
Since [sitespeed](https://github.com/sitespeedio/sitespeed.io) has a couple of dependencies such as Node, Python, Chrome, Firefox, Edge and lots of packages. There may be the need to keep update-to-date for those dependencies due to new browser features or any security concerns. 

Every time of building image: 
- lastest stable debian base image 
- lastest Chrome 
- latest Firefox 
- latest Edge 
- latest [Node-lts](https://nodejs.org/en/)

### How to build our custom docker image
In terminal, just run `./build.sh`. The script will download the latest sitespeed resource code first, then build the image based on `custom.dockerfile`. 

The image will be tagged as `sitespeedio-custom:<sitespeed version specified in package.json>`

### How to use the sitespeed image
Just run `docker run --rm -v ${pwd}:/sitespeed.io sitespeed:<tag> <website url>`. The result will show in `$pwd` folder. 

Examples: 
`docker run --rm -v ${pwd}:/sitespeed.io sitespeed:26.1.0 http://www.sitespeed.io/`. 

The default browser is Chrome, 

- if you want to test on Firefox, 
`docker run --rm -v ${pwd}:/sitespeed.io sitespeed:26.1.0 -b firefox http://www.sitespeed.io/`

- if you want to test on Edge, 
`docker run --rm -v ${pwd}:/sitespeed.io sitespeed:26.1.0 -b edge http://www.sitespeed.io/`
