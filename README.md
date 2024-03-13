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
    * npm run serve
