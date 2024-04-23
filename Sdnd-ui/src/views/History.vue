<template>
  <div>
    <h1>Liste des Documents</h1>
    <ul>
      <li v-for="document in documents" :key="document.id">
        <div>{{ document.title }}</div>
        <div>{{ document.content }}</div>
        <button @click="showAnnotations(document)">Voir Annotations</button>
      </li>
    </ul>
    <div v-if="selectedDocument">
      <document-revisions :document="selectedDocument" />
    </div>
  </div>
</template>

<script>
import DocumentAnnotations from "./DocumentAnnotations.vue";

export default {
  components: {
    DocumentAnnotations,
  },
  data() {
    return {
      documents: [],
      selectedDocument: null,
    };
  },
  mounted() {
    this.fetchDocuments();
  },
  methods: {
    async fetchDocuments() {
      const response = await fetch("/api/documents");
      this.documents = await response.json();
    },
    showAnnotations(document) {
      this.selectedDocument = document;
    },
  },
};
</script>
