# Projects

## Data Migration

### Three Main .Net Core (3.1) Command Line Programs

* **Composer** - Reads 6 databases and writes JSON messages to files one message per line.

  * Uses the `command pattern`
  * Executes a single migration command based on command line.
  * Uses the `factory pattern` to determine command and insert it into the IoC (Inversion of Control) Container.
  * **Entity Framework** with LINQ to SQL and stored procedure wrappers.

* **DeliveryMan** - Reads text from a file and publishes the text to Azure Topics on the bus.

  * Track message sent in an **Azure Storage Table**
  * Logs messages to **Application Insights**

* **Informer** - Subscribes to an Azure subscription and writes messages to an Azure storage table.

  * Can be configured to filter on different types of sources.

* **PowerBI Reports** - Gather many different sources for reconciliation

  * Pre-Migration Report - Detects what's missing **BEFORE** running the data migration
  * Status Tracking - Calls out the errors versus successes
  * Reconciliation Report - Something that the business looks at to make sure all the messages align with the data in the destination system.

## Movie Release Calendar

* Proof of concept in .Net Core against vanilla API.
* Assisted with **Angular** (version ?)
* **GraphQL** - Second phase of the Noovie API.

## Azure

* Service Bus
* Storage
* Active Directory
* Key Vault
* Web Apps
* Logic Apps
* Function Apps
* Cognitive Services
* Redis Cache
