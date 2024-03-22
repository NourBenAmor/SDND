<template>
    <div>
      <h2>Historique des Révisions pour {{ document.title }}</h2>
      <ul>
        <li v-for="revision in revisions" :key="revision.id">
          <div>{{ revision.revisionDate }}</div>
          <div>{{ revision.content }}</div>
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  export default {
    props: ['document'],
    data() {
      return {
        revisions: []
      };
    },
    mounted() {
      this.fetchRevisions();
    },
    methods: {
      async fetchRevisions() {
        const response = await fetch(`/api/documents/${this.document.id}/revisions`);
        this.revisions = await response.json();
      }
    }
  };
  </script>
  
