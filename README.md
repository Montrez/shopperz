### spring.security
# Getting Started

## Step 1: Installing Spring Boot

Getting Started using Java Spring Boot with MyEclipse/Eclipse:

- Will need Docker installed on local computer.
- Will need to start the Docker engine after installation.

Used Spring Initializer to create a Spring boot project:

- Spring boot : Spring 2.3.0
- Dependencies: Spring Web

Now inside of your project we will create a new package under /src/main/java named "resource". 

Inside of this package create a java class named "HelloResource" that is structured as follows:

```
@RestController
@RequestMapping("/rest/docker/hello")
public class HelloResource {
	
	@GetMapping
	public String hello() {
		return "Hello World";
	}

}
```
@RestController is used because we are using the Spring MVC
@RequestMapping("/rest/docker/hello") creates the mapping for the url.
@GetMapping simply takes that mapping and prints out the contents of this method on that url path.


### Step 1.1: Installing Docker 
If Docker is not installed on your computer you can follow this link: https://docs.docker.com/get-docker/

This link will take you to a page that will allow you to install the latest updates for Windows, Mac, Linux. 

After installing Docker you will need to setup your Dockerhub account so that we can save our images: https://hub.docker.com/signup


### Step 1.2:
Next we will do a maven install using eclipse:
- Right click the project and then click on 'Run As'
- Click on Run Configurations and then select Maven Build
- Inside the new Maven Build go to 'Goals' and click on 'Select'
- Next drop down default lifecycle phases and select 'install'
This will create your new jar file.

To shorten jar file name we go into the pom.xml file
And do the following: 
```
<build>
		<plugins>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
		</plugins>
		<finalName>docker-spring-boot</finalName>
</build>
```
## Step 2: Building a Dockerfile
Now we will create the Dockerfile
```
FROM openjdk:8
ADD target/docker-spring-boot.jar docker-spring-boot.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "docker-spring-boot.jar"]
```
- FROM is telling us which image we are going to use for our container. In this case we are using the offical Docker image for Java 8 that is listed on Dockerhub.
- ADD first lists the path of the jar file, and then lists the jar file we are using.
- EXPOSE will use port 8085 on localhost
- ENTRYPOINT lists all the commands we need for java to run this build.

Next we need to make sure the application knows that we are using port 8085 by updating our "application.properties" which should be located in the 'src/main/resources' package. If not, you can create the file since we only need to add one field.
```
server.port=8085
```

Next we need to build the image:

```
docker build -f Dockerfile -t docker-spring-boot .
```
-f indicator for file

-t indicator for tagname
docker-spring-boot is the name of our image.

After building, which may take a while if it's your first time. We will check that the image is created.
```
docker images
```
This command should list all of the images that we have created on Docker. We should see 'docker-spring-boot' as the most recent image at the top.

Now lets run the container with the image. On sucess, this will allow us to see Hello World on http://localhost:8085/rest/docker/hello. 
Run:
```
docker run -p 8085:8085 docker-spring-boot
```
Errors that came up include: 

Error: unable to access jar file.
Fix: Used sudo and issue disappeared. 

If needed we can go into a container with:

```
docker exec -it {container_id} /bin/bash
```

## Step 3: Settting up MySql

Now if we ever need to change anything we can just rebuild using the Dockerfile and the build command from earlier and rerun the application with the 'docker build' command above. Currently that is the case. 

To create our database we will need to exectute this command "root" user

Have to map the ports from inside the container to outside the container.

Install Mysql workbench to make sure that we can connect to the container from the outside.

***MAKE SURE YOU DO NOT HAVE THE MYSQL SERVER RUNNING ALREADY.

We'll need to first pull down a version of mysql from dockerhub. Here's a link to check out the different versions: https://hub.docker.com/_/mysql.

However we can simply checkout the latest version with this command:
```
docker pull mysql
```
This by default will pull down the latest image version for mysql. 

Now we can run our new image inside of a container like so:

```
docker run  -p 3306:3306 -p 33060:33060 --name mysql-standalone -e MYSQL_ROOT_PASSWORD={your_password} -d mysql:{mysql_version}
```
If all went well we should now have a container that is actively running our mysql image and we can take a look in our docker dashboard which is installed with Docker or run:

```
docker ps or docker container ls -a
```
To create a database we can either connect to it via mysql workbench or through the container itself using:
```
docker exec -it [container_name] mysql -uroot -p
```
This will prompt us for the password we specified when we created the mysql container. Inside we can run regular sql commands to set up our database.

Might have to stop all other containers and rename this container if you receive this error:

```
docker: Error response from daemon: Conflict. The container name "/mysql-standalone1" is already in use by container "[containerId]". You have to remove (or rename) that container to be able to reuse that name.
```

Use jdbc:mysql://mysql-standalone:3306/attorneygo_db instead for the database connection in the applications.properties file. This is the name of our new container and we need to access that information from our Spring boot application. 

## Step 4: Using Docker Volumes to link Workspace

In order to interact with our new container and mirrror our working directory with the container we could use this command:
```
docker run -v “{Project Directory}:/home“ --it —name docker-mysql --link mysql-standalone:mysql -p 8086:8086 docker-spring-boot —entrypoint /bin/bash
```

This will remove the need to have to rebuild or Dockerfile everytime we make a change. If you change directories into the home folder inside this container we should see the same folders and files that we have in our working directory. 

We can add debug to our container by using this commamnd:
```
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
```

## Step 5: Pushing to Dockerhub
Just like with Github we'll want to save our own files, images, somewhere to use them again. This way we can pull directly from our own directories. 
First lets login:

```
docker login
```
In the web browser we can create the repository on dockerhub. This way it will already be created and we can push to this repository.

Next we should tag a image. It further documents what we will use it for later.
```
docker tag {image_id} yourhubusername/{image_name}:{tag}
```
Now we can push the image to our dockerhub.
```
docker push yourhubusername/{image_name}
```
