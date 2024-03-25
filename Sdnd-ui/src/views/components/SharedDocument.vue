<template>
    <div>
      <h2>Documents Partagés</h2>
      <ul>
        <li v-for="document in sharedDocuments" :key="document.id">
          <div>{{ document.title }}</div>
          <div>{{ document.content }}</div>
          <!-- Autres détails du document à afficher -->
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        sharedDocuments: []
      };
    },
    mounted() {
      this.fetchSharedDocuments();
    },
    methods: {
      fetchSharedDocuments() {
        const userId = 
        axios.get(`/api/shareddocuments/${userId}`)
          .then(response => {
            this.sharedDocuments = response.data;
          })
          .catch(error => {
            console.error('Erreur lors de la récupération des documents partagés', error);
          });
      }
    }
  };
  </script>
  
