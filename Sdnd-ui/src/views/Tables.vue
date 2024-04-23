<script setup>
import AuthorsTable from "./components/DocumentsTable.vue";
</script>
<template>
  <div class="py-4 container-fluid">
    <div class="row">
      <div class="col-12">
        <authors-table />
      </div>
    </div>
  </div>
</template>
./components/DocumentsTable.vue import axios from 'axios'; export default {
data() { return { documents: [] }; }, mounted() { this.fetchDocuments(); },
methods: { async fetchDocuments() { try { const response = await axios.get('');
this.documents = response.data; } catch (error) { console.error('Erreur lors de
la récupération des documents:', error); } } } };
