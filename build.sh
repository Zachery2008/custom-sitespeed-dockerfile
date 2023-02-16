REPO_NAME="sitespeedio-custom"

# Clone sitespeed.io resouce code 
git clone https://github.com/sitespeedio/sitespeed.io.git ./sitespeed.io

# Copy custom dockerfile to sitespeed.io folder
cp custom.dockerfile ./sitespeed.io/custom.dockerfile

cd ./sitespeed.io
# Get the image tag 
tag=$(jq -r .version package.json)

# Build the image
docker build -t $REPO_NAME:$tag -f custom.dockerfile .