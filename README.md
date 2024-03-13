## Solution de Numerisation de Documents : 
##### Description
Ce projet illustre une application full-stack avec une API ASP.NET Core en tant que backend et une application mobile Flutter en tant que frontend. Les utilisateurs peuvent effectuer diverses tâches, telles que récupérer des données depuis l’API, les afficher dans l’application mobile et interagir avec le serveur.

###### Technologies utilisées
* Backend (API) :
ASP.NET Core : Sert de base pour l’API Web.
Entity Framework Core : Utilisé pour l’accès aux données et la gestion de la base de données.
Swagger : Permet la documentation et les tests de l’API.
* Frontend (Web) :
Vue js :  Framework JavaScript Évolutif, accessible, performant et polyvalent. pour construire des interfaces utilisateur. 
* Frontend (Mobile) :
Flutter : Framework multiplateforme pour la création d’applications mobiles.
##### Pour commencer
Configuration du backend :

Ouvrez la solution Sdnd/Sdnd-api dans IDE préféré et executer : * dotnet restore 
Configurez la chaîne de connexion à la base de données dans appsettings.json.
Exécutez les migrations pour créer le schéma de la base de données: 
    * dotnet ef database update.
Démarrez l’API : * dotnet run.
Configuration du frontend web:
Ouvrez la solution sous Sdnd/Sdnd-ui
    * npm install 
    * npm run 
