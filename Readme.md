```
$ docker build -t="torhve/openresty" . 
$ docker run -t -i -p 8080:8080 -v=`pwd`:/helloproj -w=/helloproj torhve/openresty
```
