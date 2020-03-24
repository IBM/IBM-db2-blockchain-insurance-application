*Read this in other languages: [中国語](README-cn.md),[日本語](README-ja.md).*

# Db2 for Blockchain analytics

In this project we will be leveraging the sampe blockchain insurance application [Insurance application](https://github.com/IBM/build-blockchain-insurance-app). We will be integrating DB2’s Federation Capabilities to perform SQL Analytics on the sample blockchain insurance application using Hyperledger Fabric. Apache Zeppelin notebook will be used to perform analytics by querying the blockchain using Db2 and SQL.

Audience level : Intermediate Developers

## Included Components
* Hyperledger Fabric
* Docker
* IBM Db2 database

## Application Workflow Diagram
![Workflow](images/arch-blockchain-insurance2.png)

* Generate Certificates for peers
* Build Docker images for network
* Start the insurance network
* Query Blockchain via Zeppelin notebooks using SQL

## Prerequisites
We find that Blockchain can be finicky when it comes to installing Node. We want to share this [StackOverflow response](https://stackoverflow.com/questions/49744276/error-cannot-find-module-api-hyperledger-composer) - because many times the errors you see with Compose are derived in having installed either the wrong Node version or took an approach that is not supported by Compose:

* [Docker](https://www.docker.com/products) - latest
* [Docker Compose](https://docs.docker.com/compose/overview/) - latest
* [NPM](https://www.npmjs.com/get-npm) - latest
* [nvm]() - latest
* [Node.js](https://nodejs.org/en/download/) - latest
* [Git client](https://git-scm.com/downloads) - latest
* **[Python](https://www.python.org/downloads/) - 2.7.x**

## Steps

1. [Run the application](#1-run-the-application)

## 1. Run the application

Clone the repository:
```bash
git clone https://github.com/IBM/IBM-db2-blockchain-insurance-application
```

Login using your [docker hub](https://hub.docker.com/) credentials.
```bash
docker login
```

Run the build script to download and create docker images for the orderer, insurance-peer, police-peer, shop-peer, repairshop-peer, web application and certificate authorities for each peer. This will run for a few minutes.

For Mac user:
```bash
cd IBM-db2-blockchain-insurance-application
./build_mac.sh
```

For Ubuntu user:
```bash
cd IBM-db2-blockchain-insurance-application
./build_ubuntu.sh
```

You should see the following output on console:
```
Creating db2-fabric ...
Creating repairshop-ca ...
Creating insurance-ca ...
Creating shop-ca ...
Creating police-ca ...
Creating orderer0 ...
Creating repairshop-ca
Creating insurance-ca
Creating police-ca
Creating shop-ca
Creating orderer0 ... done
Creating insurance-peer ...
Creating insurance-peer ... done
Creating shop-peer ...
Creating shop-peer ... done
Creating repairshop-peer ...
Creating repairshop-peer ... done
Creating web ...
Creating police-peer ...
Creating web
Creating police-peer ... done
Creating db2-fabric ... done
```

**Wait for few minutes for application to install and instantiate the chaincode on network**

### Verfiy that all container are up and running

To verify this, run docker ps in your terminal. These  are all the containers that you should see running.

```bash
docker ps
```

![docker ps](images/docker-ps.png)


### Verify that web container is up and running

Check the status of installation using command:
```bash
docker logs web
```
On completion, you should see the following output on console:
```
> blockchain-for-insurance@2.1.0 serve /app
> cross-env NODE_ENV=production&&node ./bin/server

/app/app/static/js
Server running on port: 3000
Default channel not found, attempting creation...
Successfully created a new default channel.
Joining peers to the default channel.
Chaincode is not installed, attempting installation...
Base container image present.
info: [packager/Golang.js]: packaging GOLANG from bcins
info: [packager/Golang.js]: packaging GOLANG from bcins
info: [packager/Golang.js]: packaging GOLANG from bcins
info: [packager/Golang.js]: packaging GOLANG from bcins
Successfully installed chaincode on the default channel.
Successfully instantiated chaincode on all peers.
```

## Setting up Db2 instance

In order to setup Db2 we will be using the zeppelin-notebook container, where Apache Zeppelin is setup and running, which is a web-based notebook that enables interactive data analytics. We will configure Apache Zeppelin to connect to Db2 instance.

We need to make sure the `db2-fabric` container is up and running. The container runs a lightweight community edition of Db2. You can execute `docker logs db2-fabric` to see the progress and status of the Db2 instance. You can keep executing this command to get the latest information for this container until you see:

`(*) All databases are now active. (*) Setup has completed.`

Once the installation is done, Lets setup the Db2 instance that was just created.
To setup we need to `exec` inside the `db2-fabric`. For this run: 

`docker exec -it db2-fabric bash`

You can then execute a setup script that sets some environment variables for DB2 and logging details. We then stop and start the database manager to pull in the latest configuration details. To do this run the following: 

```bash
su - db2inst1 -c '/db2-container/setup-instance.sh' && su - db2inst1 -c 'db2stop' && su - db2inst1 -c 'db2start'
``` 


## Sample Blockchain Insurance App Walkthrough

Use the link http://localhost:3000 to load the web application in browser.

The home page shows the participants (Peers) in the network. You can see that there is an Insurance, Repair Shop, Police and Shop Peer implemented. They are the participants of the network.

![Blockchain Insurance](images/home.png)

Imagine being a consumer (hereinafter called “Biker”) that wants to buy a phone, bike or Ski. By clicking on the “Go to the shop” section, you will be redirected to the shop (shop peer) that offers you the following products.

![Customer Shopping](images/Picture1.png)

You can see the three products offered by the shop(s) now. In addition, you have insurance contracts available for them. In our scenario, you are an outdoor sport enthusiast who wants to buy a new Bike. Therefore, you’ll click on the Bike Shop section.

![Shopping](images/Picture2.png)

In this section, you are viewing the different bikes available in the store. You can select within four different Bikes. By clicking on next you’ll be forwarded to the next page which will ask for the customer’s personal data.

![Bike Shop](images/Picture3.png)

You have the choice between different insurance contracts that feature different coverage as well as terms and conditions. You are required to type-in your personal data and select a start and end date of the contract. Since there is a trend of short-term or event-driven contracts in the insurance industry you have the chance to select the duration of the contract on a daily basis. The daily price of the insurance contract is being calculated by a formula that had been defined in the chaincode. By clicking on next you will be forwarded to a screen that summarizes your purchase and shows you the total sum.

![Bike Insurance](images/Picture4.png)

The application will show you the total sum of your purchase. By clicking on “order” you agree to the terms and conditions and close the deal (signing of the contract). In addition, you’ll receive a unique username and password. The login credentials will be used once you file a claim.  A block is being written to the Blockchain.

>note You can see the block by clicking on the black arrow on the bottom-right.

![Bike Insurance](images/Picture5.png)

Login credentials. Block written to the chain.

![Login Credentials](images/Picture6.png)

Once an incident has happened the Biker can file a claim on his own by selecting the “claim Self-Service” tab.

![Claim Service](images/Picture61.png)

The Biker will be asked to login by using the credentials that had been given to him before.

![Login](images/Picture7.png)

He can file a new claim by selecting the tab shown above.

![File Claim](images/Picture8.png)

The Biker can briefly describe the damage on his bike and/or select whether it has been stolen. In case the Bike has been stolen the claim will be processed through the police who has to confirm or deny the theft (option 1). In case there was just a damage the claim will be processed through the repair shop (option 2). In the following section, we will start with option 1.

![Claim Description](images/Picture9.png)

**Option 1**

Once the Biker has submitted the claim it will be shown in the box marked in red. Furthermore, another block is being written to the chain.
![Claim Block](images/Picture10.png)

The Biker can also view the active claims. **Note:** You may need to re-log into Claims Processing to see the new active claim.

![Active Claims](images/Picture11.png)

By selecting “claim processing” the Insurance company can view all active claims that have not been processed yet. A clerk can decide on the claims in this view. Since we are still looking at option 1 the theft has to be confirmed or denied by the police. Therefore, the insurance company can only reject the claim at this point in stage.

![Claim Processing](images/Picture12.png)

The Police Peer can view the claims that include theft. In case the bike has been reported stolen they can confirm the claim and include a file reference number. In case no theft has been reported they can reject the claim and it will not be processed.

![Police Peer](images/Picture13.png)

Let’s assume the Biker did not rip-off the insurance company and has reported the bike as stolen. The police will confirm the claim which results in another Block being written to the chain.

![Police Transaction](images/Picture14.png)

Going back to the “claim processing” tab you can see that the insurance company has the option to reimburse the claim now because the police had confirmed that the bike has been stolen. Block is being written to the chain

![Claim Processing](images/Picture15.png)

The Biker can see the new status of his claim which changed to reimbursed.

![User login](images/Picture16.png)

**Option 2**

Option 2 covers the case of an accident.

![Accident](images/Picture17.png)

The insurance “claim processing” tab shows the unprocessed claims. A clerk can choose between three options on how to process the claim. “Reject” will stop the claim process whereas “reimburse” leads directly to the payment to the customer. In case something needs to be repaired the insurance company has the option to select “repair”. This will forward the claim to a repair shop and will generate a repair order. A block is being written to the chain.

![Claim Processing](images/Picture18.png)

The Repair Shop will get a message showing the repair order. Once they’ve done the repair works the repair shop can mark the order as completed. Afterwards, the insurance company will get a message to proceed the payment to the repair shop. a block is being written to the chain

![Reapir Shop](images/Picture19.png)

The Biker can see in his “claim self-service” tab that the claim has been resolved and the bike was repaired by the shop.

![Claim Status](images/Picture20.png)

The insurance company has the option to activate or deactivate certain contracts. This does not mean that contracts that have already been signed by customers will be no longer valid. It just does not allow new signings for these types of contracts. In addition, the insurance company has the possibility to create new contract templates that have different terms and conditions and a different pricing.  Any transaction will result in a block being written to the chain.

![Contract Management](images/Picture21.png)


## Configure a Federated Server to Access the Blockchain

To learn about Db2 federated server please follow [go here](https://www.ibm.com/support/producthub/db2/docs/content/SSEPGG_11.5.0/com.ibm.data.fluidquery.doc/topics/cfpint23.html)

To setup the Db2 federated server, execute the following script in the `db2-fabric` container:

```bash
docker exec -it db2-fabric bash
su - db2inst1 -c "db2 connect to testdb && db2 -tvf /samples/insurance-setup.sql"
```

The SQL file located in the `./db2-fabric/db2-container/samples` directory titled `insurance-setup.sql` contains details on how the server is created.

### Manage Interpreter Settings in Zeppelin Notebook

Zeppelin notebook uses Db2 federated server and SQL to run queries on the blockchain network. We need to configure zeppelin interpreter details and specify Db2 connection parameters. Zeppelin Interpreter is the plug-in which enable zeppelin user to use a specific language/data-processing-backend. Navigate to `http://localhost:8080` where the zeppelin-notebook is running.

![zeppelin notebook](images/zeppelin-notebook.png)

Select `Interpreter` from top right corner of the `Anonymous` user. We need to modify `jdbc` and `sh` settings.

![zeppelin notebook](images/interpreter.png)


#### Search `jdbc` from the text box and modify the following details:

![jdbc settings](images/jdbc-settings.png)

```bash
default.driver  -->  com.ibm.db2.jcc.DB2Driver
default.url --> jdbc:db2://db2-fabric:50000/testdb
default.user --> db2inst1
default.password --> password
```
1.	`db2` is the relational database we are using
2.	`db2-fabric` is the name of the docker container that `db2` is running on
3.	`50000` is the open port we will be accessing
4.	`testdb` is the name of the database that we want to connect to

#### Search for `sh` from the text box and modify the following details: 

![sh settings](images/sh-settings.png)

```bash
shell.command.timeout.millisecs --> 600000
```
This will ensure that we won’t receive a timeout when executing a datagenerator job.

#### Db2 jar dependency
Also add the location of Db2 JDBC driver artifact under Dependencies. Add
`/opt/zeppelin/notebook/db2jcc.jar` in the text field and save.


## Generate Transactions on the Blockchain

Navigate to zeppelin UI using `http://localhost:8080`. Before we can analyze the Blockchain, we must first create a notebook and generate some demo data. Import notebook by clicking `import note` from zeppelin home page and upload the json file from your repository in location `zeppelin-notebook/notebook/Blockchain Demo.json`

Open the notebook by clicking the uploaded notebook from the home page. The first cell has command that identifies the private key used to connect to the Blockchain app and will set this in the properties file.

We have bundled together a data generator written in Java, and the next command will run the data generator job.

```bash
java -cp /opt/zeppelin/notebook/fabric-datagen-dependencies-1.0-DATAGEN.jar com.ibm.federation.datagen.GenerateTransactions --config-file=/opt/zeppelin/notebook/insurance.properties --datagen-type=insurance --flows=5 --attempts=100 --channel-name=default --chaincode-name=bcins seed-concurrent --threads=2
```

This data generator is compatible with other Blockchain applications so we must specify the type of blockchain to use. In this case, `datagen-type` should be set to `insurance`.

`Flows` refers to the various paths a customer can take based off the events that occur during the purchase of a product.

![Flows](images/flows.png)

From the Hyperledger Docs, A `channel` is defined as a private “subnet” of communication between two or more specific network members and we had configured the channel name to be `default`.

The `chaincode` name is defined as `bcins`

To generate transactions, select the first cell and click the `play` icon on the top right of the cell. Youc an then see transactions being generated on the blockchain by vieweing the Block explorer in the web app. There will be 50 transaction generated with 5 flows and this will take around 2 minutes to complete. 

![Generated transactions](images/generated-transactions.png)

With valid transactions being generated on the Blockchain, we can now query the Blockchain.

#### Query Blockchain via Zeppelin Notebooks using SQL

With configuration of the Federation server completed and transactions generated, we can now focus on analyzing the Blockchain. From the data analysts persona who works for insurance organization, we can anticipate 3 lines of business who would be interested in exploring different kinds of business insights from this network.

`Insurance Sales Reporting` focuses on analyzing the amount. Some insights can be:
1.	How many Contract were sold and over what period of time?
2.	What’s the policy purchase distribution over various dates/months?
3.	How much Revenue has been generated by selling policies in total or quarters?

`Insurance Claim Analysis`. Some insights can be:
1.	How many claims were filed for each product?
2.	What is the exposure for each product?

`Insurance Risk Analysis`. Some insights can be:
1.	What is the comparison between revenue vs claims paid?
2.	Are there any fraud claims that cannot be verified by police or theft?

We can start off by doing some basic exploration of data to see what we are dealing with.

Using the nickname `nn_tx `we had created for accessing transactions as local tables, we can execute a `select *` to get an understanding on this table.

Some noticeable columns to point out are 

```sql
ID: 
BLOCK_ORDINAL:
ORDINAL:
CHANNEL_ID:
CREATION_TIME:
CREATOR_MSPID
CREATOR_CERT
IS_VALID
VALIDATION_CODE
IS_TRANSACTION
SIGNATURE
CHAINCODE_ID:
ENDORSEMENT_CODE:
ARGS_COUNT:
```
In this blockchain application, there are three argument columns that we can use.

```
ARG_0 stores
ARG_1 stores
ARG_2 stores the business logic and is the most useful column that we can leverage
```

Here is an example of a JSON Payload with business details:

```json
{
   “contract_type_uuid":"17d773dc-2624-4c22-a478-87544dd0a17f",
   "username":"colin-bell-94@yahoo.com",
   "password":"",
   "first_name":"Colin",
   "last_name":"Bell",
   "item":{
      "id":1,
      "brand":"Apple",
      "model":"6",
      "price":630,
      "serial_no":"ZE5YYL"
   },
   "start_date":"2018-12-11T19:54:29.168Z",
   "end_date":"2018-12-23T01:40:20.736Z",
   "uuid":"3163b36c-0629-4974-bfbd-bdcb09f90a26"
}
```
For each insight there is a query you can run in the respective cell of the zeppelin notebook you have uploaded, to get the insight details.


## Additional resources
Following is a list of additional blockchain resources:
* [Fundamentals of IBM Blockchain](https://www.ibm.com/blockchain/what-is-blockchain)
* [Hyperledger Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
* [Hyperledger Fabric code on GitHub](https://github.com/hyperledger/fabric)

## Troubleshooting

* Run `clean.sh` to remove the docker images and containers for the insurance network.
```bash
./clean.sh
```
## License
This code pattern is licensed under the Apache Software License, Version 2.  Separate third party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1 (DCO)](https://developercertificate.org/) and the [Apache Software License, Version 2](https://www.apache.org/licenses/LICENSE-2.0.txt).

[Apache Software License (ASL) FAQ](https://www.apache.org/foundation/license-faq.html#WhatDoesItMEAN)
