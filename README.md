# Dockerfiles

To build a Docker image on a regular cadence, create a directory in this repo named as how you would like the image to be named. Include a `Dockerfile` and a `Makefile` with a target called `build`.

## The `build` target

In your `Makefile`, the `build` target must do the following:

* Login to the ECR registry to which you want your image pushed
* Build the Docker image
* Tag the Docker image
* Push the Docker image to the ECR registry

Optionally, you can include steps to do some kind of automated testing.
