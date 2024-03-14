## Solution de Numerisation de Documents : 
##### Description
Ce projet vise à créer une application de gestion de documents complète. Il permettra aux utilisateurs d’annoter facilement des documents au format PDF, de créer de nouveaux documents, de les partager avec d’autres utilisateurs et de rédiger une description pour chacun d’eux. De plus, l’application permettra également d’ajouter des annotations aux documents existants. L’idée principale du projet est de numériser de nouveaux documents et de les intégrer à la solution via l’application mobile développée en Flutter.
###### Technologies utilisées
* Backend (API) :
ASP.NET Core : Sert de base pour l’API Web.
Entity Framework Core : Utilisé pour l’accès aux données et la gestion de la base de données.
Swagger : Permet la documentation et les tests de l’API.
* Frontend (Web) :
Vue js :  Framework JavaScript Évolutif, accessible, performant et polyvalent. pour construire des interfaces utilisateur. 
* Frontend (Mobile) :
Flutter : Framework multiplateforme pour la création d’applications mobiles.

## Installation et exécution de l'application Sdnd

##### Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants installés sur votre machine :

* .NET 8 SDK
* Node.js
* NPM

##### Étapes

1. **Ouvrez la solution Sdnd/Sdnd-api dans votre IDE préféré.**
2. **Restaurez les packages NuGet:**

```
dotnet restore
```

3. **Configurez la chaîne de connexion à la base de données dans le fichier appsettings.json.**
4. **Exécutez les migrations pour créer le schéma de la base de données:**

```
dotnet ef database update
```

5. **Démarrez l'API:**

```
dotnet run
```

6. **Configurez le frontend web:**

    * Ouvrez la solution Sdnd/Sdnd-ui.
    * Installez les packages NPM:

```
npm install
```

8. **Démarrez le serveur web:**

```
npm run serve
```

## Lien Jira de Project 
suivre l'avancement de project [Ici](https://jassersoftware.atlassian.net/jira/software/projects/SDND/boards/4?atlOrigin=eyJpIjoiZmViZTljN2JjZjc4NDJlMmI5ZjA5OWVjZTkzZGNmNjQiLCJwIjoiaiJ9)
