<template>
    <div>
      <h1>Partager un document avec autorisation de visualisation</h1>
      <label for="documentId">ID du document :</label>
      <input type="number" v-model="documentId" id="documentId" placeholder="ID du document">
      <label for="userId">ID de l'utilisateur :</label>
      <input type="number" v-model="userId" id="userId" placeholder="ID de l'utilisateur">
      <button @click="shareDocument">Partager le document</button>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    data() {
      return {
        documentId: null,
        userId: null
      };
    },
    methods: {
      shareDocument() {
        if (!this.documentId || !this.userId) {
          alert("Veuillez remplir tous les champs.");
          return;
        }
        
        axios.post(`/api/document/${this.documentId}/share/${this.userId}`)
          .then(response => {
            console.log(response.data.message);
            alert(response.data.message);
          })
          .catch(error => {
            console.error("Erreur lors du partage du document :", error);
            alert("Une erreur s'est produite lors du partage du document.");
          });
      }
    }
  }
  </script>
  
