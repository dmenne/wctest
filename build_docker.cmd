docker rm -f wctests
docker build --no-cache --tag dmenne/wctests .
docker run -d -it  --name wctests  -p 3839:3838 dmenne/wctests
