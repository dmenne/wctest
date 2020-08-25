docker rm -f wctests
rem docker build --no-cache --tag dmenne/wctests .
docker build --tag dmenne/wctests .
docker run -d -it  --name wctests  -p 3839:3838 dmenne/wctests
