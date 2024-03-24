<template>
    <div>
      <h1>Liste des Documents</h1>
      <ul>
        <li v-for="document in documents" :key="document.id">
          <div>{{ document.title }}</div>
          <div>{{ document.content }}</div>
          <button @click="showRevisions(document)">Voir Révisions</button>
        </li>
      </ul>
      <div v-if="selectedDocument">
        <document-revisions :document="selectedDocument" />
      </div>
    </div>
  </template>
  
  <script>
  import DocumentRevisions from './DocumentRevisions.vue';
  
  export default {
    components: {
      DocumentRevisions
    },
    data() {
      return {
        documents: [],
        selectedDocument: null
      };
    },
    mounted() {
      this.fetchDocuments();
    },
    methods: {
      async fetchDocuments() {
        const response = await fetch('/api/documents');
        this.documents = await response.json();
      },
      showRevisions(document) {
        this.selectedDocument = document;
      }
    }
  };
  </script>
  
