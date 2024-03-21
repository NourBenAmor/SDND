<template>
  <main class="container">
    <div class="button-container">
      <a @click="downloadDocument" class="btn btn-link text-primary px-3 mb-0">
        <i class="fas fa-download text-primary me-2" aria-hidden="true"></i>Download
      </a>
      <a class="btn btn-link text-primary px-3 mb-0">
        <i class="fas fa-share text-primary me-2" aria-hidden="true"></i>Share
      </a>
    </div>
    <pdf
      class="viewer"
      :src="src"
      :page="1"
    >
      <slot>
        loading content here...
      </slot>
    </pdf>
  </main>
</template>

<script setup>
  import { ref } from 'vue';
  import pdf from 'pdfvuer';
  import { useRoute } from 'vue-router';

  const route = useRoute();
  const documentId = ref(route.params.id);
  const src = ref(`https://localhost:7278/api/Document/pdf/${documentId.value}`);
  
  console.log(route); 

  const downloadDocument = async () => {
  
}
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  align-items: center; 
}

.button-container {
  display: flex;
  gap: 10px; 
}

.viewer {
  height: 80vh; 
  width: 80%; 
}
</style>