# Custom Sitespeed Docker Image Build 

### Why we need to customize the docker image?
Since [sitespeed](https://github.com/sitespeedio/sitespeed.io) has a couple of dependencies such as Node, Python, Chrome, Firefox, Edge and lots of packages. There may be the need to keep update-to-date for those dependencies due to new browser features or any security concerns. 

Every time of building image: 
- lastest stable debian base image 
- lastest Chrome 
- latest Firefox 
- latest Edge 
- latest Node-18.x

### How to build our custom docker image
In terminal, just run `./build.sh`. The script will download the latest sitespeed resource code first, then build the image based on `custom.dockerfile`. 

The image will be tagged as `sitespeedio-custom:<sitespeed version specified in package.json>`

