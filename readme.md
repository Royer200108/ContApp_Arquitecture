# ContApp

Este es un proyecto de implementación de infraestructura en Azure diseñada para una posible aplicación contable haciendo uso de la herramienta de código Terraform.

## ¿Qué es Terraform?

<img src="/img/Logo-Terraform.png" style="width: 400px; heigth: 400px">

*Terraform* es una herramienta de configuración de software diseñada para automatizar múltiples procesos  por medio de conceptos como el de **Infrastructure As Code**

## Azure.

<img src="/img/Logo-Azure.png" style="width: 400px; heigth: 400px">

*Azure* es una nube pública de pago por uso que permite compilar, implementar y administrar de manera rápida aplicaciones en una red global de centros de datos (dataceters) de Microsoft.

## Estructura de Terraform.
Con el uso de *Terraform* se ha concebido la infraetructura de la propuesta de proyecto para una hipotética Aplicación Contable.

### Recursos que contiene estr proyecto.
Para la realización de este proyecto se incluyeron los siguientes recursos.
* App Service Plan.
* Redes virtuales (VNets).
* Sub redes (SubNets).
* Servidor de Bases de Datos (Azure SQL).
* Almacenamientos (Blob storage y Queue storage).
* Function apps.

### Diagrama de infraestructura.

<img src="/img/Infraestructura.png">